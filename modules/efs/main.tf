# modules/efs/main.tf

resource "aws_efs_file_system" "this" {
  creation_token = "${var.environment}-efs"
  encrypted      = true

  tags = {
    Name        = "${var.environment}-efs"
    Environment = var.environment
  }
}

resource "aws_security_group" "efs" {
  name        = "${var.environment}-efs-sg"
  description = "Allow EFS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-efs-sg"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}




