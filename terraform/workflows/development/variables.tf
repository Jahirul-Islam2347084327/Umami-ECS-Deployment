variable "az1" {
  type = string
  description = "availibilty zone for the first set of public and private subnet"
  default = "us-east-1a"
}

variable "az2" {
  type = string
  description = "availibilty zone for the second set of public and private subnet"
  default = "us-east-1b"
}