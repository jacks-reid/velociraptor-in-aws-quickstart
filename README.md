# Velociraptor in AWS Quickstart

Packer and Terraform code to quickly experiment with the [Velociraptor](https://github.com/Velocidex/velociraptor) IR tool

## Usage

```sh
# build AWS AMIs preconfigured with Velociraptor
cd packer
pip3 -m venv .venv
source .venv/bin/activate 
pip install ansible

# set your AWS access keys
export PKR_VAR_aws_access_key=ABC
export PKR_VAR_aws_secret_key=XYZ

# set your preferred AWS region
export PKR_VAR_aws_region=XYZ

# build the AMIs
packer build .

# save the AMI values created by Packer
export SERVER_AMI=$amazon-ebs.velociraptor-server
export CLIENT_AMI=$amazon-ebs.velociraptor-client

# apply the infrastructure
cd infra
terraform init
terraform apply -var aws_az=$YOUR_PREFERRED_AWS_AZ -var server_ami=$SERVER_AMI -var client_ami=$CLIENT_AMI # then enter yes

# keep your keys private
terraform output -raw private_key_pem > priv-key.pem
chmod 400 priv-key.pem

# get the server public IP
export SERVER_PUBLIC_IP=$(terraform output -raw server_public_ip)

# login to your server
ssh -i priv-key.pem admin@$SERVER_PUBLIC_IP

# create client configuration
sudo ./velociraptor --config server.config.yaml config client > client.config.yaml

# edit the configuration with the following
# Client:
#   server_urls:
#   - https://$SERVER_PRIVATE_IP:8000/
#   use_self_signed_ssl: true
exit

# download the client config to transfer to the VM
scp -i priv-key.pem admin@$SERVER_PUBLIC_IP:~/client.config.yaml .

# get the client public IP
export CLIENT_PUBLIC_IP=$(terraform output -raw client_public_ip)

# copy the client config file to the client VM
scp -i priv-key.pem client.config.yaml admin@$CLIENT_PUBLIC_IP:~/client.config.yaml

# start the client
ssh -i priv-key.pem admin@$CLIENT_PUBLIC_IP
sudo ./velociraptor --config client.config.yaml client -v

# in a separate tab, start a SSH tunnel to the web GUI
ssh -i priv-key.pem -L 8889:localhost:8889 admin@$SERVER_PUBLIC_IP
```

Visit https://localhost:8889 in your browser and login with `login:dogsandcats`. You will see an untrusted certificate error. You can type `thisisunsafe` to get pass the error.

Use the top search bar to see the client connected to your server. Use the "Hunts" feature to run investigations against your client. The `Linux.Syslog.SSHLogin` is a good artifact to start with -- you'll see some familiar logs.

## Clean up

AWS is not free! The resources created in this quickstart are not free. 

To delete the infrastructure provisioned by Terraform, use the following:

```sh
terraform destroy -var aws_az=$YOUR_PREFERRED_AWS_AZ -var server_ami=$SERVER_AMI -var client_ami=$CLIENT_AMI # then enter yes
```

To delete the AWS AMIs, first deregister the AMIs within the AWS console and then delete the snapshots that were backing those AMIs.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | n/a |
| <a name="module_velociraptor_client"></a> [velociraptor\_client](#module\_velociraptor\_client) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |
| <a name="module_velociraptor_client_sg"></a> [velociraptor\_client\_sg](#module\_velociraptor\_client\_sg) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_velociraptor_server"></a> [velociraptor\_server](#module\_velociraptor\_server) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |
| <a name="module_velociraptor_server_sg"></a> [velociraptor\_server\_sg](#module\_velociraptor\_server\_sg) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_az"></a> [aws\_az](#input\_aws\_az) | variables.tf | `any` | n/a | yes |
| <a name="input_client_ami"></a> [client\_ami](#input\_client\_ami) | n/a | `any` | n/a | yes |
| <a name="input_server_ami"></a> [server\_ami](#input\_server\_ami) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_public_ip"></a> [client\_public\_ip](#output\_client\_public\_ip) | n/a |
| <a name="output_private_key_pem"></a> [private\_key\_pem](#output\_private\_key\_pem) | outputs.tf |
| <a name="output_server_public_ip"></a> [server\_public\_ip](#output\_server\_public\_ip) | n/a |
