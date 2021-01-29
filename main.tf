# source ./awsCredentials.sh
# terraform init 
# terraform validate
# terraform plan
# terraform apply --auto-approve
# terraform destroy


# chmod 400 danilons-keypair.pem
# ssh -i "danilons-keypair.pem" ec2-user@ec2-3-15-227-248.us-east-2.compute.amazonaws.com


# Credentials must be available as enviroment variable. 
# See awsCredentials.sh
provider "aws" {}

# resource: aws_security_group (EC2), resource name: ssh_security_group
resource "aws_security_group" "ssh_security_group" {
  name        = "danilons_ciandtVpn"
  description = "Allow SSH"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [
      "187.19.15.32/29",
      "200.186.98.240/29",
      "177.185.2.136/29"]
    protocol    = "tcp"
  }

  ingress {
    description = "Application"
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [
      "187.19.15.32/29",
      "200.186.98.240/29",
      "177.185.2.136/29"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "danilons_ciandtVpn"
  }
}

# resource: aws_instance (EC2), resource name: danilons_techlab
resource "aws_instance" "danilons_terraform_techlab2" {  
  ami = "ami-0a0ad6b70e61be944" # Image to deploy: Amazon Linux 2 AMI
  instance_type = "t2.micro" 
  key_name = "danilons-keypair"

  security_groups = [
    "${aws_security_group.ssh_security_group.name}"
  ]

  tags = {
    Name = "danilons_terraform_techlab2"
  }
  
}

# resource: aws_dynamodb_table, resource name: danilons_techlab
resource "aws_dynamodb_table" "danilons_terraform_techlab2" {
  name           = "danilons_terraform_techlab2"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"  

  attribute {
    name = "id"
    type = "S"
  }
  
}

output "instance_ip" {
  value = "${aws_instance.danilons_terraform_techlab2.public_ip}"
}
