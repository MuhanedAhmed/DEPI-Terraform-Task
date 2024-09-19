# -------------------------------------------------------------- #
# -------------------- ALB Module Variables -------------------- #
# -------------------------------------------------------------- #

variable "lb_name" {
  type        = string
  description = "Name of the LB"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "subnet-1-id" {
  type        = string
  description = "The ID of first subnet in subnet group"
}

variable "subnet-2-id" {
  type        = string
  description = "The ID of second subnet in subnet group"
}

variable "target_instance_1_id" {
  type        = string
  description = "The ID of the first EC2 instance"
}

variable "target_instance_2_id" {
  type        = string
  description = "The ID of the second EC2 instance"
}

variable "Security_Group_id" {
  type        = string
  description = "The ID of the security group"
}


variable "Is_Internal" {
  type        = bool
  description = "Determine whether the ALb is External or Internal"
}

variable "target_group_name" {
  type        = string
  description = "The name of the target group"
}