# aws-elastic-wordpress-evolution
Advanced Demo - Web App - Single Server to Elastic Evolution

## Requirements
1. Git
2. AWS Account
3. Git

## Steps to deploy the infrastructure
```bash 
git golne project repo url
cd aws-elastic-wordpress-evolution
terraform init
terraform plan
terraform apply -auto-approve
```



## Simple definition of the architecture

“This architecture is an elastic WordPress platform built on AWS. The network foundation is a VPC with subnets across multiple Availability Zones. Traffic enters through an Application Load Balancer, which forwards requests only to healthy EC2 instances. Those EC2 instances are launched from a launch template and managed by an Auto Scaling Group. WordPress stores its database content in Amazon RDS and its shared media content in Amazon EFS. Security Groups, IAM roles, and Systems Manager Parameter Store handle access control and configuration.” ([AWS Documentation][2])

## Component by component: definition, use, and importance

### 1) VPC, subnets, route tables, and internet access

“A VPC is your private network in AWS. Inside it, you create subnets, and each subnet lives in a single Availability Zone. Public subnets are used for internet-facing components like a load balancer, while private subnets are preferred for protected resources like application servers and databases. Route tables decide where traffic goes, and an internet gateway allows public subnets to talk to the internet. In production, private app subnets usually reach the internet through NAT gateways rather than being public themselves.” ([AWS Documentation][2])

### 2) Application Load Balancer

“An Application Load Balancer, or ALB, is the front door of the application. It accepts HTTP or HTTPS traffic from users and routes requests to targets such as EC2 instances. It continuously checks target health and only sends traffic to healthy instances. That gives us both resilience and cleaner failure handling, because unhealthy servers are automatically skipped.” ([AWS Documentation][3])

### 3) Target Group and health checks

“The target group is where the ALB keeps the list of registered application instances. The health check tells AWS what path and port to test, and a target must pass those health checks before it can receive traffic. This is important because it prevents the load balancer from sending users to broken servers.” ([AWS Documentation][4])

### 4) Launch Template

“A launch template is the blueprint for new EC2 instances. It stores settings like the AMI, instance type, security groups, IAM instance profile, and user data script. This matters because the web server becomes replaceable: if a server dies, AWS can launch another one from the same template with the same configuration.” ([AWS Documentation][5])

### 5) Auto Scaling Group

“An Auto Scaling Group, or ASG, maintains the desired number of EC2 instances. It can launch new instances, terminate failed instances, and respond to load changes. When Elastic Load Balancing health checks are enabled, the ASG can replace targets that the load balancer reports as unhealthy. That is a major reason this design is self-healing.” ([AWS Documentation][6])

### 6) EC2 instances running WordPress

“The EC2 instances are the compute layer. They run Apache, PHP, and WordPress. In this pattern, the instances should be treated as disposable. We do not want important state trapped on a single server, because that would break scaling and recovery.” ([GitHub][7])

### 7) Amazon RDS for MySQL

“Amazon RDS is the managed relational database service that stores WordPress relational data such as posts, users, comments, and settings. A DB subnet group places the database into selected VPC subnets, and subnet groups must cover at least two Availability Zones. For true high availability, RDS Multi-AZ maintains a synchronous standby in another Availability Zone and can fail over automatically during disruptions.” ([AWS Documentation][8])

### 8) Amazon EFS

“Amazon EFS is the shared file storage layer. In the WordPress pattern, it is ideal for `wp-content`, which holds uploads, media, and theme assets. EFS can have a mount target in each Availability Zone you want to use, and all the web servers can mount the same file system. That means one instance can be replaced without losing shared media content.” ([GitHub][9])

### 9) Security Groups

“Security Groups are virtual firewalls. They control which inbound and outbound traffic is allowed. A secure design uses least privilege: the load balancer security group allows web traffic from the internet, the WordPress security group allows port 80 only from the load balancer security group, the database security group allows 3306 only from WordPress, and the EFS security group allows 2049 only from WordPress.” ([AWS Documentation][10])

### 10) IAM role and instance profile

“An IAM role for EC2 gives the instance temporary permissions without hardcoding access keys. The instance profile is the container that passes that role to the EC2 instance at launch. This is how the server can securely call AWS APIs, such as reading Parameter Store values or using Session Manager.” ([AWS Documentation][11])

### 11) Systems Manager Parameter Store

“Parameter Store is used for configuration and secrets. Regular values can be stored as String parameters, and sensitive values such as database passwords can be stored as SecureString parameters, which use AWS KMS for encryption. This is important because it keeps secrets out of the script and out of the AMI.” ([AWS Documentation][12])

## Manual build steps in AWS Console

Read this part slowly like you are teaching a lab.

### Step 1: Create the VPC

“First, create a custom VPC. Give it a CIDR block large enough for all the subnets you need. The VPC is the private network boundary for the whole application.” ([AWS Documentation][2])

### Step 2: Create the subnets

“Next, create subnets across three Availability Zones. In this pattern, I would create three public subnets for the load balancer and NAT gateways, three app subnets for the WordPress servers, and three database subnets for RDS. A subnet belongs to one Availability Zone only, so spreading them across zones gives us fault tolerance.” ([AWS Documentation][2])

### Step 3: Add internet access

“Create an internet gateway and attach it to the VPC. Then create a public route table and add a default route to the internet gateway. Associate the public subnets with that route table. That is what makes them public.” ([AWS Documentation][13])

### Step 4: For a production-style design, add NAT gateways

“If the application instances live in private app subnets, create a public NAT gateway in each Availability Zone and point the app subnet route tables to the NAT gateway in the same zone. That lets private instances download packages and updates without being directly reachable from the internet, and AWS recommends one NAT gateway per Availability Zone for resiliency.” ([AWS Documentation][14])

### Step 5: Create the security groups

“Create four security groups. One for the ALB, allowing inbound HTTP or HTTPS from the internet. One for WordPress, allowing inbound HTTP only from the ALB security group. One for RDS, allowing MySQL on port 3306 only from the WordPress security group. And one for EFS, allowing NFS on port 2049 only from the WordPress security group.” ([AWS Documentation][10])

### Step 6: Create the DB subnet group and RDS instance

“Open RDS and create a DB subnet group using the database subnets in at least two Availability Zones. Then create a MySQL RDS instance in that subnet group, make it not publicly accessible, and attach the database security group. If you want to call this highly available in a production sense, enable Multi-AZ so AWS keeps a synchronous standby in another Availability Zone.” ([AWS Documentation][15])

### Step 7: Create the EFS file system

“Open EFS and create a regional file system. Then add one mount target in each Availability Zone where the application servers will run, using the EFS security group. This gives all WordPress servers shared access to the same `wp-content` data.” ([AWS Documentation][16])

### Step 8: Create the IAM role and instance profile

“Create an IAM role for EC2 and then create or use an instance profile to pass that role to launched instances. If you want Session Manager, attach `AmazonSSMManagedInstanceCore`. If the bootstrap script reads Parameter Store, also allow `ssm:GetParameter` or `ssm:GetParameters`, and if you read encrypted values, allow `kms:Decrypt` for the SecureString key.” ([AWS Documentation][11])

### Step 9: Create Systems Manager parameters

“Create the application configuration in Parameter Store. Store the database name, database user, RDS endpoint, EFS file system ID, and ALB DNS name as String parameters. Store the database password as a SecureString parameter. That way the instance reads configuration at boot instead of hardcoding secrets into the launch template.” ([AWS Documentation][12])

### Step 10: Create the launch template

“Open EC2 and create a launch template. Put in the AMI, instance type, security group, IAM instance profile, and the user data script that installs Apache, PHP, WordPress, mounts EFS, reads the Parameter Store values, and writes the WordPress config file. The launch template becomes the standard build definition for every app server.” ([AWS Documentation][5])

### Step 11: Create the target group

“Create an instance target group on port 80. Set the health check path to `/` or to a more specific application path if you want a tighter health signal. Remember that the target must pass health checks before the load balancer will send traffic to it.” ([AWS Documentation][4])

### Step 12: Create the Application Load Balancer

“Create an internet-facing Application Load Balancer in at least two public subnets, ideally across all the Availability Zones you are using. Attach the load balancer security group, then add a listener on port 80 or 443 and forward that listener to the target group.” ([AWS Documentation][17])

### Step 13: Create the Auto Scaling Group

“Create the Auto Scaling Group from the launch template. Place the instances in the app subnets, attach the target group, enable ELB health checks, and set the desired, minimum, and maximum capacity. That gives you self-healing and the ability to scale the web tier out or in.” ([AWS Documentation][6])

### Step 14: Test and complete WordPress setup

“Once the target shows healthy, open the ALB DNS name in the browser. The load balancer routes the request to a healthy EC2 instance, WordPress talks to RDS for structured data, and shared media lives on EFS. At that point you can complete the WordPress setup screen.” ([AWS Documentation][3])

## How all the components work together

“When a user opens the site, the DNS name of the ALB is the entry point. The ALB receives the HTTP request and forwards it to a healthy WordPress instance in the target group. That EC2 instance runs the PHP application, reads and writes relational content in RDS, and reads and writes shared media in EFS. If one application server fails, the ALB stops sending traffic to it, and the Auto Scaling Group launches a replacement from the launch template. Because the database and shared content are not stored locally on the instance, the failed server can be replaced without losing the application state that matters.” ([AWS Documentation][3])

## Resilience, security, and reliability

### Resilience

“This design is resilient because the load balancer spans multiple Availability Zones, the Auto Scaling Group can replace unhealthy instances, and EFS can be mounted from multiple Availability Zones. For the database layer, the architecture becomes truly highly available when RDS is configured as Multi-AZ with automatic failover.” ([AWS Documentation][18])

### Security

“This design is secure when we follow least privilege. The ALB is the only internet-facing entry point. WordPress instances should live in private subnets, not accept traffic directly from the internet, and only accept traffic from the ALB security group. The database accepts traffic only from the application security group, and secrets such as the DB password are stored in Parameter Store as SecureString rather than hardcoded.” ([AWS Documentation][19])

### Reliability

“This design is reliable because health checks are continuous, failed instances are replaced, configuration is standardized in a launch template, and the stateful parts of the system are handled by managed services. The result is a platform where the app servers are interchangeable and recovery is automated.” ([AWS Documentation][20])

## Conclusion

“So the big lesson is this: high availability is not just about adding more servers. It is about separating responsibilities. The load balancer handles traffic distribution, the Auto Scaling Group handles replacement and elasticity, RDS handles durable relational data, EFS handles shared file content, and IAM plus Parameter Store handle secure access and configuration. Once you separate those concerns, the application becomes far easier to scale, secure, and recover.” ([AWS Documentation][3])



[1]: https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE1%20-%20Setup%20and%20Manual%20wordpress%20build.md?utm_source=chatgpt.com "Setup and Manual wordpress build.md at master · acantril ..."
[2]: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html?utm_source=chatgpt.com "What is Amazon VPC? - Amazon Virtual Private Cloud"
[3]: https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html?utm_source=chatgpt.com "How Elastic Load Balancing works"
[4]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html?utm_source=chatgpt.com "Target groups for your Application Load Balancers"
[5]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-launch-template.html?utm_source=chatgpt.com "Create an Amazon EC2 launch template"
[6]: https://docs.aws.amazon.com/autoscaling/ec2/userguide/health-checks-overview.html?utm_source=chatgpt.com "About the health checks for your Auto Scaling group"
[7]: https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE2%20-%20Automate%20the%20build%20using%20a%20Launch%20Template.md?utm_source=chatgpt.com "STAGE2 - Automate the build using a Launch Template.md"
[8]: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html?utm_source=chatgpt.com "Working with a DB instance in a VPC - AWS Documentation"
[9]: https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE4%20-%20Add%20EFS%20and%20Update%20the%20LT.md?utm_source=chatgpt.com "Add EFS and Update the LT.md at master · acantril/learn- ..."
[10]: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html?utm_source=chatgpt.com "Control traffic to your AWS resources using security groups"
[11]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html?utm_source=chatgpt.com "IAM roles for Amazon EC2 - Amazon Elastic Compute Cloud"
[12]: https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html?utm_source=chatgpt.com "AWS Systems Manager Parameter Store"
[13]: https://docs.aws.amazon.com/vpc/latest/userguide/working-with-igw.html?utm_source=chatgpt.com "Add internet access to a subnet - Amazon Virtual Private Cloud"
[14]: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html?utm_source=chatgpt.com "NAT gateways - Amazon Virtual Private Cloud"
[15]: https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-rds-dbsubnetgroup.html?utm_source=chatgpt.com "AWS::RDS::DBSubnetGroup - AWS CloudFormation"
[16]: https://docs.aws.amazon.com/efs/latest/ug/accessing-fs.html?utm_source=chatgpt.com "Managing mount targets - Amazon Elastic File System"
[17]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-application-load-balancer.html?utm_source=chatgpt.com "Create an Application Load Balancer - AWS Documentation"
[18]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html?utm_source=chatgpt.com "Application Load Balancers"
[19]: https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html?utm_source=chatgpt.com "Subnets for your VPC - Amazon Virtual Private Cloud"
[20]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html?utm_source=chatgpt.com "Health checks for Application Load Balancer target groups"
