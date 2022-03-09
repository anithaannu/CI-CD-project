#terraform {
 #   required_version = ">= 0.12"
  #  backend "s3" {
   #     bucket = "terraform-statefiles-folder"
    #    key = "myapp/state.tfstate"
     #   region = "us-east-1"
   # }
#}

provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_instance" "Docker-Server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = "t2.micro" 
    key_name = "Ansible_new_key"
    security_groups = ["All_traffic_sg"]
    user_data = file("entry-script.sh")
    tags = {
        Name = "Docker Server by Terraform"
    }
}


output "ec2_public_ip" {
    value = aws_instance.Docker-Server.public_ip
}
