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
