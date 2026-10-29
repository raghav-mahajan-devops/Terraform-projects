# Terraform Projects

A collection of Infrastructure as Code (IaC) projects written with Terraform. They provision resources on AWS using the official `hashicorp/aws` provider.

| Project | Folder | Purpose |
|---|---|---|
| Automate EC2 instance creation | [automate-ec2-instance-creation](automate-ec2-instance-creation) | Creates a key pair, a security group and an Ubuntu EC2 instance in the default VPC |

## 1. automate-ec2-instance-creation

Provisions a ready-to-use Ubuntu web server on AWS with a single `terraform apply`.

**What it creates**
1. **Key pair** named `terraform_key_pair`, built from your local public key at `~/.ssh/terraform_key_pair.pub`.
2. **Default VPC** is adopted into Terraform so the other resources can reference it. Terraform does not create or delete it.
3. **Security group** that allows inbound SSH (22), HTTP (80) and HTTPS (443) from anywhere, and all outbound traffic.
4. **EC2 instance** running Ubuntu on a `t3.micro`, with a 20 GB `gp3` root volume that is deleted when the instance is terminated. It is tagged `Name=Terraform-Ubuntu-Host` and `Environment=Dev`.

**Files**

| File | Contents |
|---|---|
| [terraform.tf](automate-ec2-instance-creation/terraform.tf) | Required provider (`hashicorp/aws ~> 6.0`) and the AWS region (`us-west-2`) |
| [variables.tf](automate-ec2-instance-creation/variables.tf) | Input variables with defaults |
| [create_ec2_instance.tf](automate-ec2-instance-creation/create_ec2_instance.tf) | Key pair, default VPC, security group and EC2 instance |
| [output.tf](automate-ec2-instance-creation/output.tf) | Values printed after apply |

**Requirements**
- Terraform installed (`terraform version` to check).
- AWS credentials configured, for example with `aws configure`.
- An SSH key pair at `~/.ssh/terraform_key_pair` and `~/.ssh/terraform_key_pair.pub`. Create it with:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/terraform_key_pair
```

**Usage**
```bash
cd automate-ec2-instance-creation

terraform init      # download the AWS provider
terraform plan      # preview the resources that will be created
terraform apply     # create them (type "yes" to confirm)
terraform output    # show the instance ID, IPs and DNS name

# connect to the instance (Ubuntu AMIs use the "ubuntu" user)
ssh -i ~/.ssh/terraform_key_pair ubuntu@$(terraform output -raw ec2_instance_public_ip)

terraform destroy   # remove everything when you are done
```

**Variables**

Override any of these with `-var`, for example `terraform apply -var="ec2_instance_type=t3.small"`, or in a `terraform.tfvars` file.

| Variable | Default | Description |
|---|---|---|
| `ec2_image` | `ami-03a23d9d58ea08615` | AMI ID (Ubuntu, valid in `us-west-2`) |
| `ec2_instance_type` | `t3.micro` | Instance type |
| `storage_size` | `20` | Root volume size in GB |
| `volume_type` | `gp3` | Root volume type |
| `key_pair_name` | `terraform_key_pair` | Name of the AWS key pair |
| `security_group_name` | `terraform_security_group` | Name of the security group |
| `ssh_port` | `22` | SSH port opened in the security group |
| `http_port` | `80` | HTTP port opened in the security group |
| `https_port` | `443` | HTTPS port opened in the security group |
| `protocol` | `tcp` | Protocol for the inbound rules |

**Outputs**

| Output | Description |
|---|---|
| `ec2_instance_id` | ID of the EC2 instance |
| `ec2_instance_public_ip` | Public IP address |
| `ec2_instance_private_ip` | Private IP address inside the VPC |
| `ec2_instance_public_dns` | Public DNS name |

**Notes**
- AMI IDs are region-specific. If you change the region in `terraform.tf`, update `ec2_image` to an Ubuntu AMI from that region.
- SSH is open to `0.0.0.0/0` for simplicity. For anything beyond practice, restrict it to your own IP.
- The `t3.micro` instance type is Free Tier eligible in most accounts. Run `terraform destroy` afterwards to avoid charges.
- Terraform state (`terraform.tfstate`) and the `.terraform/` provider folder are generated locally and should not be committed.
