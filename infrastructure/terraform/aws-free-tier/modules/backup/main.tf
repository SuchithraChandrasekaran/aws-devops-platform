# RDS backup configuration
# Applied to existing RDS instance via aws_db_instance in modules/rds/main.tf
# Documented here for reference

# Backup settings on aws-devops-db:
#   backup_retention_period = 7        (7 days automated backups)
#   backup_window           = "03:00-04:00"  (UTC)
#   maintenance_window      = "sun:04:00-sun:05:00"
#
# Manual snapshots:
#   Run scripts/backup/rds-snapshot.sh for on-demand snapshots
#   Retention: 7 days (cleanup handled by script)
#
# Point-in-time recovery:
#   Available for any second within backup_retention_period
#   Use: aws rds restore-db-instance-to-point-in-time
#
# Restore procedure:
#   Run scripts/backup/rds-restore-test.sh <snapshot-id>
#   Always restore to a NEW instance, never over live DB

variable "db_identifier" {
  type    = string
  default = "aws-devops-db"
}

output "backup_info" {
  value = {
    retention_days  = 7
    backup_window   = "03:00-04:00 UTC"
    snapshot_script = "scripts/backup/rds-snapshot.sh"
    restore_script  = "scripts/backup/rds-restore-test.sh"
  }
}
