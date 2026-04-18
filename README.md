# A4L WordPress One-Click Terraform

This layout is a cleaned-up, Terraform-based version of the A4L/Cantrill **Web Application Architecture Evolution** demo.

## What it provisions
- A4L-style VPC and subnets
- Security groups
- IAM role and instance profile for EC2
- RDS MySQL
- EFS + mount targets
- Application Load Balancer + target group + listener
- Launch Template
- Auto Scaling Group
- CPU-based scale-out / scale-in alarms and policies
- SSM parameters used by the EC2 bootstrap script

## Why this version is different from the original files
The original files mixed multiple stages of the demo together:
- final-stage Terraform resources (RDS, EFS, ALB, ASG)
- earlier-stage user data that still bootstrapped a **local MariaDB**
- hardcoded endpoints / IDs in SSM instead of using Terraform outputs

This version aligns those pieces so `terraform apply` builds the final elastic WordPress stack in one run.

## Files
- `provider.tf`
- `variables.tf`
- `networking.tf`
- `security.tf`
- `iam.tf`
- `data.tf`
- `rds.tf`
- `efs.tf`
- `alb.tf`
- `ssm.tf`
- `launch_template.tf`
- `autoscaling.tf`
- `outputs.tf`
- `userdata.sh.tftpl`
- `terraform.tfvars.example`
- `deploy.sh`

## Usage
```bash
cp terraform.tfvars.example terraform.tfvars
# edit values if needed
terraform init
terraform plan
terraform apply -auto-approve
```

Or:
```bash
chmod +x deploy.sh
./deploy.sh
```

## Notes
- This keeps the **public-subnet ASG** behavior used in the demo video.
- The EC2 instances only allow HTTP from the ALB security group.
- The launch template uses a dynamic **Amazon Linux 2023** SSM public AMI parameter instead of a hardcoded AMI ID.
- User data is **app-only**: it does **not** install/start a local MariaDB.
