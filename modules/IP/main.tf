# Fetch your current public IP address and convert it to CIDR notation

# data "http" "myip" { url = "https://checkip.amazonaws.com" }

# locals {
#   my_ip_cidr = "${trimspace(data.http.myip.response_body)}/32"
# }

# output "my_ip" { value = local.my_ip_cidr }
