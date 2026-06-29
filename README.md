# Umami-ECS-Deployment
Production-grade AWS infrastructure deployed via Terraform &amp; GitHub Actions. Features a multi-AZ VPC routing public traffic through Route 53 &amp; ALB into secure private subnets hosting ECS Fargate tasks. Outbound internet uses NAT Gateways, while data is isolated in a multi-AZ Amazon RDS cluster. Zero EC2 management, fully serverless &amp; secure.
