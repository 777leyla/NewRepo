resource "aws_instance" "bastion" {
  ami                         = "ami-0cff7528ff583bf9a"
  subnet_id                   = aws_subnet.public_subnet1a.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.bastion-profile.name}"
  key_name                    = "gogreen"
  tags = {
    "Name" = "Bastion-EC2"
  }
}
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
}


resource "aws_security_group" "bastion" {
  name        = "Bastion host"
  description = "Allow SSH access to bastion host and outbound internet access"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    description = "SSH"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
    ingress {
    description = "HTTPS"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

// Generate the SSH keypair that we’ll use to configure the EC2 instance.
// After that, write the private key to a local file and upload the public key to AWS
# resource "tls_private_key" "ssh" {
#   algorithm = "RSA"
#   rsa_bits  = "4096" 
# }
# resource "aws_key_pair" "gogreen" {
#   key_name   = "gogreen"
#   public_key = tls_private_key.ssh.public_key_openssh
#   provisioner "local-exec" {
#     command = "echo '$(tls_private_key.ssh.private_key_pem)' > ./gogreen.pem"
#   }
# }