resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required? 1 : 0
  peer_vpc_id   = data.aws_vpc.default.id # Acceptor vpc id
  vpc_id        = aws_vpc.main.id # Requestor vpc id
  auto_accept   = true

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-default"
    }
  )
}

resource "aws_route" "public_peering" {      #Public Route info
  count = var.is_peering_required? 1 : 0
  route_table_id            = aws_route_table.public.id  
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "private_peering" {      #Private Route info
  count = var.is_peering_required? 1 : 0
  route_table_id            = aws_route_table.private.id  
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "database_peering" {      #database Route info
  count = var.is_peering_required? 1 : 0
  route_table_id            = aws_route_table.database.id  
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "default_peering" {      #Public Route info
  count = var.is_peering_required? 1 : 0
  route_table_id            = data.aws_route_table.main.route_table_id  
  destination_cidr_block    = var.cidr_block 
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id #vpc cidr
}