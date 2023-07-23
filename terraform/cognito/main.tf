resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.user_pool_name}-${var.env}"
  auto_verified_attributes = [
    "email",
  ]

  mfa_configuration = "OFF"

  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_message = " ユーザー名は {username}、仮パスワードは {####} です。"
      email_subject = " 仮パスワード"
      sms_message   = " ユーザー名は {username}、仮パスワードは {####} です。"
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
    #email_sending_account = "SES"
  }

  password_policy {
    minimum_length                   = 16
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
  }

  username_configuration {
    case_sensitive = true
    #case_sensitive = false
  }

  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_message         = " 検証コードは {####} です。"
    email_message_by_link = " E メールアドレスを検証するには、次のリンクをクリックしてください。{##Verify Email##} "
    email_subject         = " 検証コード"
    email_subject_by_link = " 検証リンク"
    #sms_message           = " 検証コードは {####} です。"
  }

  tags = {
    Env = "${var.env}"
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  #allowed_oauth_flows                  = []
  #allowed_oauth_flows_user_pool_client = false
  #allowed_oauth_scopes                 = []
  #callback_urls                        = []

  explicit_auth_flows = [
    # 更新トークン(新しいアクセストークンを取得するのに必要。)
    "ALLOW_REFRESH_TOKEN_AUTH",
    # SRPプロトコルを使用してユーザー名&パスワードを検証する。
    "ALLOW_USER_SRP_AUTH",
  ]
  logout_urls                   = []
  name                          = "${var.user_pool_name}-${var.env}"
  prevent_user_existence_errors = "ENABLED"

  # 属性の読み取り有無設定。
  read_attributes = [
    "address",
    "email",
    "email_verified",
    "name",
    "updated_at",
  ]
  # 更新トークンの期限
  refresh_token_validity       = 30
  supported_identity_providers = []
  user_pool_id                 = aws_cognito_user_pool.user_pool.id

  # 属性の書き有無設定。
  write_attributes = [
    "address",
    "email",
    "email_verified",
    "name",
    "updated_at",
  ]
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name = "${var.identity_pool_name}_${var.env}"

  allow_unauthenticated_identities = false

  openid_connect_provider_arns = []
  saml_provider_arns           = []
  supported_login_providers    = {}
  tags                         = {}

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.user_pool_client.id
    provider_name           = "cognito-idp.ap-northeast-1.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
    server_side_token_check = false
  }
}