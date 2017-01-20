/*******************************************************************************
 * Variables
 ******************************************************************************/

/* variable "pg_extension" {
  description = "Extension to postgres" // TODO extend to list
} */

variable "environment" {
  description = "The environment tag, e.g prod"
}

variable "vpc_id" {
  description = "The VPC ID to use"
}

variable "zone_id" {
  description = "The Route53 Zone ID where the DNS record will be created"
}

variable "access_from_security_groups" {
  description = "A list of security group IDs that can access the rds"
  type = "list"
}

variable "subnet_ids" {
  description = "A list of subnet IDs"
  type = "list"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
}

variable "name-db-instance" {
  description = "The database name"
}

variable "username" {
  description = "The master user username"
}

variable "password" {
  description = "The master user password"
}

variable "engine" {
  description = "The database engine"
  default     = "mysql"
}

variable "instance_type" {
  description = "The type of instance"
  default     = "db.r3.large"
}

variable "preferred_backup_window" {
  description = "The time window on which backups will be made (HH:mm-HH:mm)"
  default     = "07:00-09:00"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  default = false
}

variable "backup_retention_period" {
  description = "The backup retention period"
  default     = 5
}

variable "publicly_accessible" {
  description = "When set to true the RDS instance can be reached from outside the VPC"
  default     = false
}

variable "dns_name" {
  description = "Route53 record name for the RDS database, defaults to the database name if not set"
  default     = ""
}

variable "multi_az" {
  default = "true or false flag for multi availability zone"
}

variable "port" {
  description = "The port at which the database listens for incoming connections"
  default     = 3306
}

variable "final_snapshot_identifier" {
  default = "when done experimenting set this var, to make snapshots when deleting instance"
  default = ""
}

/*******************************************************************************
 * Ressources
 ******************************************************************************/
resource "aws_security_group" "main" {
  name        = "${var.name-db-instance}-rds-instance"
  description = "Allows traffic to rds from other security groups"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = "${var.port}"
    to_port         = "${var.port}"
    protocol        = "TCP"
    security_groups = ["${var.access_from_security_groups}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "RDS instance (${var.name-db-instance})"
    Environment = "${var.environment}"
  }
}

resource "aws_db_subnet_group" "main" {
  name        = "${var.name-db-instance}"
  description = "RDS instance subnet group"
  subnet_ids  = ["${var.subnet_ids}"]
}

resource "aws_db_instance" "main" {
  allocated_storage       = "${var.allocated_storage}"
  multi_az                = "${var.multi_az}"
  backup_retention_period = "${var.backup_retention_period}"
  backup_window           = "${var.preferred_backup_window}"
  db_subnet_group_name    = "${aws_db_subnet_group.main.id}"
  engine                  = "${var.engine}"
  instance_class          = "${var.instance_type}"
  name                    = "${var.name-db-instance}"
  username                = "${var.username}"
  password                = "${var.password}"
  publicly_accessible     = "${var.publicly_accessible}"
  vpc_security_group_ids  = ["${aws_security_group.main.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.main.id}"
  port                    = "${var.port}"
  final_snapshot_identifier = "${var.final_snapshot_identifier}"

}

/* resource "postgresql_extension" "my_extension" {
  name = "${var.pg_extension}"
} */


resource "aws_route53_record" "main" {
  zone_id = "${var.zone_id}"
  name    = "${coalesce(var.dns_name, var.name-db-instance)}"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_db_instance.main.endpoint}"]
}

/*******************************************************************************
 * Outputs
 ******************************************************************************/

// The instance identifier.
output "id" {
  value = "${aws_db_instance.main.id}"
}

output "endpoint" {
  value = "${aws_db_instance.main.endpoint}"
}

output "fqdn" {
  value = "${aws_route53_record.main.fqdn}"
}

output "port" {
  value = "${aws_db_instance.main.port}"
}
