# Definimos el contenido de la política de seguridad.
data "aws_iam_policy_document" "secrets_manager_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.db_conn_secret.arn
    ]
  }

  depends_on = [
    aws_secretsmanager_secret.db_conn_secret
  ]
}

# Creamos la política de seguridad y le asociamos su contenido.
resource "aws_iam_policy" "db_conn_policy" {
  name        = var.resource_names.policy
  description = "Webapp database config retrieving"
  policy      = data.aws_iam_policy_document.secrets_manager_policy.json
}

# Definimos el contenido del rol.
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

# Creamos el rol y le asociamos su contenido.
resource "aws_iam_role" "db_conn_role" {
  name               = var.resource_names.role
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name = var.resource_names.role
  }
}

# Asociamos la política de seguridad al rol.
resource "aws_iam_policy_attachment" "db_conn_policy_role_assoc" {
  name = "db_conn"
  roles = [
    aws_iam_role.db_conn_role.id
  ]
  policy_arn = aws_iam_policy.db_conn_policy.arn
  depends_on = [
    aws_iam_role.db_conn_role,
    aws_iam_policy.db_conn_policy
  ]
}