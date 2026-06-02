output "iam_role_arn" {
  description = "ARN of the ALB Controller IAM role"
  value       = aws_iam_role.alb_controller.arn
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.alb_controller.name
}

output "release_status" {
  description = "Helm release status"
  value       = helm_release.alb_controller.status
}
