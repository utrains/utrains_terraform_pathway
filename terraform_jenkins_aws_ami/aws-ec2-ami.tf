# configured aws provider with proper credentials
provider "aws" {
  region    = "us-east-1"
  profile   = "default"
}

 # create default vpc if one does not exit
 resource "aws_default_vpc" "default_vpc" {
 }

# create security group for the ec2 instance
resource "aws_security_group" "utrais_security_gp" {
  name        = "ec2 utrains security group"
  description = "allow access on ports 8080 and 22 for jenkins and ssh"
  vpc_id      = aws_default_vpc.default_vpc.id
  # allow access on port 8080 for Jenkins Server
  ingress {
    description      = "httpd access port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  # allow access on port 22 ssh connection
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags   = {
    Name = "utrains server security group"
  }
}

# launch the ec2 instance
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-064bd5050ca35013f"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.utrais_security_gp.id]
  key_name               = aws_key_pair.instance_key.key_name
  //user_data            = file("installed_script.sh")

  tags = {
    Name = "utrains devos jenkins project"
  }
}
# an empty resource block
resource "null_resource" "name" {
  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(local_file.ssh_key.filename)
    host        = aws_instance.ec2_instance.public_ip
  }
  # wait for ec2 to be created
  depends_on = [aws_instance.ec2_instance]
}
