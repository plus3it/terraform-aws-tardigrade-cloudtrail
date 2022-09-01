resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-cloudtrail-"
}

output "random_name" {
  value = random_id.name.hex
}
