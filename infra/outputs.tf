# outputs.tf
output "private_key_pem" {
  sensitive = true
  value     = module.key_pair.private_key_pem
}

output "server_public_ip" {
  value = module.velociraptor_server.public_ip
}

output "client_public_ip" {
  value = module.velociraptor_client.public_ip
}
