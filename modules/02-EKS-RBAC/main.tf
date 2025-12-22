# modules/02-EKS-RBAC/main.tf (Versi Final dengan Dukungan Namespace dan Cluster)

# =========================================================================
#  1. Pembuatan IAM Role dan EKS Access Entry (Tidak Berubah)
# =========================================================================
locals {
  unique_principals = { for def in var.rbac_eks : def.principal_name => def }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "HumanUserAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
  }
}

resource "aws_iam_role" "this" {
  for_each           = local.unique_principals
  name               = format("%s%s%s", var.role_name_prefix, each.key, var.role_name_suffix)
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_eks_access_entry" "this" {
  for_each          = aws_iam_role.this
  cluster_name      = var.cluster_name
  principal_arn     = each.value.arn
  type              = "STANDARD"
  kubernetes_groups = [each.value.name]
}

# =========================================================================
#  2. Logika untuk Memisahkan Definisi Berdasarkan Scope
# =========================================================================
locals {
  # Filter definisi yang memiliki scope "namespace"
  namespace_assignments = {
    for item in flatten([
      for definition in var.rbac_eks : [
        for namespace in (definition.scope == "namespace" ? definition.namespaces : []) : {
          principal_name    = definition.principal_name
          principal_group_name = aws_iam_role.this[definition.principal_name].name
          role_name         = definition.role_name
          namespace         = namespace
          rules             = definition.rules
          key               = format("%s-%s-%s", definition.principal_name, definition.role_name, namespace)
        }
      ]
    ]) : item.key => item
  }

  # Filter definisi yang memiliki scope "cluster"
  cluster_assignments = {
    for definition in var.rbac_eks :
    format("%s-%s", definition.principal_name, definition.role_name) => {
      principal_name    = definition.principal_name
      principal_group_name = aws_iam_role.this[definition.principal_name].name
      role_name         = definition.role_name
      rules             = definition.rules
    } if definition.scope == "cluster"
  }
}

# =========================================================================
#  3. Resource untuk Scope "NAMESPACE" (Role dan RoleBinding)
# =========================================================================
resource "kubernetes_role" "this" {
  for_each = local.namespace_assignments
  metadata {
    name      = each.value.role_name
    namespace = each.value.namespace
  }
  dynamic "rule" {
    for_each = each.value.rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_role_binding" "this" {
  for_each = local.namespace_assignments
  metadata {
    name      = each.key
    namespace = each.value.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.this[each.key].metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = each.value.principal_group_name
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [kubernetes_role.this]
}

# =========================================================================
#  4. Resource untuk Scope "CLUSTER" (ClusterRole dan ClusterRoleBinding)
# =========================================================================
resource "kubernetes_cluster_role" "this" {
  for_each = local.cluster_assignments
  metadata {
    name = each.value.role_name
  }
  dynamic "rule" {
    for_each = each.value.rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  for_each = local.cluster_assignments
  metadata {
    name = each.key
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this[each.key].metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = each.value.principal_group_name
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [kubernetes_cluster_role.this]
}