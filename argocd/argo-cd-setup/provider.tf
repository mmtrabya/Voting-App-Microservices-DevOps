data "aws_eks_cluster" "this" {
  name = "voting-app-sarah"
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

# OIDC provider (only once per cluster)
resource "aws_iam_openid_connect_provider" "eks" {
  url            = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
}

# IAM Role for EBS CSI Driver (using IRSA)
resource "aws_iam_role" "ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Attach the Amazon managed policy
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# Install the EBS CSI driver as an addon
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = data.aws_eks_cluster.this.name # Fixed reference
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.29.1-eksbuild.1" # Use the latest compatible version
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn


}


# Install the EBS CSI driver as an addon
# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name             = data.aws_eks_cluster.this.name
#   addon_name               = "aws-ebs-csi-driver"
#   service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
# }

# variable "eks_cluster_name" {
#   default = "this"
# }

# data "aws_eks_cluster" "this" {
#   name = var.eks_cluster_name
# }

# data "aws_eks_cluster_auth" "this" {
#   name = var.eks_cluster_name
# }


provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
