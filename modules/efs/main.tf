# modules/efs/main.tf

resource "aws_efs_file_system" "eks_efs" {
  creation_token = "eks-efs"
  encrypted      = true

  tags = {
    Name = "EKS-EFS"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS-SG"
  }
}

resource "aws_efs_mount_target" "efs_mt" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.eks_efs.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}