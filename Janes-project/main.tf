
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version               = "5.5.2"

  name                  = var.vpc_name
  cidr                  = var.vpc_cidr

  azs                   = var.aws_availability_zones
  private_subnets       = var.private_subnets_cidrs
  public_subnets        = var.public_subnets_cidrs

  enable_nat_gateway    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "${var.project_name}_resource"
  }
}


module "my_webserver" {
  source      = "../modules/servers"
  org_name        =var.org_name
  aws_availability_zones = var.aws_availability_zones
  instance_type   = var.instance_type
  vpcid           = module.vpc.vpc_id
  project_name    = var.project_name
  private_subnets = [module.vpc.private_subnets[0]]
  public_subnets  = module.vpc.public_subnets
}

# module "my_webserver2" {
#   source      = "../modules/servers"
#   org_name        =var.org_name
#   aws_availability_zones = var.aws_availability_zones
#   instance_type   = var.instance_type
#   vpcid           = module.vpc.vpc_id
#   project_name    = var.project_name
#   private_subnets = [module.vpc.private_subnets[1]]
#   public_subnets  = module.vpc.public_subnets
# }

