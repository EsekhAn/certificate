locals {
  name = "${var.project}-${var.environment}"

  labels = {
    project     = var.project
    environment = var.environment
    managed-by  = "terraform"
    homework    = "certification-17"
  }
}

data "yandex_client_config" "current" {}

data "yandex_compute_image" "ubuntu" {
  family    = var.ubuntu_image_family
  folder_id = "standard-images"
}

resource "yandex_vpc_network" "main" {
  name   = local.name
  labels = local.labels
}

resource "yandex_vpc_subnet" "public" {
  name           = "${local.name}-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.subnet_cidr]
  labels         = local.labels
}

resource "yandex_vpc_security_group" "build" {
  name        = "${local.name}-build"
  description = "Build node: SSH from the administrator, all outbound traffic"
  network_id  = yandex_vpc_network.main.id
  labels      = local.labels

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description    = "Maven Central, Docker Hub, Container Registry"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "stage" {
  name        = "${local.name}-stage"
  description = "Stage node: SSH from the administrator and the application port"
  network_id  = yandex_vpc_network.main.id
  labels      = local.labels

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description    = "Application HTTP port"
    protocol       = "TCP"
    port           = var.app_port
    v4_cidr_blocks = [var.allowed_app_cidr]
  }

  egress {
    description    = "Container Registry and package repositories"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_iam_service_account" "registry" {
  name        = "${local.name}-registry"
  description = "Push/pull images in Yandex Container Registry from build and stage VMs"
}

resource "yandex_resourcemanager_folder_iam_member" "registry_pusher" {
  folder_id = data.yandex_client_config.current.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.registry.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "registry_puller" {
  folder_id = data.yandex_client_config.current.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.registry.id}"
}

resource "yandex_container_registry" "app" {
  name   = "${local.name}-app"
  labels = local.labels
}

resource "yandex_compute_instance" "build" {
  name        = "${local.name}-build"
  description = "Build node: docker build + push to Container Registry"
  zone        = var.zone
  platform_id = var.platform_id
  labels      = local.labels

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.build.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
  }

  service_account_id = yandex_iam_service_account.registry.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.registry_pusher,
    yandex_resourcemanager_folder_iam_member.registry_puller,
  ]
}

resource "yandex_compute_instance" "stage" {
  name        = "${local.name}-stage"
  description = "Stage node: docker compose up"
  zone        = var.zone
  platform_id = var.platform_id
  labels      = local.labels

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = var.stage_disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.stage.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
  }

  service_account_id = yandex_iam_service_account.registry.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.registry_pusher,
    yandex_resourcemanager_folder_iam_member.registry_puller,
    yandex_compute_instance.build,
  ]
}
