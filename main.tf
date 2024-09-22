# --------------------------------------------------------------
# Creating a VPC
# --------------------------------------------------------------

module "main_VPC" {
  source             = "./Modules/VPC"
  vpc_ip             = var.main_vpc_ip
  public_subnet_IP_1 = var.public_subnet_IP_1
  public_subnet_IP_2 = var.public_subnet_IP_2
  public_subnet_AZ_1 = var.public_subnet_AZ_1
  public_subnet_AZ_2 = var.public_subnet_AZ_2
  private_subnet1_IP = var.private_subnet1_IP
  private_subnet2_IP = var.private_subnet2_IP
  private_subnet1_AZ = var.private_subnet1_AZ
  private_subnet2_AZ = var.private_subnet2_AZ

}


# --------------------------------------------------------------
# Creating Security Group for Proxies
# --------------------------------------------------------------

module "Proxy_SG" {
  source      = "./Modules/Security Group"
  name        = "Proxy_SG"
  description = "Allow HTTP inbound traffic and all outbound traffic."
  vpc_id      = module.main_VPC.vpc_id


  ingress_rules = {
    http = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.External_ALB_SG.SecurityGroup_ID
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80
    }
  }
}


# --------------------------------------------------------------
# Creating Reverse Proxy servers
# --------------------------------------------------------------

module "Proxy01" {
  source             = "./Modules/EC2"
  instance_name      = "Proxy01"
  instance_ami       = var.instance_ami
  instance_type      = var.instance_type
  instance_subnet_id = module.main_VPC.public_subnet_id_1
  SG_id              = module.Proxy_SG.SecurityGroup_ID
  keyname            = "myInternaAWSKey"
  userdata           = <<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx

# NGINX reverse proxy configuration
echo 'server {
  listen 80;
  location / {
    proxy_pass http://${module.INT_ALB.ALB_DNS};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}' | sudo tee /etc/nginx/sites-available/default > /dev/null

# Create symlink for sites-enabled
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Test and restart nginx
sudo nginx -t && sudo systemctl restart nginx
EOF 
}

module "Proxy02" {
  source             = "./Modules/EC2"
  instance_name      = "Proxy02"
  instance_ami       = var.instance_ami
  instance_type      = var.instance_type
  instance_subnet_id = module.main_VPC.public_subnet_id_2
  SG_id              = module.Proxy_SG.SecurityGroup_ID
  keyname            = "myInternaAWSKey"
  userdata           = <<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx

# NGINX reverse proxy configuration
echo 'server {
  listen 80;
  location / {
    proxy_pass http://${module.INT_ALB.ALB_DNS};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}' | sudo tee /etc/nginx/sites-available/default > /dev/null

# Create symlink for sites-enabled
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Test and restart nginx
sudo nginx -t && sudo systemctl restart nginx
EOF 
}


# --------------------------------------------------------------
# Creating Security Group for Bastion Host
# --------------------------------------------------------------

module "Bastion_SG" {
  source      = "./Modules/Security Group"
  name        = "Bastion_SG"
  description = "Allow SSH inbound traffic and all outbound traffic."
  vpc_id      = module.main_VPC.vpc_id


  ingress_rules = {
    ssh = {
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
      from_port                    = 22
      ip_protocol                  = "tcp"
      to_port                      = 22
    }
  }
}


# --------------------------------------------------------------
# Creating Bastion Host
# --------------------------------------------------------------

module "Bastion_Host" {
  source             = "./Modules/EC2"
  instance_name      = "Bastion_Host"
  instance_ami       = var.instance_ami
  instance_type      = var.instance_type
  instance_subnet_id = module.main_VPC.public_subnet_id_1
  SG_id              = module.Bastion_SG.SecurityGroup_ID
  keyname            = "myAWSkey"
}



# --------------------------------------------------------------
# Creating Security Group for Backend Servers
# --------------------------------------------------------------

module "BE_SG" {
  source      = "./Modules/Security Group"
  name        = "BE_SG"
  description = "Allow HTTP inbound traffic and all outbound traffic."
  vpc_id      = module.main_VPC.vpc_id


  ingress_rules = {
    http = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.Internal_ALB_SG.SecurityGroup_ID
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80
    }
  }
}


# --------------------------------------------------------------
# Creating Backend Servers
# --------------------------------------------------------------

module "Backend01" {
  source             = "./Modules/EC2"
  instance_name      = "Backend01"
  instance_ami       = var.instance_ami
  instance_type      = var.instance_type
  instance_subnet_id = module.main_VPC.private_subnet1_id
  SG_id              = module.BE_SG.SecurityGroup_ID
  keyname            = "myInternaAWSKey"
  Is_PublicIP        = false
  userdata           = <<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx

SERVER_NAME=$(hostname)

echo "<html>
<head><title>Welcome</title></head>
<body>
<h1>Hi from $SERVER_NAME</h1>
</body>
</html>" | sudo tee /var/www/html/index.nginx-debian.html > /dev/null

sudo systemctl restart nginx
EOF
}


module "Backend02" {
  source             = "./Modules/EC2"
  instance_name      = "Backend02"
  instance_ami       = var.instance_ami
  instance_type      = var.instance_type
  instance_subnet_id = module.main_VPC.private_subnet2_id
  SG_id              = module.BE_SG.SecurityGroup_ID
  keyname            = "myInternaAWSKey"
  Is_PublicIP        = false
  userdata           = <<-EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx

SERVER_NAME=$(hostname)

echo "<html>
<head><title>Welcome</title></head>
<body>
<h1>Hi from $SERVER_NAME</h1>
</body>
</html>" | sudo tee /var/www/html/index.nginx-debian.html > /dev/null

sudo systemctl restart nginx
EOF
}



# --------------------------------------------------------------
# Creating Security Group for External Application Load Balancer
# --------------------------------------------------------------

module "External_ALB_SG" {
  source      = "./Modules/Security Group"
  name        = "External_ALB_SG"
  description = "Allow HTTP inbound traffic and all outbound traffic."
  vpc_id      = module.main_VPC.vpc_id


  ingress_rules = {
    http = {
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80
    }
  }
}

# --------------------------------------------------------------
# Creating External Application Load Balancer
# --------------------------------------------------------------

module "EXT_ALB" {
  source               = "./Modules/ALB"
  lb_name              = "EXT-ALB"
  target_group_name    = "Proxy-Group"
  target_instance_1_id = module.Proxy01.EC2_id
  target_instance_2_id = module.Proxy02.EC2_id
  vpc_id               = module.main_VPC.vpc_id
  subnet-1-id          = module.main_VPC.public_subnet_id_1
  subnet-2-id          = module.main_VPC.public_subnet_id_2
  Security_Group_id    = module.External_ALB_SG.SecurityGroup_ID
  Is_Internal          = false
}


# --------------------------------------------------------------
# Creating Security Group for Internal Application Load Balancer
# --------------------------------------------------------------

module "Internal_ALB_SG" {
  source      = "./Modules/Security Group"
  name        = "Internal_ALB_SG"
  description = "Allow HTTP inbound traffic and all outbound traffic."
  vpc_id      = module.main_VPC.vpc_id


  ingress_rules = {
    http = {
      cidr_ipv4                    = null
      referenced_security_group_id = module.Proxy_SG.SecurityGroup_ID
      from_port                    = 80
      ip_protocol                  = "tcp"
      to_port                      = 80
    }
  }
}


# --------------------------------------------------------------
# Creating Internal Application Load Balancer
# --------------------------------------------------------------

module "INT_ALB" {
  source               = "./Modules/ALB"
  lb_name              = "INT-ALB"
  target_group_name    = "Backend-Group"
  target_instance_1_id = module.Backend01.EC2_id
  target_instance_2_id = module.Backend02.EC2_id
  vpc_id               = module.main_VPC.vpc_id
  subnet-1-id          = module.main_VPC.private_subnet1_id
  subnet-2-id          = module.main_VPC.private_subnet2_id
  Security_Group_id    = module.Internal_ALB_SG.SecurityGroup_ID
  Is_Internal          = true
}