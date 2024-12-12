# DEFINE ALL YOUR VARIABLES HERE

instance_type = "t2.medium"
ami           = "ami-0e2c8caa4b6378d8c"   # Ubuntu 24.04
key_name      = "Virginia-key"                # Replace with your key-name without .pem extension
volume_size   = 20
region_name   = "us-east-1"
server_name   = "JENKINS-SERVER"

# Note: 
# a. First create a pem-key manually from the AWS console
# b. Copy it in the same directory as your terraform code
