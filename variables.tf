# Variables for Vault Configuration
variable "vault_address" {
  description = "URL of the Vault server"
  type        = string
}

variable "role" {
  description = "Name of the AppRole for Vault authentication"
  type        = string
  default     = "terraform"  # Default value for convenience
}

# (Optional) Variables for SSH key generation
variable "ssh_key_algorithm" {
  description = "Algorithm for SSH key generation"
  type        = string
  default     = "RSA"
}

variable "ssh_key_size" {
  description = "Size of the SSH key"
  type        = number
  default     = 4096
}
