locals {
  domain_name = "lb.${var.domain}"
}

resource "digitalocean_certificate" "loadbalancer" {
  name              = "tls-${local.domain_name}"
  private_key       = "${file(var.tls_private_key)}"
  leaf_certificate  = "${file(var.tls_cert)}"
  certificate_chain = "${file(var.tls_chain)}"
}

# Create a new Load Balancer with TLS termination
resource "digitalocean_loadbalancer" "public" {
  name                   = "${local.domain_name}"
  region                 = "lon1"
  droplet_tag            = "${digitalocean_tag.collector.id}"
  redirect_http_to_https = true

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = "8082"
    target_protocol = "http"

    certificate_id = "${digitalocean_certificate.loadbalancer.id}"
  }

  healthcheck {
    port     = "8082"
    protocol = "tcp"
  }
}

resource "digitalocean_record" "loadbalancer" {
  domain = "${var.domain}"
  type   = "A"
  name   = "lb"
  ttl    = 30
  value  = "${digitalocean_loadbalancer.public.ip}"
}
