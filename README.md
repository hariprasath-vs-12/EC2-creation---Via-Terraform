# Portfolio infrastructure (Terraform)

Terraform code that creates the AWS infrastructure for the portfolio website: a VPC with two public subnets and an Ubuntu EC2 instance running **nginx**.

The website code lives in a separate repo: <https://github.com/hariprasath-vs-12/portfolio>

## What it creates (region `ap-south-2`, Hyderabad)

| Resource | Details |
|---|---|
| VPC | `10.0.0.0/16`, DNS support and hostnames enabled |
| Internet gateway | Attached to the VPC |
| Public subnets | 2 subnets (`10.0.1.0/24`, `10.0.2.0/24`) in two different availability zones |
| Route table | `0.0.0.0/0` to the internet gateway, associated with both subnets |
| Security group | Inbound 80 and 443 from anywhere, 22 from `ssh_allowed_cidr`, all outbound |
| EC2 instance | `t3.micro`, Ubuntu AMI, 8 GB encrypted gp3 volume, key pair `ec2`, IMDSv2 required |

On first boot the instance runs `user_data.sh`: `apt update` and `upgrade`, installs nginx, unzip, curl and AWS CLI v2, and starts nginx.

## Files

```
.
├── providers.tf    Terraform and AWS provider versions, S3 backend
├── variables.tf    Inputs with defaults
├── main.tf         VPC, subnets, IGW, route table, security group, EC2
├── outputs.tf      VPC, subnet, security group and instance outputs
└── user_data.sh    Boot script for the instance (must keep LF line endings)
```

## Prerequisites

- Terraform 1.10 or newer (`terraform -version`)
- AWS CLI configured with credentials (`aws configure`, then `aws sts get-caller-identity`)
- An **S3 bucket for remote state**, created manually in `ap-south-2` with versioning and encryption on and public access blocked. Its name must match `bucket` in `providers.tf`
- An **EC2 key pair** named `ec2` in `ap-south-2` (key pairs are per region)
- The AMI in `variables.tf` must exist in `ap-south-2` and be x86_64

## Usage

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

After `apply`, Terraform prints `website_url` and `instance_public_ip`. Wait 1 to 3 minutes for the boot script to finish, then open the URL. You will see the default nginx page until the site is deployed.

Connect to the server:

```bash
ssh -i /path/to/ec2.pem ubuntu@<instance_public_ip>
```

Watch the boot script: `sudo tail -f /var/log/user-data.log`

### Deploy the website

On the server:

```bash
sudo git clone --depth 1 https://github.com/hariprasath-vs-12/portfolio.git /opt/portfolio-src
sudo bash /opt/portfolio-src/deploy/deploy.sh
```

### Destroy

```bash
terraform destroy
```

Run this when you are done testing, to stop the charges.

## Variables

| Name | Default | Description |
|---|---|---|
| `aws_region` | `ap-south-2` | AWS region |
| `project_name` | `portfolio` | Prefix for resource names and tags |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `public_subnet_cidrs` | `["10.0.1.0/24", "10.0.2.0/24"]` | Exactly two public subnet CIDRs |
| `ami_id` | `ami-0199ac7c9fbf9ed83` | Ubuntu AMI ID |
| `instance_type` | `t3.micro` | EC2 instance type |
| `key_name` | `ec2` | Existing EC2 key pair name |
| `root_volume_size` | `8` | Root volume size in GiB |
| `ssh_allowed_cidr` | `0.0.0.0/0` | CIDR allowed to SSH. Set this to your own IP, for example `203.0.113.10/32` |

To override values without editing code, create a `terraform.tfvars` file (it is git-ignored):

```hcl
ssh_allowed_cidr = "203.0.113.10/32"
```

## Notes

- **State:** stored in S3 (`portfolio/terraform.tfstate`) with native locking. Never commit `*.tfstate` files.
- **SSH:** port 22 is open to the internet by default. Restrict `ssh_allowed_cidr` to your IP.
- **Cost:** a `t3.micro` and its public IPv4 address are billed outside the free tier.
- **Single instance:** this is one server in one availability zone. To add an Application Load Balancer, use the two public subnets and the security group outputs, and register a second instance in the other availability zone.
- **Line endings:** `user_data.sh` must use LF. Windows CRLF endings make the boot script fail on Ubuntu. The included `.gitattributes` enforces LF.
