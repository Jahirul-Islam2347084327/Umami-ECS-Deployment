resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "umami-vpc"
  }
}

resource "aws_subnet" "public-subnet-a" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.main.id
  availability_zone = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public-subnet-b" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.main.id
  availability_zone = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "private-subnet-a" {
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.main.id
  availability_zone = var.az1
  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private-subnet-b" {
  cidr_block = "10.0.4.0/24"
  vpc_id = aws_vpc.main.id
  availability_zone = var.az2
   tags = {
    Name = "private-subnet-b"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private-route-table-a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-a.id
  }
  tags = {
    Name = "private-route-table-a"
  }
}

resource "aws_route_table" "private-route-table-b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-b.id
  }
  tags = {
    Name = "private-route-table-b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet-gateway"
  }
}

#resource "aws_network_acl" "main" {
 # vpc_id = aws_vpc.main.id
  #ingress{
   # protocol = "tcp"
    #from_port = 443
   # to_port = 443
   # action = "allow"
   # cidr_block = "0.0.0.0/0"
   # rule_no = 100
  #}
  #ingress{
  #  protocol = "tcp"
  #  from_port = 80
  #  to_port = 80
  #  action = "allow"
  #  cidr_block = "0.0.0.0/0"
   # rule_no = 110
 # }
  #egress{
  #  protocol = "tcp"
  #  from_port = 1024
  #  to_port = 65535
  #  action = "allow"
  #  cidr_block = "0.0.0.0/0"
  #}
  #tags = {
  #  Name = "network-acl"
  #}
#}

resource "aws_eip" "nat-ip-a" {
  domain = "vpc"

  tags = {
    Name ="elsatic-ip-a"
  }
}

resource "aws_eip" "nat-ip-b" {
  domain = "vpc"

  tags = {
    Name ="elsatic-ip-b"
  }
}

resource "aws_nat_gateway" "nat-a" {
  subnet_id = aws_subnet.public-subnet-a.id
  allocation_id = aws_eip.nat-ip-a.id
  tags = {
    Name = "nat-gateway-a"
  }
}


resource "aws_nat_gateway" "nat-b" {
  subnet_id = aws_subnet.public-subnet-b.id
  allocation_id = aws_eip.nat-ip-b.id
  tags = {
    Name = "nat-gateway-b"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-b" {
   subnet_id = aws_subnet.public-subnet-b.id
   route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-a" {
  subnet_id = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private-route-table-a.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id = aws_subnet.private-subnet-b.id
  route_table_id = aws_route_table.private-route-table-b.id
}