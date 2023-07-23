

resource "aws_ecr_repository" "terraform_ecr_repository" {
  encryption_configuration {
#tfsec:ignore:aws-ecr-repository-customer-key
    encryption_type = var.encryption_type
  }

  image_scanning_configuration {
    scan_on_push = "true"
  }

  image_tag_mutability = "IMMUTABLE"
  name                 = "${terraform.workspace}-${var.repository_name}"
}

resource "aws_ecr_lifecycle_policy" "terraform_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.terraform_ecr_repository.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}