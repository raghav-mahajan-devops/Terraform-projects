output "dns_name" {
  value = aws_instance.multi_instance[each.key].public_dns
}
output "public_ip" {
  value = aws_instance.multi_instance[each.key].public_ip
}