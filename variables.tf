variable "database_master_password" {
    description = "password"
    type = string
    default = "password"
} 
variable "multi-az-deployment" {
  description = "create a standby DB instance"
  type        = bool
  default     = true
}
