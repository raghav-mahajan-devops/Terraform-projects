# Terraform Projects

A collection of Infrastructure as Code (IaC) projects written with Terraform. They provision resources on AWS using the official `hashicorp/aws` provider.

| Project | Folder | Purpose |
|---|---|---|
| Automate EC2 instance creation | [automate-ec2-instance-creation](automate-ec2-instance-creation) | Creates a key pair, a security group and an Ubuntu EC2 instance in the default VPC |
| Automate multi-instance EC2 creation | [automate-ec2-multi-instace-creation](automate-ec2-multi-instace-creation) | Creates two Ubuntu EC2 instances running nginx with `for_each`, and keeps the state file in S3 |
| S3 backend resources | [backend_s3](backend_s3) | Creates the S3 bucket that holds remote state and the DynamoDB table used for state locking |
| VPC using a registry module | [create_vpc_using_inbuilt_module](create_vpc_using_inbuilt_module) | Creates a two-AZ VPC with public and private subnets using the `terraform-aws-modules/vpc/aws` module |

Each folder is a separate Terraform project with its own state. The only dependency between them is that [backend_s3](backend_s3) must be applied before [automate-ec2-multi-instace-creation](automate-ec2-multi-instace-creation), because that project stores its state in the bucket and locks it with the table.

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

## 2. automate-ec2-multi-instace-creation

Provisions two Ubuntu web servers from a single resource block using `for_each`. Each instance installs nginx on first boot, and the Terraform state is stored remotely in S3.

**What it creates**
1. **Key pair** named `terraform-key-pair-multi-instance`, built from your local public key at `~/.ssh/terraform-key-pair-multi-instance.pub`.
2. **Default VPC** is adopted into Terraform so the other resources can reference it. Terraform does not create or delete it.
3. **Security group** named `multi-instance-sg` that allows inbound SSH (22), HTTP (80) and HTTPS (443) from anywhere, and all outbound traffic.
4. **Two EC2 instances**, `instance-1` (`t3.micro`) and `instance-2` (`t3.small`), each with an 8 GB `gp2` root volume that is deleted when the instance is terminated. [nginx.sh](automate-ec2-multi-instace-creation/nginx.sh) runs as user data to install, start and enable nginx.

**Files**

| File | Contents |
|---|---|
| [terraform.tf](automate-ec2-multi-instace-creation/terraform.tf) | Required provider (`hashicorp/aws ~> 6.0`), the S3 backend and the AWS region (`us-west-2`) |
| [variables.tf](automate-ec2-multi-instace-creation/variables.tf) | Input variables with defaults |
| [multi-ec2.tf](automate-ec2-multi-instace-creation/multi-ec2.tf) | Key pair, default VPC, security group and EC2 instances |
| [nginx.sh](automate-ec2-multi-instace-creation/nginx.sh) | User data script that installs nginx |
| [output.tf](automate-ec2-multi-instace-creation/output.tf) | Values printed after apply |

**Requirements**
- Terraform installed and AWS credentials configured, as in project 1.
- The S3 bucket and DynamoDB table from [backend_s3](backend_s3) must exist before you run `terraform init` here.
- An SSH key pair at `~/.ssh/terraform-key-pair-multi-instance` and `~/.ssh/terraform-key-pair-multi-instance.pub`. Create it with:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/terraform-key-pair-multi-instance
```

**Usage**
```bash
cd automate-ec2-multi-instace-creation

terraform init      # connect to the S3 backend and download the AWS provider
terraform plan      # preview the resources that will be created
terraform apply     # create them (type "yes" to confirm)
terraform output    # show the public IPs and DNS names of both instances

# check nginx, using an IP from the output (allow a minute or two for it to install)
curl http://<public_ip>

# connect to an instance (Ubuntu AMIs use the "ubuntu" user)
ssh -i ~/.ssh/terraform-key-pair-multi-instance ubuntu@<public_ip>

terraform destroy   # remove everything when you are done
```

**Variables**

Variable names are spelled as they appear in [variables.tf](automate-ec2-multi-instace-creation/variables.tf), including `instace_type` and `instace_name`.

| Variable | Default | Description |
|---|---|---|
| `image` | `ami-03a23d9d58ea08615` | AMI ID (Ubuntu, valid in `us-west-2`) |
| `instace_name` | `["instance-1", "instance-2"]` | Instance names, used as the `for_each` keys and the `Name` tag |
| `instace_type` | `["t3.micro", "t3.small"]` | Instance types, matched to `instace_name` by position |
| `key_pair_name` | `terraform-key-pair-multi-instance` | Name of the AWS key pair |
| `security_group_name` | `multi-instance-sg` | Name of the security group |
| `ssh_port` | `22` | SSH port opened in the security group |
| `http_port` | `80` | HTTP port opened in the security group |
| `https_port` | `443` | HTTPS port opened in the security group |
| `protocol` | `tcp` | Protocol for the inbound rules |
| `environment` | `["dev", "prod"]` | Declared but not used by any resource yet |

**Outputs**

| Output | Description |
|---|---|
| `dns_name` | List of public DNS names, one per instance |
| `public_ip` | List of public IP addresses, one per instance |

**Notes**
- The `for_each` map in [multi-ec2.tf](automate-ec2-multi-instace-creation/multi-ec2.tf) reads indexes `0` and `1` only, so adding a third item to the variable lists does not create a third instance.
- The state file is stored at `automate-ec2-multi-instance/terraform.tfstate` in the `terraform-bucket-multi-instance` bucket. The `dynamodb_table` setting in the backend block turns on state locking: Terraform holds a lock in `multi-instance-lock-table` during an operation, so two applies cannot run at the same time.
- AMI IDs are region-specific. The `us-west-2` region is set in both `terraform.tf` and the `aws_instance` resource, so change both if you move regions, and update `image` to match.
- `t3.small` is not Free Tier eligible. Run `terraform destroy` afterwards to avoid charges.

## 3. backend_s3

Creates the AWS resources that remote state depends on. Apply this project first, since it has to exist before another project can use it as a backend. Its own state stays local.

**What it creates**
1. **S3 bucket** named `terraform-bucket-multi-instance`, used by project 2 to store its state file.
2. **DynamoDB table** named `multi-instance-lock-table`, used by project 2 for state locking, with on-demand (`PAY_PER_REQUEST`) billing and a string hash key called `LockID`.

**Files**

| File | Contents |
|---|---|
| [terraform.tf](backend_s3/terraform.tf) | Required provider (`hashicorp/aws ~> 6.0`) and the AWS region (`us-west-2`) |
| [variable.tf](backend_s3/variable.tf) | Input variables with defaults |
| [bucket.tf](backend_s3/bucket.tf) | S3 bucket |
| [dynamoDB.tf](backend_s3/dynamoDB.tf) | DynamoDB table |

**Usage**
```bash
cd backend_s3

terraform init      # download the AWS provider
terraform plan      # preview the resources that will be created
terraform apply     # create them (type "yes" to confirm)
```

**Variables**

| Variable | Default | Description |
|---|---|---|
| `bucket_name` | `terraform-bucket-multi-instance` | Name of the S3 bucket |
| `dynamodb_table_name` | `multi-instance-lock-table` | Name of the DynamoDB table |
| `dynamodb_table_hash_key` | `LockID` | Hash key of the table |
| `dynamodb_table_attribute_name` | `LockID` | Attribute that defines the hash key |
| `dynamodb_table_billing_mode` | `PAY_PER_REQUEST` | Billing mode of the table |

**Notes**
- Terraform requires the hash key to be named exactly `LockID`, so keep that spelling if you override these variables.
- If you rename the table, update `dynamodb_table` in project 2's [terraform.tf](automate-ec2-multi-instace-creation/terraform.tf) to match.
- Newer Terraform versions mark the `dynamodb_table` backend setting as deprecated in favour of `use_lockfile`, so expect a warning. Locking through the table still works.
- S3 bucket names are globally unique. If you deploy this in another account, change `bucket_name` and the `bucket` value in project 2's [terraform.tf](automate-ec2-multi-instace-creation/terraform.tf) to the same new name.
- Destroy this project last. The bucket has no `force_destroy` setting, so `terraform destroy` fails until the bucket is empty.

## 4. create_vpc_using_inbuilt_module

Builds a VPC from the public [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) registry module instead of writing each networking resource by hand.

**What it creates**
1. **VPC** named `raghav-vpc` with the CIDR block `10.0.0.0/16`, tagged `Terraform=true` and `Environment=dev`.
2. **Public subnets** `10.0.101.0/24` and `10.0.102.0/24` in `us-west-2a` and `us-west-2b`.
3. **Private subnets** `10.0.1.0/24` and `10.0.2.0/24` in the same two availability zones.
4. **Internet gateway** and route tables for the subnets.
5. **Two NAT gateways**, one for each private subnet, each with an Elastic IP.
6. **VPN gateway** attached to the VPC.

**Files**

| File | Contents |
|---|---|
| [terraform.tf](create_vpc_using_inbuilt_module/terraform.tf) | Required provider (`hashicorp/aws ~> 6.0`) and the AWS region (`us-west-2`) |
| [vpc.tf](create_vpc_using_inbuilt_module/vpc.tf) | The `vpc` module block and its settings |

**Usage**
```bash
cd create_vpc_using_inbuilt_module

terraform init      # download the VPC module and the AWS provider
terraform plan      # preview the resources that will be created
terraform apply     # create them (type "yes" to confirm)

terraform destroy   # remove everything when you are done
```

**Notes**
- The availability zones in [vpc.tf](create_vpc_using_inbuilt_module/vpc.tf) must belong to the region in `terraform.tf`, so change both together.
- NAT gateways are billed by the hour and are not covered by the Free Tier, so run `terraform destroy` as soon as you finish. Setting `single_nat_gateway = true` in [vpc.tf](create_vpc_using_inbuilt_module/vpc.tf) reduces the count to one.
- The module has no `version` argument, so `terraform init` picks the latest release that fits the provider. Pin one with `version` to keep builds repeatable.
- All settings are written directly in [vpc.tf](create_vpc_using_inbuilt_module/vpc.tf). This project has no variables or outputs of its own.
