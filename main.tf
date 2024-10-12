terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "digitalocean" {}

provider "digitalocean" {
  token = var.digitalocean
}

# MySQL Droplet using DigitalOcean Marketplace image
resource "digitalocean_droplet" "mysql" {
  name     = "mysqlonubuntu2004-s-1vcpu-1gb-nyc1-01"
  region   = "nyc1"
  image    = "mysql-20-04"      
  size     = "s-1vcpu-1gb"
  ssh_keys = ["ec:9c:fe:af:18:f8:9c:ae:0b:b3:a0:ee:ec:05:88:d7"]
}

# Node.js Droplet (no changes here)
resource "digitalocean_droplet" "nodejs" {
  name     = "nodejs-droplet"
  region   = "nyc1"
  image    = "ubuntu-24-10-x64"
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = ["ec:9c:fe:af:18:f8:9c:ae:0b:b3:a0:ee:ec:05:88:d7"]
}

# # Firewall for MySQL
# resource "digitalocean_firewall" "mysql" {
#   name = "mysql-firewall"

#   droplet_ids = [digitalocean_droplet.mysql.id]

#   # Allow MySQL connection only from the Node.js server
#   inbound_rule {
#     protocol         = "tcp"
#     port_range       = "3306"
#     source_addresses = [digitalocean_droplet.nodejs.ipv4_address]
#   }

  # # Allow SSH only from the control machine (your machine's IP)
  # inbound_rule {
  #   protocol         = "tcp"
  #   port_range       = "22"
  #   source_addresses = ["191.95.132.34"] # your IP 191.95.132.34
  # }

  # # Inbound rule for HTTPS (port 443) to secure phpMyAdmin access
  # inbound_rule {
  #   protocol         = "tcp"
  #   port_range       = "443" # HTTPS only
  #   source_addresses = ["0.0.0.0/0", "::/0"]  # All addresses can access HTTPS
  # }

  # # Optional: Inbound rule for HTTP (port 80) only if not forcing HTTPS
  # inbound_rule {
  #   protocol         = "tcp"
  #   port_range       = "80" # HTTP access (for non-HTTPS users)
  #   source_addresses = ["0.0.0.0/0", "::/0"]
  # }

  # # Outbound rule for HTTPS and DNS (to allow internet access)
  # outbound_rule {
  #   protocol              = "tcp"
  #   port_range            = "443"
  #   destination_addresses = ["0.0.0.0/0", "::/0"]
  # }

  # outbound_rule {
  #   protocol              = "udp"
  #   port_range            = "53"
  #   destination_addresses = ["0.0.0.0/0", "::/0"]
  # }
# }

# # Firewall for Node.js
# resource "digitalocean_firewall" "nodejs" {
#   name = "nodejs-firewall"

#   droplet_ids = [digitalocean_droplet.nodejs.id]

#   # Inbound rule for HTTPS (port 443)
#   inbound_rule {
#     protocol         = "tcp"
#     port_range       = "443"
#     source_addresses = ["0.0.0.0/0", "::/0"]  # Allow all to access Node.js over HTTPS
#   }

#   # Outbound rule for HTTPS and DNS
#   outbound_rule {
#     protocol              = "tcp"
#     port_range            = "443"
#     destination_addresses = ["0.0.0.0/0", "::/0"]
#   }

#   outbound_rule {
#     protocol              = "udp"
#     port_range            = "53"
#     destination_addresses = ["0.0.0.0/0", "::/0"]
#   }
# }




# error generado cuando dejo la salida de internet (era porque en el port_ range no lo tenía definido y estaban varios en uno solo)
# Error: Error creating firewall: POST https://api.digitalocean.com/v2/firewalls: 422 (request "88652950-0884-4617-9dc3-fbf318574783") invalid port range
# │
# │   with digitalocean_firewall.mysql,
# │   on main.tf line 49, in resource "digitalocean_firewall" "mysql":
# │   49: resource "digitalocean_firewall" "mysql" {
# │
# ╵
# ╷
# │ Error: Error creating firewall: POST https://api.digitalocean.com/v2/firewalls: 422 (request "be62e54b-d5d7-4151-9d13-066082b8bdce") invalid port range
# │
# │   with digitalocean_firewall.nodejs,
# │   on main.tf line 86, in resource "digitalocean_firewall" "nodejs":
# │   86: resource "digitalocean_firewall" "nodejs" {