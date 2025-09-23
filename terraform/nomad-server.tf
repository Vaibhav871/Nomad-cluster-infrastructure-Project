resource "aws_instance" "nomad_server" {
  ami                         = var.nomad_ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.nomad_sg.id]
  associate_public_ip_address = false

  user_data = file("${path.module}/../cloud-init/nomad-server.sh")

  tags = {
    Name    = "nomad-server"
    Cluster = "nomad-cluster"
  }
}
