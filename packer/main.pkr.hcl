// main.pkr.hcl
// export PKR_VAR_aws_access_key=$YOURKEY
variable "aws_access_key" {
  type = string
}

// export PKR_VAR_aws_secret_key=$YOURSECRETKEY
variable "aws_secret_key" {
  type = string
}

// export PKR_VAR_aws_region=$YOURREGION
variable "aws_region" {
  type = string
}

source "amazon-ebs" "velociraptor-server" {
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.aws_region
  source_ami    = "ami-09a41e26df464c548" # debian-11, free tier :)
  instance_type = "t2.micro"
  ssh_username  = "admin"
  ami_name      = "velociraptor-server-{{timestamp}}"
}

source "amazon-ebs" "velociraptor-client" {
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  region        = var.aws_region
  source_ami    = "ami-09a41e26df464c548" # debian-11, free tier :)
  instance_type = "t2.micro"
  ssh_username  = "admin"
  ami_name      = "velociraptor-client-{{timestamp}}"
}

build {
  sources = [
    "source.amazon-ebs.velociraptor-server",
    "source.amazon-ebs.velociraptor-client"
  ]
  provisioner "ansible" {
    playbook_file = "./server-playbook.yaml"
    only          = ["amazon-ebs.velociraptor-server"]
  }
  provisioner "ansible" {
    playbook_file = "./client-playbook.yaml"
    only          = ["amazon-ebs.velociraptor-client"]
  }
}
