variable "alb-security-group-id" {
  type = string
}


variable "public-subnets-id" {
  type = list(string)
}

variable "vpc-id" {
  type = string
}
