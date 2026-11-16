variable "folder_id" {
  description = "ID каталога Yandex Cloud. Если не задан — провайдер берёт YC_FOLDER_ID"
  type        = string
  default     = null
}

variable "zone" {
  description = "Зона доступности Yandex Cloud"
  type        = string
  default     = "ru-central1-d"
}

variable "project" {
  description = "Префикс имён всех ресурсов"
  type        = string
  default     = "devops-cert"
}

variable "environment" {
  description = "Имя окружения (в задании — stage)"
  type        = string
  default     = "stage"
}

variable "subnet_cidr" {
  description = "CIDR создаваемой подсети"
  type        = string
  default     = "10.17.1.0/24"
}

variable "platform_id" {
  description = "Платформа ВМ"
  type        = string
  default     = "standard-v3"
}

variable "vm_cores" {
  description = "Количество vCPU на каждой ВМ"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Объём RAM каждой ВМ, ГБ (Maven + Docker требуют больше, чем 2 ГБ)"
  type        = number
  default     = 4
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU, % (20 достаточно для учебного стенда)"
  type        = number
  default     = 20
}

variable "disk_size" {
  description = "Размер загрузочного диска, ГБ"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Тип загрузочного диска сборочной ВМ: network-ssd или network-hdd"
  type        = string
  default     = "network-ssd"
}

variable "stage_disk_type" {
  description = "Тип загрузочного диска stage-ВМ. По умолчанию network-hdd, чтобы не упираться в квоту SSD в зоне"
  type        = string
  default     = "network-hdd"
}

variable "ubuntu_image_family" {
  description = "Семейство официальных образов Ubuntu в Yandex Cloud"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу, который добавляется в metadata ВМ"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "image_name" {
  description = "Имя образа приложения в Yandex Container Registry"
  type        = string
  default     = "hello"
}

variable "allowed_ssh_cidr" {
  description = "Откуда разрешён SSH. Для демо 0.0.0.0/0, для реального стенда — свой IP/32"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_app_cidr" {
  description = "Откуда доступен HTTP-порт приложения на stage"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Порт, на котором приложение публикуется на stage-ВМ"
  type        = number
  default     = 8080
}
