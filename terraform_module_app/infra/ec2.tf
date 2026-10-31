# Create an key pair
resource "aws_key_pair" "terraform_key_pair" {
    key_name   = "${var.env}-${var.key_pair_name}"
    public_key = file("~/.ssh/terraform_key_pair.pub")
    tags = {
        Environment = var.env
    }

}

# use default vpc

resource "aws_default_vpc" "default" {
 
}

# Create a security group
resource "aws_security_group" "terraform_security_group" {
    tags = {
        Environment = var.env
    }
    name = "${var.env}-${var.security_group_name}"
    description = "Security group for Terraform EC2 instance"
    vpc_id = aws_default_vpc.default.id
    ingress {
        from_port   = var.ssh_port
        to_port     = var.ssh_port
        protocol    = var.protocol
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = var.http_port
        to_port     = var.http_port
        protocol    = var.protocol
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = var.https_port
        to_port     = var.https_port
        protocol    = var.protocol
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# create an EC2 instance
resource "aws_instance" "terraform_ec2" {

    ami = var.ec2_image
    instance_type = var.ec2_instance_type
    key_name = aws_key_pair.terraform_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.terraform_security_group.id]
     root_block_device  {
        volume_size           = var.storage_size
        volume_type           = var.volume_type
        delete_on_termination = true
    }
    tags = {
    Name        = "${var.env}-EC2-Instance"
    Environment = var.env
    }

}