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
  ssh_keys = ["81:82:8a:89:28:50:ac:ed:01:7f:d7:52:c9:11:b6:90"]
}



resource "digitalocean_droplet" "nodejs" {
  image    = "ubuntu-20-04-x64"
  name     = "nodejs-droplet"
  region   = "nyc1"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["81:82:8a:89:28:50:ac:ed:01:7f:d7:52:c9:11:b6:90"]
}


# Firewalls y reglas de los droplets



#Aislar la conexión a la BD de tal manera que solo se tenga acceso desde la aplicación web (App Service). Esto se logra configurando del firewall de la BD MySQL)

resource "digitalocean_firewall" "mysql" {
  name = "mysql-firewall"

  droplet_ids = [digitalocean_droplet.mysql.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "3306"
    source_addresses = ["digitalocean_droplet.nodejs.ipv4_address"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["191.95.132.34"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]

  }
  # outbound_rule {
  # protocol              = "tcp"
  # port_range            = "0-65535"
  # destination_addresses = ["0.0.0.0/0"]
  # }
  }





resource "digitalocean_firewall" "nodejs" {
  name = "nodejs-firewall"

  droplet_ids = [digitalocean_droplet.mysql.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["192.168.1.0/24", "2002:1:2::/48"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}


