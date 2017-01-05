variable "environment" {
  description = "The environment tag, e.g prod"
}

variable "cluster_id" {
	 description = "(Required) Group identifier. ElastiCache converts this name to lowercase"
}

variable "engine" {
	 description = "Required Name of the cache engine to be used for this cache cluster. Valid values for this parameter are memcached or redis"
	 default = "redis"
}

variable "engine_version" {
	 description = "Optional Version number of the cache engine to be used. See Selecting a Cache Engine and Version in the AWS Documentation center for supported versions"
	 default = ""
}

variable "maintenance_window" {
   	description = "(Optional) Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:0"
	 default = ""
}

variable "node_type" {
	 description = "Required The compute and memory capacity of the nodes. See Available Cache Node Types for supported node types"
}

variable "num_cache_nodes" {
	 description = "Required The initial number of cache nodes that the cache cluster will have. For Redis, this value must be 1. For Memcache, this value must be between 1 and 20. If this number is reduced on subsequent runs, the highest numbered nodes will be removed."
	 default=1
}

variable "parameter_group_name" {
	 description = "Required Name of the parameter group to associate with this cache cluster"
	 default = "default.redis2.8"
}

variable "port" {
	 description = "Required The port number on which each of the cache nodes will accept connections. For Memcache the default is 11211, and for Redis the default port is 6379."
	 default = 6379
}

variable subnet_group_name {
	 description = "Optional, VPC only Name of the subnet group to be used for the cache cluster."
	 default = ""
}

variable security_group_names {
	 description = "Optional, EC2 Classic only List of security group names to associate with this cache cluster"	 
	 default = ""
}

variable "security_group_ids" {
	 description =" Optional, VPC only One or more VPC security groups associated with the cache cluster"
	 default = ""
}

variable "apply_immediately" {
	 description = "Optional Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is false. See Amazon ElastiCache Documentation for more information. Available since v0.6.0"
	 default = ""
}

variable "snapshot_arns" {
	 description = "Optional A single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3. Example: arn:aws:s3:::my_bucket/snapshot1.rdb"
	 default = ""
}

variable "snapshot_name" {
	 description = "Optional The name of a snapshot from which to restore data into the new node group. Changing the snapshot_name forces a new resource."
	 default = ""
}

variable "snapshot_window" {
	 description = "Optional, Redis onl The daily time range in UTC during which ElastiCache will begin taking a daily snapshot of your cache cluster. Example: 05:00-09:00"
	 default = ""
}

variable "snapshot_retention_limit" {
	 description = "Optional, Redis only The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted. If the value of SnapshotRetentionLimit is set to zero 0, backups are turned off. Please note that setting a snapshot_retention_limit is not supported on cache.t1.micro or cache.t2.* cache nodes"
	 default = ""
}

variable "notification_topic_arn" {
	 description = "Optional An Amazon Resource Name ARN of an SNS topic to send ElastiCache notifications to. Example: arn:aws:sns:us-east-1:012345678999:my_sns_topic"
	 default = ""
}

variable "az_mode" {
	 description = "Optional, Memcached only Specifies whether the nodes in this Memcached node group are created in a single Availability Zone or created across multiple Availability Zones in the cluster's region. Valid values for this parameter are single-az or cross-az, default is single-az. If you want to choose cross-az, num_cache_nodes must be greater than 1"
	 default = ""
}

variable "availability_zone" {
	 description = "Optional The Availability Zone for the cache cluster. If you want to create cache nodes in multi-az, use availability_zones"
	 default = ""
}

variable "availability_zones" {
	 description = "Optional, Memcached only List of Availability Zones in which the cache nodes will be created. If you want to create cache nodes in single-az, use availability_zone"
	 default = ""
}

variable "tags" {
	 description = "Optional A mapping of tags to assign to the resource"
	 default = ""
}



resource "aws_elasticache_cluster" "bar" {
    apply_immediately = "false"
    cluster_id = "redis-cluster-example-id"

    engine = "${var.engine}"
    port = "${var.port}"
    num_cache_nodes = "${var.num_cache_nodes}"
    parameter_group_name = "${var.parameter_group_name}"

    node_type = "cache.t2.micro"

    tags {
    	 Name        = "Elasticache cluster (${var.cluster_id})"
    	 Environment = "${var.environment}"
    }

}
