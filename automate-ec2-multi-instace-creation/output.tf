output "dns_name" {
    value = [
        for dns in aws_instance.multi_instance : dns.public_dns
    ]
}
output "public_ip" {
     value = [
        for ip in aws_instance.multi_instance : ip.public_ip
    ]
}