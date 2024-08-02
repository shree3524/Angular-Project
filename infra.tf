resource  "aws_vpc" "vpc-1" {
    cidr_block = "192.168.0.0/16"
    tags = {
        Name = "vpc-1"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.vpc-1.id
    cidr_block = "192.168.0.0/24"
    availability_zone = "ap-southeast-2a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-Subnet"
    }
}

resource "aws_subnet" "public-fronted" {
    vpc_id = aws_vpc.vpc-1.id
    cidr_block = "192.168.1.0/24"
    availability_zone = "ap-southeast-2b"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-Subnet-fronted"
    }
}


resource "aws_subnet" "public-db" {
    vpc_id = aws_vpc.vpc-1.id
    cidr_block = "192.168.2.0/24"
    availability_zone = "ap-southeast-2c"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public-Subnet-Database"
    }
}

resource "aws_internet_gateway" "igw-demo" {

    vpc_id = aws_vpc.vpc-1.id
    tags = {
        Name = "igw-demo"
    }
}

resource "aws_route_table" "RT-public" {
    vpc_id = aws_vpc.vpc-1.id
    tags = {
        Name = "RT-public"
    }
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw-demo.id
    }
}


resource "aws_route_table_association" "rt-public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.RT-public.id
}

resource "aws_route_table_association" "rt-public1" {
    subnet_id = aws_subnet.public-fronted.id
    route_table_id = aws_route_table.RT-public.id

} 

resource "aws_route_table_association" "rt-public2" {
   subnet_id = aws_subnet.public-db.id
   route_table_id = aws_route_table.RT-public.id
}

resource "aws_security_group" "demo-sg" {
    name = "demo-sg"
    description = "allow ports to instance"
    vpc_id = aws_vpc.vpc-1.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
      ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

      ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
      ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
      egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "demo-sg"
    }
}


resource "aws_instance" "vm-backend" {
    ami = "ami-03f0544597f43a91d"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    key_name = "pin"
    
    tags = {
        Name = "backend-Instance"
    }
}


resource "aws_instance" "vm-db" {
    ami = "ami-03f0544597f43a91d"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public-db.id
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    key_name = "pin"
    
    tags = {
        Name = "Database-Instance"
    }
}

resource "aws_instance" "vm-fronted" {
    ami = "ami-03f0544597f43a91d"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public-fronted.id
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    key_name = "pin"
    
    tags = {
        Name = "fronted-Instance"
    }
}
resource "aws_db_subnet_group" "db-subnet" {
  name = "db-subnet"
  subnet_ids = [aws_subnet.public-fronted.id,aws_subnet.public-db.id]
}

resource "aws_db_instance" "rds" {
  allocated_storage = 20
  db_name = "database1"
  engine = "mariadb"
  engine_version = "10.11.6"
  username = "admin"
  password = "Passwd123$"
  instance_class = "db.t3.micro"
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.db-subnet.name

  vpc_security_group_ids = [aws_security_group.demo-sg.id]

  tags = {
    Name = "DB-Instance"
  }
}
