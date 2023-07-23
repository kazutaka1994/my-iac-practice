output "ecr_url" {
  value = aws_ecr_repository.terraform_ecr_repository.repository_url
}