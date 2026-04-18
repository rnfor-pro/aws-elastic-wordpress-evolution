variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.16.0.0/16"
}

variable "snpubA" {
  type    = string
  default = "10.16.0.0/20"
}

variable "snpubB" {
  type    = string
  default = "10.16.64.0/20"
}

variable "snpubC" {
  type    = string
  default = "10.16.128.0/20"
}

variable "sndba" {
  type    = string
  default = "10.16.16.0/20"
}

variable "sndbB" {
  type    = string
  default = "10.16.80.0/20"
}

variable "sndbc" {
  type    = string
  default = "10.16.144.0/20"
}

variable "snappA" {
  type    = string
  default = "10.16.32.0/20"
}

variable "snappB" {
  type    = string
  default = "10.16.96.0/20"
}

variable "snappC" {
  type    = string
  default = "10.16.160.0/20"
}

variable "rt_pub_default_ipv4" {
  type    = string
  default = "0.0.0.0/0"
}

variable "db_name" {
  type    = string
  default = "a4lwordpressdb"
}

variable "db_user" {
  type    = string
  default = "a4lwordpressuser"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "4n1m4l54L1f3"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 3
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}
