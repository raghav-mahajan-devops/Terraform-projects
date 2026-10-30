resource "aws_key_pair" "terraform_key_pair_multi_instance" {
  key_name   = var.key_pair_name
  public_key = file("~/.ssh/terraform-key-pair-multi-instance.pub")
}

resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "aws_multi_instance_sg" {
  name   = var.security_group_name
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "multi_instance" {

  for_each = tomap({
    (var.instace_name[0]) = var.instace_type[0]
    (var.instace_name[1]) = var.instace_type[1]
  })
  ami                    = var.image
  key_name               = aws_key_pair.terraform_key_pair_multi_instance.key_name
  vpc_security_group_ids = [aws_security_group.aws_multi_instance_sg.id]
  instance_type          = each.value
  user_data              = file("nginx.sh")
  region                 = "us-west-2"
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
  tags = {
    Name = each.key
  }
}