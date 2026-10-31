module "infra_dev" {
  source = "./infra"
  env    = "dev"
  key_pair_name = "terraform-key-pair"
  security_group_name = "terraform-security-group"
    ec2_image = "ami-03a23d9d58ea08615"
    ec2_instance_type = "t3.micro"
}
module "infra_staging" {
  source = "./infra"
  env    = "staging"
  key_pair_name = "terraform-key-pair"
  security_group_name = "terraform-security-group"
    ec2_image = "ami-03a23d9d58ea08615"
    ec2_instance_type = "t3.small"
}
