variable "key_pair_name" {
  default = "terraform-key-pair-multi-instance"
  type    = string
}

variable "security_group_name" {
  default = "multi-instance-sg"
  type    = string
}

variable "ssh_port" {
  default = 22
  type    = number
}
variable "http_port" {
  default = 80
  type    = number
}
variable "https_port" {
  default = 443
  type    = number
}
variable "protocol" {
  default = "tcp"
  type    = string
}

variable "instace_type" {
  type    = list(string)
  default = ["t3.micro", "t3.small"]
}

variable "instace_name" {
  type    = list(string)
  default = ["instance-1", "instance-2"]
}

variable "image" {
  default = "ami-03a23d9d58ea08615"
  type    = string
}
variable "environment" {
  type    = list(string)
  default = ["dev", "prod"]
}