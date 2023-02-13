##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "location" {
  description = "The region where the virtual network is created."
  default     = "southafricanorth"
}

variable "admin_username" {
   description = "GuestOS username"
}
variable "admin_password" {
   description = "GuestOS password"
}
