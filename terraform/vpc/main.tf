module "vpc" {
  providers = {
    aws = aws.suna_development
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"
  name = "suna-vpc"
  cidr = "10.10.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic
  # 10.10.00000 000.00000000 0,8,16,24,32,40,48,56,64,...248 = Max32個のサブネットが作成可能
  # リソースに割り当て可能なipは11bit分=2^11=2048
  # 最初の4つと最後が予約済み、-5して、各サブネットには2043個のipが割り振り可能
  # 気をつけるのはENI1つでipアドレス1つ
  azs                 = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  public_subnets      = ["10.10.0.0/21", "10.10.8.0/21", "10.10.16.0/21"]
  private_subnets     = ["10.10.24.0/21", "10.10.32.0/21", "10.10.40.0/21"]
  database_subnets    = ["10.10.48.0/21", "10.10.56.0/21", "10.10.64.0/21"]
  elasticache_subnets = ["10.10.72.0/21", "10.10.80.0/21", "10.10.88.0/21"]
  #redshift_subnets    = ["10.10.96.0/21", "10.10.104.0/21", "10.10.112.0/21"]
  intra_subnets       = ["10.10.120.0/21", "10.10.128.0/21", "10.10.136.0/21"]

  # db用のサブネットは作らない
  create_database_subnet_group   = false

  enable_dns_hostnames           = true  # Should be true to enable DNS hostnames in the VPC
  enable_dns_support             = true  # Should be true to enable DNS support in the Default VPC
  #enable_classiclink             = false
  #enable_classiclink_dns_support = false
  enable_nat_gateway             = false
  single_nat_gateway             = false

  #customer_gateways = {
  #  IP1 = {
  #    bgp_asn    = 65112
  #    ip_address = "1.2.3.4"
  #  },
  #  IP2 = {
  #    bgp_asn    = 65112
  #    ip_address = "5.6.7.8"
  #  }
  #}

  enable_vpn_gateway = false

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "service.consul"
  # dhcp_options_domain_name_servers
  # DHCPオプションセットのDNSサーバーアドレスのリストを指定します。
  # デフォルトではAWSが提供します（enable_dhcp_optionsをtrueに設定する必要があります）
  #dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  # VPC endpoint for S3
  enable_s3_endpoint = false

  # VPC endpoint for DynamoDB
  enable_dynamodb_endpoint = false

  # VPC endpoint for SSM
  enable_ssm_endpoint              = false
  ssm_endpoint_private_dns_enabled = false
  ssm_endpoint_security_group_ids  = []

  # VPC endpoint for SSMMESSAGES
  enable_ssmmessages_endpoint              = false
  ssmmessages_endpoint_private_dns_enabled = false
  ssmmessages_endpoint_security_group_ids  = []

  # VPC Endpoint for EC2
  enable_ec2_endpoint              = false
  ec2_endpoint_private_dns_enabled = false
  ec2_endpoint_security_group_ids  = []

  # VPC Endpoint for EC2MESSAGES
  enable_ec2messages_endpoint              = false
  ec2messages_endpoint_private_dns_enabled = false
  ec2messages_endpoint_security_group_ids  = []

  # VPC Endpoint for ECR API
  enable_ecr_api_endpoint              = false
  ecr_api_endpoint_private_dns_enabled = false
  ecr_api_endpoint_security_group_ids  = []

  # VPC Endpoint for ECR DKR
  enable_ecr_dkr_endpoint              = false
  ecr_dkr_endpoint_private_dns_enabled = false
  ecr_dkr_endpoint_security_group_ids  = []

  # VPC endpoint for KMS
  enable_kms_endpoint              = false
  kms_endpoint_private_dns_enabled = false
  kms_endpoint_security_group_ids  = []

  # VPC endpoint for ECS
  enable_ecs_endpoint              = false
  ecs_endpoint_private_dns_enabled = false
  ecs_endpoint_security_group_ids  = []

  # VPC endpoint for ECS telemetry
  enable_ecs_telemetry_endpoint              = false
  ecs_telemetry_endpoint_private_dns_enabled = false
  ecs_telemetry_endpoint_security_group_ids  = []

  # VPC endpoint for SQS
  enable_sqs_endpoint              = false
  sqs_endpoint_private_dns_enabled = false
  sqs_endpoint_security_group_ids  = []

  # Additional tags for the VPC Endpoints
  #vpc_endpoint_tags = {
  #  Project  = "Secret"
  #  Endpoint = "true"
  #}
}
