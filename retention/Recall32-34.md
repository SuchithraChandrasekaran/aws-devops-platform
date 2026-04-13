# Days 32 to 34 Command Recall

---

## Day 32 - Create custom SSM Automation documents (runbooks) for common tasks

```bash
# Create SSM Automation document - restart app
aws --endpoint-url=http://localhost:4566 ssm create-document \
  --name "RestartApp" \
  --document-type "Automation" \
  --content '{
    "schemaVersion": "0.3",
    "description": "Restart the application on EC2",
    "parameters": { "InstanceId": { "type": "String" } },
    "mainSteps": [
      {
        "name": "StopInstance",
        "action": "aws:changeInstanceState",
        "inputs": { "InstanceIds": ["{{ InstanceId }}"], "DesiredState": "stopped" }
      },
      {
        "name": "StartInstance",
        "action": "aws:changeInstanceState",
        "inputs": { "InstanceIds": ["{{ InstanceId }}"], "DesiredState": "running" }
      }
    ]
  }'

# Create SSM Command document - run shell script
aws --endpoint-url=http://localhost:4566 ssm create-document \
  --name "RunHealthCheck" \
  --document-type "Command" \
  --content '{
    "schemaVersion": "2.2",
    "description": "Run health check on instance",
    "mainSteps": [{
      "action": "aws:runShellScript",
      "name": "healthCheck",
      "inputs": { "runCommand": ["curl -f http://localhost:3000 || echo UNHEALTHY"] }
    }]
  }'

# Execute automation document
aws --endpoint-url=http://localhost:4566 ssm start-automation-execution \
  --document-name "RestartApp" \
  --parameters InstanceId=i-1234567890

# Run command on instance
aws --endpoint-url=http://localhost:4566 ssm send-command \
  --instance-ids i-1234567890 \
  --document-name "RunHealthCheck"

# Check execution status
aws --endpoint-url=http://localhost:4566 ssm describe-automation-executions

# List your documents
aws --endpoint-url=http://localhost:4566 ssm list-documents \
  --filters Key=Owner,Values=Self
```

---

## Day 33 - Build Step Functions workflow for complex orchestration and DR procedures

```json
// state-machine.json
{
  "Comment": "DR Procedure: backup, failover, verify",
  "StartAt": "TakeBackup",
  "States": {
    "TakeBackup": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:000000000000:function:backup-verify",
      "Next": "CheckBackupStatus",
      "Catch": [{ "ErrorEquals": ["States.ALL"], "Next": "NotifyFailure" }]
    },
    "CheckBackupStatus": {
      "Type": "Choice",
      "Choices": [{
        "Variable": "$.backupStatus",
        "StringEquals": "SUCCESS",
        "Next": "StartFailover"
      }],
      "Default": "NotifyFailure"
    },
    "StartFailover": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:000000000000:function:auto-stop-resources",
      "Next": "WaitForFailover"
    },
    "WaitForFailover": {
      "Type": "Wait",
      "Seconds": 30,
      "Next": "VerifyHealth"
    },
    "VerifyHealth": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:000000000000:function:health-check",
      "Next": "NotifySuccess"
    },
    "NotifySuccess": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "arn:aws:sns:us-east-1:000000000000:my-alerts",
        "Message": "DR completed successfully"
      },
      "End": true
    },
    "NotifyFailure": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "arn:aws:sns:us-east-1:000000000000:my-alerts",
        "Message": "DR procedure FAILED"
      },
      "End": true
    }
  }
}
```

```bash
# Create state machine
aws --endpoint-url=http://localhost:4566 stepfunctions create-state-machine \
  --name "DRProcedure" \
  --definition file://state-machine.json \
  --role-arn arn:aws:iam::000000000000:role/myapp-ec2-role

# Start execution
aws --endpoint-url=http://localhost:4566 stepfunctions start-execution \
  --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:DRProcedure \
  --input '{"trigger": "manual"}'

# Check execution status
aws --endpoint-url=http://localhost:4566 stepfunctions list-executions \
  --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:DRProcedure

# Get execution history
aws --endpoint-url=http://localhost:4566 stepfunctions get-execution-history \
  --execution-arn <execution-arn>
```

---

## Day 34 - Implement fan-out pattern with SNS/SQS, dead letter queues

```bash
# Create SNS topic (fan-out source)
aws --endpoint-url=http://localhost:4566 sns create-topic --name app-events

# Create 3 SQS queues
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name orders-queue
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name notifications-queue
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name analytics-queue

# Create Dead Letter Queue
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name orders-dlq

# Attach DLQ to orders-queue (max 3 retries)
aws --endpoint-url=http://localhost:4566 sqs set-queue-attributes \
  --queue-url http://localhost:4566/000000000000/orders-queue \
  --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:us-east-1:000000000000:orders-dlq\",\"maxReceiveCount\":\"3\"}"}'

# Subscribe all 3 queues to SNS
aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:app-events \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:us-east-1:000000000000:orders-queue

aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:app-events \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:us-east-1:000000000000:notifications-queue

aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:app-events \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:us-east-1:000000000000:analytics-queue

# Publish message - fans out to all 3 queues
aws --endpoint-url=http://localhost:4566 sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:app-events \
  --message '{"event": "order_placed", "orderId": "123"}'

# Verify messages in each queue
aws --endpoint-url=http://localhost:4566 sqs receive-message \
  --queue-url http://localhost:4566/000000000000/orders-queue

aws --endpoint-url=http://localhost:4566 sqs receive-message \
  --queue-url http://localhost:4566/000000000000/notifications-queue

# Check DLQ for failed messages
aws --endpoint-url=http://localhost:4566 sqs receive-message \
  --queue-url http://localhost:4566/000000000000/orders-dlq

# Queue message count
aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes \
  --queue-url http://localhost:4566/000000000000/orders-queue \
  --attribute-names ApproximateNumberOfMessages
```

---
