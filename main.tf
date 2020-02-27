provider "aws" {
  profile    = "personal"
  region     = "eu-central-1"
}

resource "aws_vpc" "fake-product-production-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"

  tags = {
    Name = "fake-product-production"
  }
}

resource "aws_subnet" "fake-product-production-subnet" {
  vpc_id                  = aws_vpc.fake-product-production-vpc.id
  cidr_block              = "10.0.1.0/24"

  tags = {
    Name = "fake-product-production-subnet"
  }
}

resource "aws_security_group" "fake-product-production-sg" {
  name        = "fake-product-production-sg"
  vpc_id      = aws_vpc.fake-product-production-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "fake-product-staging-vpc" {
  cidr_block       = "20.0.0.0/16"
  instance_tenancy = "dedicated"

  tags = {
    Name = "fake-product-staging"
  }
}

resource "aws_subnet" "fake-product-staging-subnet" {
  vpc_id                  = aws_vpc.fake-product-staging-vpc.id
  cidr_block              = "20.0.1.0/24"

  tags = {
    Name = "fake-product-staging-subnet"
  }
}

resource "aws_security_group" "fake-product-staging-sg" {
  name        = "fake-product-staging-sg"
  vpc_id      = aws_vpc.fake-product-staging-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["20.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "fake-product-assets-bucket" {
  bucket = "fake-product-assets"
  acl    = "private"
}

resource "aws_iam_user" "emma-user" {
  name = "emma"
}

resource "aws_iam_user_policy_attachment" "emma-user-policy-attach" {
  user       = aws_iam_user.emma-user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "liam-user" {
  name = "liam"
}

resource "aws_iam_user_policy_attachment" "liam-user-policy-attach" {
  user       = aws_iam_user.liam-user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "fake-product-user" {
  name = "fake-product-user"
}

resource "aws_iam_policy" "fake-product-bucket-read-write-policy" {
  name        = "fake-product-bucket-read-write"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::fake-product-assets"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["arn:aws:s3:::fake-product-assets/*"]
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "fake-product-user-policy-attach" {
  user       = aws_iam_user.fake-product-user.name
  policy_arn = aws_iam_policy.fake-product-bucket-read-write-policy.arn
}
