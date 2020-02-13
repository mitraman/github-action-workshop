
output "main_vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public-subnet-a.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private-subnet-a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public-subnet-b.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private-subnet-b.id
}