# Create a new Load Balancer with TLS termination
resource "digitalocean_loadbalancer" "chronograf" {
  name        = "chronograf.jsoc.pw"
  region      = "lon1"
  droplet_tag = "${digitalocean_tag.influx.id}"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = "8888"
    target_protocol = "http"
  }

  healthcheck {
    port     = "8888"
    protocol = "tcp"
  }
}

resource "digitalocean_record" "chronograf" {
  domain = "${var.domain}"
  type   = "A"
  name   = "chronograf"
  ttl    = 30
  value  = "${digitalocean_loadbalancer.public.ip}"
}
