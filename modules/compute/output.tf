output "alb_dns_name" {
  value       = aws_lb.web.dns_name
  description = "Public URL to access the deployed demo application"
}