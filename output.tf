# Outputs for Signed Certificate and SSH Keys
output "signed_certificate" {
  value       = vault_ssh_secret_backend_cert.ssh_cert.signed_key
  description = "This is the signed SSH certificate for access to the target VM."
}

output "private_key" {
  value       = tls_private_key.ssh_key.private_key_pem
  description = "The private SSH key for connecting to the target VM. Store it securely!"
  sensitive   = true  # Mark as sensitive to avoid displaying in logs
}

output "public_key" {
  value       = tls_private_key.ssh_key.public_key_openssh
  description = "The public SSH key to be used for access."
}
