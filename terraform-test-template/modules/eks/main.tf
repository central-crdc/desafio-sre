provider "aws" {
  # A configuração do provider virá do terragrunt
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  eks_managed_node_group_defaults = {
    disk_size                  = 50
    instance_types             = ["t3.medium"]
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }
  
  eks_managed_node_groups = var.node_groups
  
  tags = merge(
    var.tags,
    {
      Terraform   = "true"
      Environment = var.environment
    }
  )
}
