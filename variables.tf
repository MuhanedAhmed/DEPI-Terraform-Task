# --------------------------------------------------------------- #
# ------------- Main Cofiguration Files Variables --------------- #
# --------------------------------------------------------------- #

#------------------------------------------------------------------
# Provider Variables
#------------------------------------------------------------------

variable "region" {
  type = string
}

#------------------------------------------------------------------
# VPC Module Variables
#------------------------------------------------------------------

variable "main_vpc_ip" {
  type        = string
  description = "A CIDR block for the VPC"
}

variable "public_subnet_IP_1" {
  type        = string
  description = "A CIDR block for the public subnet 1"
}

variable "public_subnet_IP_2" {
  type        = string
  description = "A CIDR block for the public subnet 2"
}


variable "public_subnet_AZ_1" {
  type        = string
  description = "The Availability Zone (AZ) for the public subnet 1"
}

variable "public_subnet_AZ_2" {
  type        = string
  description = "The Availability Zone (AZ) for the public subnet 2"
}

variable "private_subnet1_IP" {
  type        = string
  description = "A CIDR block for the private subnet 1"
}

variable "private_subnet2_IP" {
  type        = string
  description = "A CIDR block for the private subnet 2"
}

variable "private_subnet1_AZ" {
  type        = string
  description = "The Availability Zone (AZ) for the private subnet 1"
}

variable "private_subnet2_AZ" {
  type        = string
  description = "The Availability Zone (AZ) for the private subnet 2"
}


#------------------------------------------------------------------
# EC2 Module Variables 
#------------------------------------------------------------------

variable "instance_type" {
  type        = string
  description = "The size of the EC2 instance"
}

variable "instance_ami" {
  type        = string
  description = "The AMI of the EC2 instance"
}


#------------------------------------------------------------------
# RDS Variables
#------------------------------------------------------------------

