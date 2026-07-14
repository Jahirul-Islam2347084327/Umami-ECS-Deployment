variable "az1" {
  type = string
  description = "availibilty zone for the first set of public and private subnet"
}

variable "az2" {
  type = string
  description = "availibilty zone for the second set of public and private subnet"
}

variable "region" {
  type = string
}

variable "endpoint-security" {
  type = string
}