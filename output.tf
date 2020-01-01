output "this_db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.this_db_instance_address
}

output "this_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this_db_instance_arn
}

output "this_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.this_db_instance_endpoint
}

output "this_db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this_db_instance_id
}

output "this_db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.this_db_instance_resource_id
}

output "this_db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.this_db_instance_status
}

output "this_db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.this_db_instance_name
}

output "this_db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.this_db_instance_username
}

output "db.password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = aws_db_instance.demodb-orcl.db.password
}

output "this_db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this_db_instance_port
}