# Le réseau de Waxtan.
# Schéma du MVP :
#   Internet -> Internet Gateway -> VPC 10.0.0.0/16
#     └── Subnet public 10.0.1.0/24 -> EC2 + conteneur Waxtan
# Tout ce fichier est gratuit sur AWS.

# Le VPC : notre réseau privé isolé dans AWS.
resource "aws_vpc" "principal" {
  cidr_block = "10.0.0.0/16" # 65 536 adresses privées, de 10.0.0.0 à 10.0.255.255

  enable_dns_support   = true # le VPC résout les noms de domaine
  enable_dns_hostnames = true # les machines reçoivent un nom DNS (utile à Session Manager)

  tags = {
    Name = "${var.projet}-vpc" # le nom affiché dans la console : "waxtan-vpc"
  }
}

# Le subnet public : un morceau du VPC, dans une seule zone de disponibilité.
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.principal.id # référence : le subnet est créé APRÈS le VPC
  cidr_block        = "10.0.1.0/24"        # 256 adresses, découpées dans le /16 du VPC
  availability_zone = "${var.region}a"     # eu-north-1a : un seul datacenter, compromis assumé du MVP

  tags = {
    Name = "${var.projet}-subnet-public"
  }
}

# L'Internet Gateway : la porte entre le VPC et Internet.
resource "aws_internet_gateway" "principal" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name = "${var.projet}-igw"
  }
}

# La table de routage : "pour aller partout ailleurs (0.0.0.0/0), passe par la porte".
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.principal.id
  }

  tags = {
    Name = "${var.projet}-rt-public"
  }
}

# L'association : c'est ELLE qui rend le subnet "public".
# Un subnet est public parce que sa table de routage mène à une Internet Gateway.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Le Security Group : le pare-feu du serveur.
# Tout est interdit par défaut, on n'ouvre que le web. PAS de port 22 (Session Manager).
resource "aws_security_group" "web" {
  name        = "${var.projet}-web"
  description = "Trafic web vers le serveur Waxtan (80 et 443), pas de SSH"
  vpc_id      = aws_vpc.principal.id

  tags = {
    Name = "${var.projet}-sg-web"
  }
}

# Entrée : HTTP depuis tout Internet.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Entrée : HTTPS depuis tout Internet.
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.web.id
  description       = "HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# Sortie : tout autorisé. Le serveur doit pouvoir télécharger l'image (ECR),
# parler à Session Manager, à S3 et aux API (Claude, Whisper, Supabase).
# Terraform ne recrée pas la règle de sortie par défaut d'AWS : il faut l'écrire.
resource "aws_vpc_security_group_egress_rule" "tout" {
  security_group_id = aws_security_group.web.id
  description       = "Toutes les sorties"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # -1 = tous les protocoles, tous les ports
}
