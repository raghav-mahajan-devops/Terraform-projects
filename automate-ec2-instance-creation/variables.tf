variable "ec2_image" {
    description = "The AMI ID for the EC2 instance"
    default     = "ami-03a23d9d58ea08615" # Ubuntu
    type        = string
  
}

variable "ec2_instance_type" {
    description = "The instance type for the EC2 instance"
    default     = "t2.micro"
    type        = string
}

variable "storage_size" {
    description = "The size of the root block device in GB"
    default     = 20
    type        = number
}

variable "volume_type" {
    description = "The type of the root block device"
    default     = "gp3"
    type        = string
}

variable "key_pair_name" {
    description = "The name of the key pair to use for the EC2 instance"
    default     = "terraform_key_pair"
    type        = string
}

variable "security_group_name" {
    description = "The name of the security group to create"
    default     = "terraform_security_group"
    type        = string
}

variable "http_port" {
    description = "The port for HTTP traffic"
    default     = 80
    type        = number
}
variable "https_port" {
    description = "The port for HTTPS traffic"
    default     = 443
    type        = number
}

variable "ssh_port" {
    description = "The port for SSH traffic"
    default     = 22
    type        = number
}

variable "protocol" {
    description = "The protocol for the security group rules"
    default     = "tcp"
    type        = string
}