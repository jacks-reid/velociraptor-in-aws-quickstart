# main.tf
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "velociraptor-aws-vpc"
  cidr = "10.0.0.0/16"

  azs            = [var.aws_az]
  public_subnets = ["10.0.3.0/24"]
}

# Server configuration
module "velociraptor_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "velociraptor-server"

  ami                    = var.server_ami
  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_name
  monitoring             = true
  vpc_security_group_ids = [module.velociraptor_server_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
}

module "velociraptor_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "velociraptor-server-sg"
  description = "Security group for access to the Velociraptor server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 1
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 1
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

# Client configuration
module "velociraptor_client" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "velociraptor-client"

  ami                    = var.client_ami
  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_name
  monitoring             = true
  vpc_security_group_ids = [module.velociraptor_client_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
}

module "velociraptor_client_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "velociraptor-client-sg"
  description = "Security group for access to the Velociraptor client"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 1
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 1
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

module "key_pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  key_name           = "velociraptor-key-pair"
  create_private_key = true
}
