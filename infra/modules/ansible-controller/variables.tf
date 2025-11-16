variable "region" {
  description = "The AWS region to deploy the Ansible controller instance."
  type        = string
  default     = "sa-east-1" 
}

variable "ami_id" {
  description = "The AMI ID for the Ansible controller instance."
  type        = string
  default = "ami-0684eabefb252036e"
}

variable "instance_type" {
    description = "The instance type for the Ansible controller instance."
    type        = string
    default     = "t3.micro"
}

variable "instance_name" {
    description = "The name tag for the Ansible controller instance."
    type        = string
    default     = "Ansible-Controller"
}