# kandula-mid-project-opsschool
Opsschool Mid Course project. Creates a VPC  with two availability zones, 
each one with two subnets, one public and one private. The public subnets contain a single NAT, a 
Jenkins master , and a Jenkins node on private subnet. 
Both Jenkins server and node are configured as Consul clients .   
The private subnets contain an EKS master and a worker group , one in each subnet, 
and also three Consul servers.   
Once the Jenkins is up and the required credentials are entered, you can configure a pipeline job to get the 
kandula app from git, i create 2 pipelien: 1.build docker image and push to docker hub
                                           2. create deployment.yaml and loadbalncer.ymal and deploay to EKS
                                           
                                           
# How it's work:
Provisioning is done by terraform, installation on the Jenkins master and node.
Once the Jenkins server is up, an SSH node is defined with credentials , Dockerhub and a git
SSH key are required, aws credentials (you will have to configure aws credentials in 3 secrettext (aws_access_key_id, aws_secret_access_key , aws_default_region) ).
you need to clone this reop as contian kandula app:
https://github.com/yossima066/kandula-project-app.git


# Requirements:
You will need a machine with the following installed on it to run the enviroment:
- AWS Account
- AWS CLI (for aws configure)
- terraform  
- git

# To run:
`terraform init`  
`terraform validate`  
`terraform plan -out midpro.tfplan`  
`terraform apply "midpro.tfplan`


# Jenkins:
Access Jenkins master:<public-ip>:8080

  
# Consul:
Access Consul ui: Load Balancer DNS hostname (will redirect to :8500/ui)


## To bring everything down:
Terraform may have issues bringing the eks load balancer down. To avoid these issues you get bring it down yourself with `kubectl delete svc lb` or by deleting the load balancer through the AWS console.  
Once the load-balancer is down,  run:  
`terraform destroy`






