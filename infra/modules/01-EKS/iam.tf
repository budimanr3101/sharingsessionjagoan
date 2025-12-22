resource "aws_iam_policy" "aws_load_balancer_controller" {
  name = "nbl_AWSLoadBalancerControllerIAMPolicy"
  path = "/"
  description = "AWS Load Balancer Controller IAM Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "elasticloadbalancing:SetWebACL",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetRulePriorities",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:SetRulePriorities",
          "elasticloadbalancing:ModifyListenerAttributes",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = [
          "arn:aws:ec2:*:*:security-group/*"
        ]
        Condition = {
          StringEquals = {
            "ec2:CreateAction" : "CreateSecurityGroup"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = [
          "arn:aws:ec2:*:*:security-group/*"
        ]
      }
    ]
  })
}

# Create IAM role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "nbl-aws-load-balancer-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks-cluster.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks-cluster.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks-cluster.oidc_provider}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
  role       = aws_iam_role.aws_load_balancer_controller.name
} 

#CMK POLICY==================================================================================

resource "aws_iam_policy" "sharedCMK" {
  name        = "CmkCentralicedAccountPolicy"
  description = "sharedCMK IAM Policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowUseOfKeyInAccountSecurity",
        Effect = "Allow",
        Action = [
          "kms:*"
          # "kms:Encrypt",
          # "kms:Decrypt",
          # "kms:ReEncrypt*",
          # "kms:GenerateDataKey*",
          # "kms:DescribeKey",
          # "kms:CreateGrant"
        ],
        # Resource = "arn:aws:kms:ap-southeast-3:537124962690:key/94ee7551-3c36-424d-9b7c-78483b951386"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "sharedCMK" {
  name = "sharedCMKRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "eks.amazonaws.com",
            "autoscaling.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "sharedCMK" {
  policy_arn = aws_iam_policy.sharedCMK.arn
  role       = aws_iam_role.sharedCMK.name
}

# EKS Node Role
resource "aws_iam_role" "eks_node_role" {
  name = format("%s-%s-%s-eks-node-role", var.master_prefix, var.env_prefix, var.app_prefix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "autoscaling.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = var.tags
}

# Attach required EKS node policies
resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node_role.name
}

# Attach your custom policies
resource "aws_iam_role_policy_attachment" "eks_node_alb_controller" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cmk" {
  policy_arn = aws_iam_policy.sharedCMK.arn
  role       = aws_iam_role.eks_node_role.name
}

# Optional: Add custom inline policy if needed
# resource "aws_iam_role_policy" "eks_node_custom_policy" {
#   name = format("%s-%s-%s-eks-node-custom-policy", var.master_prefix, var.env_prefix, var.app_prefix)
#   role = aws_iam_role.eks_node_role.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           # Add your custom permissions here
#           "s3:GetObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           # Add your resource ARNs here
#           "arn:aws:s3:::your-bucket-name",
#           "arn:aws:s3:::your-bucket-name/*"
#         ]
#       }
#     ]
#   })
# }

#### Cluster AutoScaller ###
# IAM Policy
resource "aws_iam_policy" "cluster_autoscaler" {
  count       = var.enable_cluster_autoscaller ? 1 : 0
  name        = "EKSClusterAutoscalerPolicy"
  path        = "/"
  description = "Policy for EKS Cluster Autoscaler"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        Resource = "*"
      }
    ]
  })
}

## IAM Role ##
resource "aws_iam_role" "cluster_autoscaler" {
  count      = var.enable_cluster_autoscaller ? 1 : 0
  name = "eks-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = module.eks-cluster.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${module.eks-cluster.oidc_provider}:aud" = "sts.amazonaws.com",
            "${module.eks-cluster.oidc_provider}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# ## IAM attach Policy ##
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count      = var.enable_cluster_autoscaller ? 1 : 0
  role       = aws_iam_role.cluster_autoscaler[0].name
  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
}



#### EFS CSI DRIVER IAM ROLE & Policy ###
# IAM Policy
# Buat managed policy
# resource "aws_iam_policy" "efs_csi_driver" {
#   name = "${var.env_prefix}-${var.app_prefix}-eks-efs-csi-policy"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "elasticfilesystem:DescribeAccessPoints",
#           "elasticfilesystem:DescribeFileSystems",
#           "elasticfilesystem:CreateAccessPoint",
#           "elasticfilesystem:DeleteAccessPoint"
#         ],
#         "Resource": "*"
#       }
#     ]
#   })
# }

# # Attach policy ke role
# resource "aws_iam_role_policy_attachment" "efs_attach_policy" {
#   policy_arn = aws_iam_policy.efs_csi_driver.arn
#   role       = aws_iam_role.efs_csi_driver.name
# }


# ## Create IAM ROLE
# resource "aws_iam_role" "efs_csi_driver" {
#   name = "${var.env_prefix}-${var.app_prefix}-eks-efs-csi-driver"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Federated = module.eks-cluster.oidc_provider_arn
#         },
#         Action = "sts:AssumeRoleWithWebIdentity",
#         Condition = {
#           StringEquals = {
#             "${module.eks-cluster.oidc_provider}:aud" = "sts.amazonaws.com",
#             "${module.eks-cluster.oidc_provider}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
#           }
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }


#### ADOT Telemetry #####
resource "aws_iam_policy" "adot_collector" {
  count       = var.enable_adot_role ? 1 : 0
  name        = "${var.env_prefix}-${var.app_prefix}-eks-adot-collector-policy"
  description = "Policy for ADOT Collector in EKS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups"
      ],
      Resource = "*"
    },
    {
        Effect = "Allow",
        Action = [
          # Required by awscontainerinsightreceiver
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          # Needed for EBS metrics
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      }
      ]
  })
}

resource "aws_iam_role" "adot_collector" {
  count = var.enable_adot_role ? 1 : 0
  name  = "${var.env_prefix}-${var.app_prefix}-eks-adot-collector"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Federated = module.eks-cluster.oidc_provider_arn
      },
      Action    = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${module.eks-cluster.oidc_provider}:aud" = "sts.amazonaws.com",
          "${module.eks-cluster.oidc_provider}:sub" = "system:serviceaccount:monitoring:aws-otel-sa"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "adot_collector" {
  count      = var.enable_adot_role ? 1 : 0
  role       = aws_iam_role.adot_collector[0].name
  policy_arn = aws_iam_policy.adot_collector[0].arn
}

### Secret Provider Class ###
# resource "aws_iam_policy" "ssm_parameter_access" {
#   count       = var.enable_secret_provider_class ? 1 : 0
#   name        = "${var.env_prefix}-${var.app_prefix}-eks-ssm-access"
#   description = "IAM policy for CSI driver to access SSM Parameter Store"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect   = "Allow",
#       Action   = [
#         "ssm:GetParameters",
#         "ssm:GetParameter",
#         "ssm:GetParametersByPath"
#       ],
#       Resource = [
#         for param in data.aws_ssm_parameter.ssm_parameters_store : param.arn
#       ]
#     },
#     {
#       Effect   = "Allow",
#       Action   = [
#          "kms:DescribeKey",
#           "kms:GenerateDataKey",
#           "kms:Encrypt",
#           "kms:Decrypt"
#       ],
#       Resource = "${var.kms_cmk_prefix}"
#     }
#     ]
#   })
# }


# resource "aws_iam_role" "ssm_secrets_store_csi" {
#   count = var.enable_secret_provider_class ? 1 : 0
#   name  = "${var.env_prefix}-${var.app_prefix}-eks-ssm-csi-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = {
#         Federated = module.eks-cluster.oidc_provider_arn
#       },
#       Action = "sts:AssumeRoleWithWebIdentity",
#       Condition = {
#         StringEquals = {
#           "${module.eks-cluster.oidc_provider}:aud" = "sts.amazonaws.com",
#           "${module.eks-cluster.oidc_provider}:sub" = [
#             "system:serviceaccount:kube-system:secrets-store-csi-driver-sa",
#             "system:serviceaccount:sample:ssm-secret-sa"
#           ]
#         }
#       }
#     }]
#   })

#   tags = var.tags
# }

# resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
#   count      = var.enable_secret_provider_class ? 1 : 0
#   role       = aws_iam_role.ssm_secrets_store_csi[0].name
#   policy_arn = aws_iam_policy.ssm_parameter_access[0].arn
# }

# resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
#   count      = var.enable_secret_provider_class ? 1 : 0
#   role       = aws_iam_role.ssm_secrets_store_csi[0].name
#   policy_arn = 
# }










