resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    
 {
    Name = local.resource_name
  }

  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.ig_tags,

  {
    Name = local.resource_name
  } 

  )
}

resource "aws_subnet" "public" {
  count      = length(var.public_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,

  {
    Name = "${local.resource_name}-public-${local.az_names[count.index]}"
  }

  )

}

resource "aws_subnet" "private" {
  count      = length(var.private_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags

  {
    Name = "${local.resource_name}-private-${local.az_names[count.index]}"
  }

  )

}

resource "aws_subnet" "database" {
  count      = length(var.database_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags

  {
    Name = "${local.resource_name}-database-${local.az_names[count.index]}"
  }

  )

}


resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    var.db_subnetgroup_tags,
    {
      Name = local.resource_name
    }
  )
  
}

resource "aws_eip" "nat" {
  domain = "vpc"
}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
      Name = local.resource_name
    }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]      
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.aws_route_table_public_tags,
    {
      Name = "${local.resource_name}-public"  #expense-dev-public
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.aws_route_table_private_tags,
    {
      Name = "${local.resource_name}-private"  #expense-dev-private
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.aws_route_table_database_tags,
    {
      Name = "${local.resource_name}-database"  #expense-dev-database
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.main.id
}

resource "aws_route" "private_nat" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_nat_gateway.main.id
}


resource "aws_route" "database_nat" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public" {    # Associating route tables with public, private and database subnets
  count = length(var.public_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {    # Associating route tables with public, private and database subnets
  count = length(var.private_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {    # Associating route tables with public, private and database subnets
  count = length(var.database_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

