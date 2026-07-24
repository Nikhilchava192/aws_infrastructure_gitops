output "application_url" {
  value       = "http://${module.compute.alb_dns_name}"
  description = "Open this URL in your web browser to check the demo app."
}