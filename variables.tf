variable "libvirt_uri" {
  description = "libvirt uri to use - https://libvirt.org/uri.html"
  type        = string
  default     = "qemu:///system"
}

variable "remnux_vcpu_count" {
  type    = number
  default = 2
}

variable "remnux_memory_mb" {
  type    = number
  default = 4 * 1024 # 4Gb
}

variable "pool_name" {
  description = "storage pool to store the REMnux disk - https://libvirt.org/storage.html"
  type        = string
  default     = "default"
}


