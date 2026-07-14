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

resource "aws_vpc_endpoint" "vpc-endpoint-dkr" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids  = [var.endpoint-security]

  tags = {
    Name = "dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "vpc-endpoint-api" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
  service_name = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids  = [var.endpoint-security]

  tags = {
    Name ="api-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [
    aws_route_table.private-route-table-a.id, 
    aws_route_table.private-route-table-b.id
  ]
}