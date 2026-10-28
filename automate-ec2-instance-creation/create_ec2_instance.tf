# Create an key pair
resource "aws_key_pair" "terraform_key_pair" {
    key_name   = "terraform_key_pair"
    public_key = file("~/.ssh/terraform_key_pair.pub")

}

# use default vpc

resource "aws_default_vpc" "default" {
 
}

# Create a security group
resource "aws_security_group" "terraform_security_group" {

    name = "terraform_security_group"
    vpc_id = aws_default_vpc.default.id
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
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

    ami = "ami-03a23d9d58ea08615" #ubuntu
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.terraform_security_group.id]
     root_block_device  {
        volume_size           = 20
        volume_type           = "gp3"
        delete_on_termination = true
    }
    tags = {
    Name        = "Terraform-Ubuntu-Host"
    Environment = "Dev"
    }

}