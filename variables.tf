variable "owner" {

}

variable "environment" {

}

variable "vpc_id" {

}

variable "private_subnets" {

}

variable "instance_type" {
  default = "t3.small"
}

variable "additional_instances" {
  default = []
}

variable "instance_min_size" {
  type = number
}

variable "instance_max_size" {
  type = number
}

variable "enable_cloudmap" {
  default = false
}

variable "instance_allow_security_group_ids" {
  description = "The security group ids allowed to access cluster instances. Generally this will be ALB security groups."
  default     = []
}

variable "architecture" {
  default     = "STANDARD"
  type        = string
  description = "Choose the task definition architecture."
  validation {
    condition     = contains(["STANDARD", "ARM"], var.architecture)
    error_message = "The container must use either AMD64 or ARM64 architecture."
  }
}

variable "ami_id" {
  default = null
}