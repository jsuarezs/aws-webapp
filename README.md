# aws-webapp
Deploying EC2, VPC, NAT, IG, RDS, ALB and ASG for webapp purposes.

**Author: Javier Suárez Sanz**


## What does it do?
   - Automated deployment of a WebApp as follows:
   
     * Use Hashicorp 3.51.0 version which is the latest one.
     * Use "terraform" as service account to use with Terraform (find "terraform.tfvars" in this repository).
     * IaC in Ireland (eu-west1-1) for this App to work.
          * VPC using 4 subnets for HA purposes: 2 private & 2 public.
            * Private subnets for BBDD servers and public subnets for web servers.
          * RDS MySQL database across two HA zones.
          * ALB to redirect the traffic between web instances.
          * WebApp is deploy using custom scripting to test the purpose of this scenario.
          * Instances are storing BBDD Secret using AWS Secret Manager feature.
          * Auto Scaling web server instances between EC2 instances.
            * Launch template to deploy ASG.
          * Route53 feature to use friendly DNS names.
     
## How to deploy it

* There's already the user terraform present in the Account so I've uploaded the Keys in terraform.tfvars in private mode in this repo so setting one directory with all tf files should work.

* Test it with: ````terraform validate````
* Plan the infrastructure: ````terraform plan````
* Deploy the infrastructure: ````terraform apply````
