variable "vsphere_user" {
  description = "vCenter username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vCenter password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vCenter server IP or FQDN"
  type        = string
}


variable "windows_admin_password" {
  description = "Local Administrator password for Windows VMs"
  type        = string
  sensitive   = true
}
