variable "key_pair_name" {
  description = "Name of the key pair to be created"
  type        = string
}

variable "security_group_name" {
  description = "Name of the security group to be created"
  type        = string
}

variable "ssh_port" {
  description = "Port number for SSH access"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "Port number for HTTP access"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Port number for HTTPS access"
  type        = number
  default     = 443
}

variable "protocol" {
  description = "Protocol for security group rules"
  type        = string
  default     = "tcp"
}

variable "ec2_image" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "storage_size" {
  description = "Size of the root block device in GB"
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "Type of the root block device volume"
  type        = string
  default     = "gp2"
}


variable "env" {
  description = "Environment name"
  type        = string
}

