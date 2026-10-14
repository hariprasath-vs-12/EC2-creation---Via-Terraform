variable "aws_region" {
  description = "AWS region (ap-south-2 = Hyderabad)"
  type        = string
  default     = "ap-south-2"
}

variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
  default     = "portfolio"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets (one per availability zone)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDRs."
  }
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (must exist in the chosen region)"
  type        = string
  default     = "ami-0199ac7c9fbf9ed83"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an EXISTING EC2 key pair in the chosen region"
  type        = string
  default     = "ec2"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 8
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH (port 22). Restrict this to your own IP, e.g. 203.0.113.10/32"
  type        = string
  default     = "0.0.0.0/0"
}
