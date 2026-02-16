resource "aws_cloudwatch_dashboard" "operations" {
  dashboard_name = "operations-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1: CPU Utilization Line Chart
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "CPUUtilization", { stat = "Average", label = "CPU %" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        x      = 0
        y      = 0
        width  = 12
        height = 6
      },
      
      # Widget 2: Memory Utilization Line Chart
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "MemoryUtilization", { stat = "Average", label = "Memory %" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Memory Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        x      = 12
        y      = 0
        width  = 12
        height = 6
      },
      
      # Widget 3: Disk Utilization Line Chart
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "DiskUtilization", { stat = "Average", label = "Disk %" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Disk Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        x      = 0
        y      = 6
        width  = 8
        height = 6
      },
      
      # Widget 4: Network Throughput
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "NetworkThroughput", { stat = "Average", label = "Network MB/s" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Network Throughput"
        }
        x      = 8
        y      = 6
        width  = 8
        height = 6
      },
      
      # Widget 5: Request Count
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "RequestCount", { stat = "Sum", label = "Requests" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Request Count"
        }
        x      = 16
        y      = 6
        width  = 8
        height = 6
      },
      
      # Widget 6: Error Count
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Logs", "ErrorCountFromLogs", { stat = "Sum", label = "Errors" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Error Count"
        }
        x      = 0
        y      = 12
        width  = 12
        height = 6
      },
      
      # Widget 7: API Response Time
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Logs", "APIResponseTime", { stat = "Average", label = "Latency (ms)" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "API Response Time"
        }
        x      = 12
        y      = 12
        width  = 12
        height = 6
      },
      
      # Widget 8: Database Connections
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "DatabaseConnections", { stat = "Average", label = "DB Connections" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Database Connections"
        }
        x      = 0
        y      = 18
        width  = 8
        height = 6
      },
      
      # Widget 9: Cache Hit Rate
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "CacheHitRate", { stat = "Average", label = "Cache Hit %" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Cache Hit Rate"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
        x      = 8
        y      = 18
        width  = 8
        height = 6
      },
      
      # Widget 10: Queue Depth
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "QueueDepth", { stat = "Maximum", label = "Queue Depth" }]
          ]
          period = 300
          stat   = "Maximum"
          region = "us-east-1"
          title  = "Queue Depth"
        }
        x      = 16
        y      = 18
        width  = 8
        height = 6
      },
      
      # Widget 11: Number Widget - Current CPU
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "CPUUtilization", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Current CPU"
          view   = "singleValue"
        }
        x      = 0
        y      = 24
        width  = 6
        height = 3
      },
      
      # Widget 12: Number Widget - Current Memory
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "MemoryUtilization", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Current Memory"
          view   = "singleValue"
        }
        x      = 6
        y      = 24
        width  = 6
        height = 3
      },
      
      # Widget 13: Number Widget - Total Errors
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Logs", "ErrorCountFromLogs", { stat = "Sum" }]
          ]
          period = 3600
          stat   = "Sum"
          region = "us-east-1"
          title  = "Errors (Last Hour)"
          view   = "singleValue"
        }
        x      = 12
        y      = 24
        width  = 6
        height = 3
      },
      
      # Widget 14: Number Widget - Total Requests
      {
        type = "metric"
        properties = {
          metrics = [
            ["MyApp/Metrics", "RequestCount", { stat = "Sum" }]
          ]
          period = 3600
          stat   = "Sum"
          region = "us-east-1"
          title  = "Requests (Last Hour)"
          view   = "singleValue"
        }
        x      = 18
        y      = 24
        width  = 6
        height = 3
      },
      
      # Widget 15: Alarm Status Widget
      {
        type = "alarm"
        properties = {
          title  = "Alarm Status"
          alarms = [
            "arn:aws:cloudwatch:us-east-1:000000000000:alarm:high-cpu-utilization",
            "arn:aws:cloudwatch:us-east-1:000000000000:alarm:high-memory-utilization",
            "arn:aws:cloudwatch:us-east-1:000000000000:alarm:high-error-count",
            "arn:aws:cloudwatch:us-east-1:000000000000:alarm:high-api-latency"
          ]
        }
        x      = 0
        y      = 27
        width  = 12
        height = 6
      },
      
      # Widget 16: Log Insights Widget
      {
        type = "log"
        properties = {
          query   = "SOURCE '/aws/application/myapp' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
          region  = "us-east-1"
          title   = "Recent Errors"
        }
        x      = 12
        y      = 27
        width  = 12
        height = 6
      }
    ]
  })

}
