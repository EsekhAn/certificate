output "build_public_ip" {
  description = "Публичный IP сборочной ВМ"
  value       = yandex_compute_instance.build.network_interface[0].nat_ip_address
}

output "stage_public_ip" {
  description = "Публичный IP stage-ВМ"
  value       = yandex_compute_instance.stage.network_interface[0].nat_ip_address
}

output "build_instance_id" {
  description = "ID сборочной ВМ"
  value       = yandex_compute_instance.build.id
}

output "stage_instance_id" {
  description = "ID stage-ВМ"
  value       = yandex_compute_instance.stage.id
}

output "app_url" {
  description = "URL приложения на stage"
  value       = "http://${yandex_compute_instance.stage.network_interface[0].nat_ip_address}:${var.app_port}/hello/"
}

output "registry_id" {
  description = "ID реестра Yandex Container Registry"
  value       = yandex_container_registry.app.id
}

output "registry_host" {
  description = "Host реестра для docker login"
  value       = "cr.yandex"
}

output "registry_image_url" {
  description = "Полный URL образа без тега: cr.yandex/<registry-id>/<image-name>"
  value       = "cr.yandex/${yandex_container_registry.app.id}/${var.image_name}"
}

output "zone" {
  description = "Зона, в которой создана инфраструктура"
  value       = var.zone
}

output "ssh_user" {
  description = "Пользователь SSH для Ubuntu-образа"
  value       = "ubuntu"
}
