variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}


variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
    default = true
}

variable "common_tags" {
    default = {}

}

variable "ig_tags" {
    default = {}
}

variable "public_cidrs" {
    type = list

    validation {
        condition = length(var.public_cidrs) == 2
        error_message = "please enter valid cidr blocks of minimum 2"
    }

}

variable "public_subnet_tags" {
    default = {}
}

variable "private_cidrs" {
    type = list

    validation {
        condition = length(var.private_cidrs) == 2
        error_message = "please enter valid cidr blocks of minimum 2"
    }

}

variable "private_subnet_tags" {
    default = {}
}



variable "database_cidrs" {
    type = list

    validation {
        condition = length(var.database_cidrs) == 2
        error_message = "please enter valid cidr blocks of minimum 2"
    }

}

variable "db_subnetgroup_tags" {
    default = {}
}

variable "database_subnet_tags" {
    default = {}
}

variable "db_subnet_group_tags" {
    default = {}
}

variable "nat_gateway_tags" {
    default = {}
}

variable "aws_route_table_public_tags" {
    default = {}
}

variable "aws_route_table_private_tags" {
    default = {}
}

variable "aws_route_table_database_tags" {
    default = {}
}

variable "public_route_tags" {
    default = {}
}

variable "private_route_tags" {
    default = {}
}

variable "database_route_tags" {
    default = {}
}

variable "is_peering_required" {
    type = bool
    default = false
}


