

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Vpc-Insurance"
  }
}
# resource "aws_network_acl" "default" {
#   vpc_id = aws_vpc.main.id

#   # ingress {
#   #   protocol   = -1
#   #   rule_no    = 100
#   #   action     = "allow"
#   #   cidr_block = "0.0.0.0/0"
#   #   from_port  = 0
#   #   to_port    = 0
#   # }
#    ingress {
#     protocol   = -1
#     rule_no    = 99
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }
#   ingress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "10.0.0.0/16"
#     from_port  = 80
#     to_port    = 80
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "10.0.0.0/16"
#     from_port  = 3306
#     to_port    = 3306
#   }

#     ingress {
#     protocol   = "tcp"
#     rule_no    = 300
#     action     = "allow"
#     cidr_block = "10.0.0.0/16"
#     from_port  = 22
#     to_port    = 22
#   }

#     ingress {
#     protocol   = "icmp"
#     rule_no    = 400
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#     ingress {
#     protocol   = "tcp"
#     rule_no    = 500
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 32768
#     to_port    = 65535
#   }

#   egress {
#     protocol   = -1
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }
#     egress {
#     protocol   = -1
#     rule_no    = 99
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }
# }
# Create Public Subnet
resource "aws_subnet" "public_subnet1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public-Subnet1"
  }
}
# Create Public Subnet
resource "aws_subnet" "public_subnet2b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public-Subnet2"
  }
}

# Create Private Subnet
resource "aws_subnet" "private_subnet1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private-Subnet1"
  }
}
# Create Private Subnet
resource "aws_subnet" "private_subnet1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-Subnet2"
  }
}
# Create Private Subnet
resource "aws_subnet" "private_subnet2a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private-Subnet3"
  }
}
# Create Private Subnet
resource "aws_subnet" "private_subnet2b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-Subnet4"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Internet-Gateway"
  }
}

# Creating EIP
resource "aws_eip" "nat_gateway" {
  vpc = true
}
# Creating EIP
resource "aws_eip" "nat_gateway1" {
  vpc = true
}

# Creating NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet1a.id

  tags = {
    Name = "gw NAT"
  }
}
# Creating NAT Gateway
resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_gateway1.id
  subnet_id     = aws_subnet.public_subnet2b.id

  tags = {
    Name = "gw NAT1"
  }
}


# Creating Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public-route-Table"
  }
}

# Creating Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id

  }
  tags = {
    Name = "Private-route-Table"
  }
}
# Creating Private Route Table
resource "aws_route_table" "private_route_table1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway1.id

  }
  tags = {
    Name = "Private-route-Table1"
  }
}




# Route Table association with Public Subnet
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet1a.id
  route_table_id = aws_route_table.public_route_table.id
}
# Route Table association with Public Subnet
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet2b.id
  route_table_id = aws_route_table.public_route_table.id
}


# Route Table association with Private Subnet
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_subnet1a.id
  route_table_id = aws_route_table.private_route_table1.id
}
# Route Table association with Private Subnet
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_subnet1b.id
  route_table_id = aws_route_table.private_route_table1.id
}
# Route Table association with Private Subnet
resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private_subnet2a.id
  route_table_id = aws_route_table.private_route_table.id
}
# Route Table association with Private Subnet
resource "aws_route_table_association" "private4" {
  subnet_id      = aws_subnet.private_subnet2b.id
  route_table_id = aws_route_table.private_route_table.id
}

# resource "aws_network_acl_association" "main" {
#   network_acl_id = aws_network_acl.default.id
#   subnet_id      = aws_subnet.public_subnet1a.id
# }
# resource "aws_network_acl_association" "main1" {
#   network_acl_id = aws_network_acl.default.id
#   subnet_id      = aws_subnet.public_subnet2b.id
# }
# resource "aws_network_acl_association" "main2" {
#   network_acl_id = aws_network_acl.default.id
#   subnet_id      = aws_subnet.private_subnet1a.id
# }
# resource "aws_network_acl_association" "main3" {
#   network_acl_id = aws_network_acl.default.id
#   subnet_id      = aws_subnet.private_subnet1b.id
# }
# resource "aws_network_acl_association" "main4" {
#   network_acl_id = aws_network_acl.default.id
#   subnet_id      = aws_subnet.private_subnet2a.id
# }
# resource "aws_network_acl_association" "main5" {
#   network_acl_id = aws_network_acl.default.id
#   subnet_id      = aws_subnet.private_subnet2b.id
# }

