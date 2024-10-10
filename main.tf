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

# Aquí iría el resto de la configuración de recursos, como los Droplets, redes, etc.


# Droplets


resource "digitalocean_droplet" "mysql" {
  image    = "ubuntu-20-04-x64"
  name     = "mysql-droplet"
  region   = "nyc1" # Elige una región cercana a ti
  size     = "s-1vcpu-1gb" # Ajusta el tamaño del droplet
  ssh_keys = ["7b:4f:8b:d7:ce:11:10:88:b1:e3:45:11:6d:a4:f2:5c"]
}



resource "digitalocean_droplet" "nodejs" {
  image    = "ubuntu-20-04-x64"
  name     = "nodejs-droplet"
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["7b:4f:8b:d7:ce:11:10:88:b1:e3:45:11:6d:a4:f2:5c"]
}


# Firewalls y reglas de los droplets



# Aislar la conexión a la BD de tal manera que solo se tenga acceso desde la aplicación web (App Service). Esto se logra configurando del firewall de la BD MySQL)

# Firewall para mysql

resource "digitalocean_firewall" "mysql" {
  name = "mysql-firewall"

  droplet_ids = [digitalocean_droplet.mysql.id]

  # Permitir conexión MySQL solo desde el servidor de Node.js
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3306"
    source_addresses = [digitalocean_droplet.nodejs.ipv4_address]
  }

  # Permitir SSH solo desde la máquina de control
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["191.95.132.34"] #mi ip 
  }

  # Reglas de salida estándar (Internet)
  outbound_rule {
    protocol              = "tcp"
    port_range            = "443" # HTTPS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53" # DNS (53) para consultas
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}



# Firewall para Node.js

resource "digitalocean_firewall" "nodejs" {
  name = "nodejs-firewall"

  # Reglas de entrada para HTTPS (puerto 443)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443" # Solo HTTPS
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Reglas de salida para HTTPS y DNS
  outbound_rule {
    protocol              = "tcp"
    port_range            = "443" # HTTPS
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53" # DNS (53) para consultas
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}



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