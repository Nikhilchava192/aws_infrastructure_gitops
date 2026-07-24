# 1. Application Load Balancer
resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "web" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# 2. Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 3. Launch Template (With Demo App User-Data Script)
resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Get EC2 metadata for unique identity per instance
              TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
              AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

              cat <<HTML > /var/www/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                  <title>GitOps Infrastructure Demo</title>
                  <style>
                      body { font-family: Arial, sans-serif; background-color: #1a202c; color: #fff; text-align: center; padding-top: 50px; }
                      .card { background-color: #2d3748; display: inline-block; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.3); }
                      h1 { color: #48bb78; }
                  </style>
              </head>
              <body>
                  <div class="card">
                      <h1>Deployment Successful!</h1>
                      <p>Provisioned automatically via <strong>GitLab CI/CD & Terraform</strong>.</p>
                      <hr>
                      <p><strong>Served by Instance ID:</strong> $INSTANCE_ID</p>
                      <p><strong>Availability Zone:</strong> $AZ</p>
                  </div>
              </body>
              </html>
              HTML
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# 4. Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = var.private_subnets
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"

  min_size     = 2
  max_size     = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-ec2-app"
    propagate_at_launch = true
  }
}