packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws"
  instance_type = "t2.micro"
  region        = "us-east-1"
  subnet_id     = "subnet-"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = [""]
  }
  ssh_username = "ubuntu"
}




build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
      inline = [
        "sudo amazon-linux-extras install nginx",
        "sudo systemctl start nginx",
        "sudo systemctl enable nginx",
      ]
    }

}