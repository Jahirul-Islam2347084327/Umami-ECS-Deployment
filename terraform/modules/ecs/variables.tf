variable "image-url" {
  type = string
}

variable "database-url" {
  type = string
}

variable "private-subnet-ids" {
  type = list(string)
}

variable "ecs-security-group-id" {
  type = list(string)
}

variable "target-group-arn" {
  type = string
}