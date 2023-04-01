terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.61.0"
    }
  }

  backend "s3" {
    bucket         = "turman-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    # dynamodb_table = "my-terraform-lock-table"
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "app" {
  ami           = "ami-00ad2436e75246bba"
  instance_type = "t2.micro"

  tags = {
    Name = "MyWebAPI"
  }

  key_name               = "mykey"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow inbound traffic for the application"

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


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "null_resource" "install_dotnet" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("mykey.pem")
    host        = aws_instance.app.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm",
      "sudo yum install -y aspnetcore-runtime-6.0"
    ]
  }
}

output "instance_ip" {
  value = aws_instance.app.public_ip
  description = "Public IP address of the EC2 instance"
}
