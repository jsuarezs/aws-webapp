data "aws_iam_policy_document" "secrets_manager_policy" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.default.arn]
  }
}
resource "aws_iam_policy" "db_conn_policy" {
  name        = "iam-pol"
  description = "Webapp database config retrieving"
  policy      = data.aws_iam_policy_document.secrets_manager_policy.json
}
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "db_conn_role" {
  name               = "ec2role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
resource "aws_iam_policy_attachment" "db_conn_policy_role_assoc" {
  name       = "db_conn"
  roles      = [aws_iam_role.db_conn_role.id]
  policy_arn = aws_iam_policy.db_conn_policy.arn
}
resource "aws_iam_instance_profile" "test_instance_profile" {
  name = "test_instance_profile"
  role = aws_iam_role.db_conn_role.name
}