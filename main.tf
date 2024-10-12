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

# Node.js Droplet
resource "digitalocean_droplet" "nodejs" {
  name     = "nodejs-droplet"
  region   = "nyc1"
  image    = "ubuntu-20-04-x64"
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = ["ec:9c:fe:af:18:f8:9c:ae:0b:b3:a0:ee:ec:05:88:d7"]
}

# Firewall for MySQL
resource "digitalocean_firewall" "mysql" {
  name = "mysql-firewall"

  droplet_ids = [digitalocean_droplet.mysql.id]

  # Allow MySQL connection only from the Node.js server
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3306"
    source_addresses = [digitalocean_droplet.nodejs.ipv4_address]
  }

  # Allow SSH only from the control machine (your machine's IP)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["191.95.132.34"]
  }

  # Allow HTTP traffic for phpMyAdmin
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow outbound traffic for HTTP, HTTPS, and DNS
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"  # HTTP
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443" # HTTPS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"  # DNS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Firewall for Node.js
resource "digitalocean_firewall" "nodejs" {
  name = "nodejs-firewall"

  droplet_ids = [digitalocean_droplet.nodejs.id]

  # Allow HTTP traffic for Node.js application
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8080"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow SSH only from the control machine (your machine's IP)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["191.95.132.34"]
  }

  # Allow outbound traffic for HTTP, HTTPS, and DNS
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"  # HTTP
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443" # HTTPS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"  # DNS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}