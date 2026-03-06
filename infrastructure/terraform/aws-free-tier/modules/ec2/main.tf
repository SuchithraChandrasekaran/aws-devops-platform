# Get latest Amazon Linux 2 AMI (free tier eligible)
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"   # FREE TIER - do not change
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker git
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user
    echo "Day 36 - instance ready" > /tmp/setup.log
  EOF

  tags = {
    Name        = "${var.project_name}-app"
    Environment = var.environment
    StopWhenDone = "true"
  }
}
