provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

resource "aws_vpc" "vpc_hw2" {
  cidr_block = var.cidr_main
  tags = {
    Name = "${var.pref}-VPC"
  }
}

#-------------  AWS::EC2::InternetGateway ----------------

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_hw2.id

  tags = {
    Name = "${var.pref}-GW"
  }
}

#AWS::EC2::RouteTable

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc_hw2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "${var.pref}-rt-gw"
  }
}

#AWS::EC2::VPCGatewayAttachment
#AWS::EC2::Route
# ----------------------------------------------------------

#----------------------  Subnets ---------------------------

resource "aws_subnet" "sub_pub_A" {
  vpc_id            = aws_vpc.vpc_hw2.id
  cidr_block        = var.cidr_pub_A
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.pref}-sub-pub-A"
  }
}

resource "aws_subnet" "sub_pub_B" {
  vpc_id            = aws_vpc.vpc_hw2.id
  cidr_block        = var.cidr_pub_B
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.pref}-sub-pub-B"
  }
}

resource "aws_subnet" "sub_pr_A" {
  vpc_id            = aws_vpc.vpc_hw2.id
  cidr_block        = var.cidr_pr_A
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.pref}-sub-pr-A"
  }
}

resource "aws_subnet" "sub_pr_B" {
  vpc_id            = aws_vpc.vpc_hw2.id
  cidr_block        = var.cidr_pr_B
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.pref}-sub-pr-B"
  }
}
resource "aws_subnet" "sub_pr_DB_A" {
  vpc_id            = aws_vpc.vpc_hw2.id
  cidr_block        = var.cidr_pr_DB_A
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.pref}-sub-pr-DB-A"
  }
}
resource "aws_subnet" "sub_pr_DB_B" {
  vpc_id            = aws_vpc.vpc_hw2.id
  cidr_block        = var.cidr_pr_DB_B
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.pref}-sub-pr-DB-B"
  }
}
# ----------------------------------------------------------

#---------------- Route Tables -----------------------------

resource "aws_route_table" "rt_pr_a" {
  vpc_id = aws_vpc.vpc_hw2.id

  tags = {
    Name = "${var.pref}-rt-pr1"
  }
}

resource "aws_route_table" "rt_pr_b" {
  vpc_id = aws_vpc.vpc_hw2.id

  tags = {
    Name = "${var.pref}-rt-pr2"
  }
}

#--- Subnet-RT Association ---

resource "aws_route_table_association" "ass-pub-a" {
  subnet_id      = aws_subnet.sub_pub_A.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "ass-pub-b" {
  subnet_id      = aws_subnet.sub_pub_B.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "ass-pr-a" {
  subnet_id      = aws_subnet.sub_pr_A.id
  route_table_id = aws_route_table.rt_pr_a.id
}
resource "aws_route_table_association" "ass-pr-b" {
  subnet_id      = aws_subnet.sub_pr_B.id
  route_table_id = aws_route_table.rt_pr_b.id
}
#-----------------------------
# ----------------------------------------------------------

#------------------- S3 Endpoint ---------------------------

resource "aws_vpc_endpoint" "ep_s3" {
  vpc_id          = aws_vpc.vpc_hw2.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.rt_pr_a.id, aws_route_table.rt_pr_b.id]
}
# ----------------------------------------------------------

#----------------- SSM Parameters --------------------------

resource "aws_ssm_parameter" "db_pass" {
  name        = "/database/password/admin"
  description = "DB MySQL cluster"
  type        = "SecureString"
  value       = var.DB_pass

  tags = {
    environment = "production"
  }
}
# ----------------------------------------------------------

#------------------  Security Group ------------------------

resource "aws_security_group" "sg_rds" {
  name        = "allow_rds"
  description = "Allow RDS Aurora inbound local traffic"
  vpc_id      = aws_vpc.vpc_hw2.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidr_main]
  }
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidr_main]
  }
  tags = {
    Name = "${var.pref}-sg-rds"
  }
}



resource "aws_security_group" "sg_http_s_ssh" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_hw2.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.pref}-sg-http-s-ssh"
  }
}
# ----------------------------------------------------------

#-----------------------  Role -----------------------------

resource "aws_iam_role" "role_ec2_s3" {
  name = "${var.pref}-role-ec2-s3-RDS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.pref}-role_ec2_s3"
  }
}

#----- Policy    for Role ---------
resource "aws_iam_role_policy" "pol" {
  name = "policy-ec2-s3"
  role = aws_iam_role.role_ec2_s3.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "polrds" {
  name = "policy-ec2-s3-rds"
  role = aws_iam_role.role_ec2_s3.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "rds:*",
          "application-autoscaling:DeleteScalingPolicy",
          "application-autoscaling:DeregisterScalableTarget",
          "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:DescribeScalingActivities",
          "application-autoscaling:DescribeScalingPolicies",
          "application-autoscaling:PutScalingPolicy",
          "application-autoscaling:RegisterScalableTarget",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DeleteAlarms",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeCoipPools",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeLocalGatewayRouteTables",
          "ec2:DescribeLocalGatewayRouteTableVpcAssociations",
          "ec2:DescribeLocalGateways",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:GetCoipPoolUsage",
          "sns:ListSubscriptions",
          "sns:ListTopics",
          "sns:Publish",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "outposts:GetOutpostInstanceTypes"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : "pi:*",
        "Effect" : "Allow",
        "Resource" : "arn:aws:pi:*:*:metrics/rds/*"
      },
      {
        "Action" : "iam:CreateServiceLinkedRole",
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : [
              "rds.amazonaws.com",
              "rds.application-autoscaling.amazonaws.com"
            ]
          }
        }
      }
    ]
    }
  )
}


# ----------------------------------

#---- InstanceProfile for Role -----

resource "aws_iam_instance_profile" "instprof" {
  name = "${var.pref}-instprof"
  role = aws_iam_role.role_ec2_s3.name
}
# ----------------------------------
# ----------------------------------------------------------

#---------------------  RDS MySQL --------------------------

resource "aws_db_subnet_group" "sub_gr" {
  name       = "${var.pref}_sql_sub_gr"
  subnet_ids = [aws_subnet.sub_pr_A.id, aws_subnet.sub_pr_B.id]

  tags = {
    Name = "${var.pref}_sql_sub_gr"
  }
}

resource "aws_rds_cluster" "rds01" {
  cluster_identifier      = "aurora-cluster-${var.pref}"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.03.2"
  availability_zones      = ["${var.region}a", "${var.region}b"]
  db_subnet_group_name = aws_db_subnet_group.sub_gr.id
  database_name           = "brvv"
  master_username         = "admin"
  master_password         = aws_ssm_parameter.db_pass.value
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "aurora-cluster-${var.pref}-${count.index}"
  cluster_identifier = aws_rds_cluster.rds01.id
  instance_class     = "db.t3.small"
  engine             = aws_rds_cluster.rds01.engine
  engine_version     = aws_rds_cluster.rds01.engine_version
  db_subnet_group_name = aws_db_subnet_group.sub_gr.id
}


# ----------------------------------------------------------

#-----------------------  EC2 ------------------------------

resource "aws_instance" "ec2_a" {
  ami           = "ami-05b622b5fa0269787" # us-west-2
  instance_type = "t2.micro"
  key_name = var.aws_key_name
  #var.aws_key_name
  #associate_public_ip_address = "true"
  subnet_id            = aws_subnet.sub_pr_A.id
  iam_instance_profile = aws_iam_instance_profile.instprof.id
  security_groups      = [aws_security_group.sg_http_s_ssh.id, ]
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  user_data = <<EOF
          #!/bin/bash
          aws s3 cp s3://anders01-hw/nginx/nginx-1.18.0-2.el7.ngx.x86_64.rpm nginx.rpm
          sudo chmod 777 nginx.rpm
          sudo yum install nginx.rpm -y
          sudo yum install -y php
          sudo yum install -y mysql
          sudo yum install -y php-mysql
          sudo yum install php-fpm -y
          cd /var/www/html
          sudo systemctl stop nginx
          sudo systemctl stop httpd
          sudo echo "<?php  \$dsn = 'mysql:host=${aws_rds_cluster.rds01.endpoint};port=3306;dbname=brvv';  ?>" > /var/www/html/base.php
          sudo aws s3 cp s3://anders01-hw/SiteDB01/index.php /var/www/html/index.php
          sudo aws s3 cp s3://anders01-hw/SiteDB01/allusers.php /var/www/html/allusers.php
          sudo aws s3 cp s3://anders01-hw/SiteDB01/style.css /var/www/html/style.css
          sudo aws s3 cp s3://anders01-hw/service_files/default.conf /etc/nginx/conf.d/default.conf
          sudo aws s3 cp s3://anders01-hw/service_files/nginx.conf /etc/nginx/nginx.conf
          sudo aws s3 cp s3://anders01-hw/service_files/php.ini /etc/php.ini
          sudo aws s3 cp s3://anders01-hw/service_files/httpd.conf /etc/httpd/conf/httpd.conf
          sudo aws s3 cp s3://anders01-hw/service_files/create.sql /tmp/create.sql           
          sudo chmod 755 /var/www/html/*
          sudo systemctl start php-fpm
          sudo systemctl enable php-fpm 
          sudo systemctl start nginx
          sudo systemctl enable nginx
          sudo mysql -h ${aws_rds_cluster.rds01.endpoint} -u "admin" "-p${aws_ssm_parameter.db_pass.value}" "brvv" < /tmp/create.sql
  EOF
  depends_on = [aws_rds_cluster.rds01, aws_rds_cluster_instance.cluster_instances]
}


# ----------------------------------------------------------

#----------------------- ALB -------------------------------

resource "aws_lb" "alb" {
  name               = "${var.pref}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_http_s_ssh.id]
  subnets            = [aws_subnet.sub_pub_A.id, aws_subnet.sub_pub_B.id]

  enable_deletion_protection = false
  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.bucket
  #  prefix  = "${var.pref}-alb-"
  #  enabled = true
  #}
  tags = {
    Environment = "${var.pref}-alb"
  }
}

#--- Target Group ---
resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.pref}-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_hw2.id

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

#--- ALB-TG Attachments ---
resource "aws_lb_target_group_attachment" "alb-attach-a" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.ec2_a.id
  port             = 80
}
#resource "aws_lb_target_group_attachment" "alb-attach-b" {
#  target_group_arn = aws_lb_target_group.alb_tg.arn
#  target_id        = aws_instance.ec2_b.id
#  port             = 80
#}

#--- ALB Listener ---
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}


# ----------------------------------------------------------





