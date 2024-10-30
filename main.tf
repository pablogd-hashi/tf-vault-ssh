# Step 1: Provider Configuration
provider "vault" {
  address = "https://pablogd-hcpvault-public-vault-3c856fd2.fd392cd2.z1.hashicorp.cloud:8200"  # Replace with your Vault server's address
}

# Step 2: Fetch AppRole Details Dynamically
data "vault_approle_auth_backend_role_id" "terraform_role_id" {
  backend = "auth/approle"      # Path where AppRole is enabled
  role    = "terraform"          # Name of the AppRole created for Terraform
}

data "vault_approle_auth_backend_role_secret_id" "terraform_secret_id" {
  backend = "auth/approle"
  role    = "terraform"
}

# Step 3: SSH Key Pair Generation
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Step 4: Vault Authentication with Dynamic IDs
provider "vault" {
  address = "https://pablogd-hcpvault-public-vault-3c856fd2.fd392cd2.z1.hashicorp.cloud:8200"
  
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = data.vault_approle_auth_backend_role_id.terraform_role_id.id
      secret_id = data.vault_approle_auth_backend_role_secret_id.terraform_secret_id.secret_id
    }
  }
}

# Step 5: SSH Certificate Request
resource "vault_ssh_secret_backend_cert" "ssh_cert" {
  backend     = "ssh-ca"               # Path to the SSH CA engine in Vault
  name        = "terraform-role"        # Role created in Vault for SSH CA
  
  public_key  = tls_private_key.ssh_key.public_key_openssh  # Public key from the generated key pair
  private_key = tls_private_key.ssh_key.private_key_pem      # Private key from the generated key pair

  # Optional: output the signed certificate so you can easily retrieve it
  provisioner "local-exec" {
    command = "echo '${self.signed_key}' > signed-cert.pem"
  }
}

# Step 6: Output the Signed Certificate
output "signed_certificate" {
  value       = vault_ssh_secret_backend_cert.ssh_cert.signed_key
  description = "This is the signed SSH certificate for access to the target VM."
}

# Step 7: Output the Private Key (Optional)
output "private_key" {
  value       = tls_private_key.ssh_key.private_key_pem
  description = "The private SSH key for connecting to the target VM. Store it securely!"
  sensitive   = true  # Mark as sensitive to avoid displaying in logs
}

# Step 8: Output the Public Key (Optional)
output "public_key" {
  value       = tls_private_key.ssh_key.public_key_openssh
  description = "The public SSH key to be used for access."
}
