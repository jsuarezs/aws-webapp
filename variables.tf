variable "access_key" {
  description = "Access key to AWS console"
}
variable "secret_key" {
  description = "Secret key to AWS console"
}
variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR addresses for VPC"
}
variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(any)
  description = "Subnet CIDRs addresse blocks"
}
variable "availability_zones" {
  default     = ["eu-west-1a", "eu-west-1b"]
  type        = list(any)
  description = "Availability zones in Ireland"
}
variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.3.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}
variable "server_port" {
  description = "The port the web server will be listening"
  type        = number
  default     = 8080
}
variable "elb_port" {
  description = "The port the elb will be listening"
  type        = number
  default     = 80
}