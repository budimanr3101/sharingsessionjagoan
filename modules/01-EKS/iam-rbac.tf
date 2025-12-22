# iam-rbac.tf (Versi Bersih)

# ======================
# IAM Assume Role Policy Document for IRSA
# ======================
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks-cluster.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    # --- DISESUAIKAN ---
    # Hanya mempercayai Service Account untuk infra.
    condition {
      test     = "StringEquals"
      variable = "${module.eks-cluster.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:infra-sa"]
    }
  }
  statement {
    sid    = "UserAssumeAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      # Mengizinkan semua user/role di akun ini untuk assume role.
      # Bisa diperketat jika perlu.
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",]
      # identifiers = [
      #   "arn:aws:iam::279370934872:user/MSI_Nabil",
      #   "arn:aws:iam::279370934872:user/MSI_Zahra"
      # ]
    }
    actions = ["sts:AssumeRole"]
  }
}

# ======================
# IAM Role and Policies untuk INFRA
# ======================
## INFRA IAM ROLE for Access Terrafrom & EKS CLUSTER With Assume ROLE #
resource "aws_iam_role" "infra_role" {
  name               = "eks-infra-access-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_policy" "infra_admin_policy" {
  name        = "eks-infra-access-policy"
  description = "Scoped EKS admin access policy for Infra IAM Role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EKSAccess",
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:AccessKubernetesApi",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup"
        ],
        Resource = module.eks-cluster.cluster_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "infra_attach_admin" {
  role       = aws_iam_role.infra_role.name
  policy_arn = aws_iam_policy.infra_admin_policy.arn
}

resource "aws_iam_role_policy_attachment" "infra_attach_AdministratorAccess_AWS" {
  # checkov:skip=CKV_AWS_274: for terraform apply access need administrator access
  role       = aws_iam_role.infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" ## for Terraform
}

# ======================
# Service Account (IRSA) untuk INFRA
# ======================
resource "kubernetes_service_account" "infra_sa" {
  # Variabel var.enable_rbac mungkin bisa dihapus jika ini selalu dibuat
  # count = var.enable_rbac ? 1 : 0

  metadata {
    name      = "infra-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.infra_role.arn
    }
  }
}

# ======================
# RBAC Binding untuk INFRA
# ======================
resource "kubernetes_cluster_role_binding" "infra_admin" {
  # count = var.enable_rbac ? 1 : 0

  metadata {
    name = "infra-admin-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "infra-sa"
    namespace = "kube-system"
  }
  depends_on = [kubernetes_service_account.infra_sa]
}