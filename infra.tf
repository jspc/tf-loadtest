resource "digitalocean_ssh_key" "core" {
  name       = "Terraform Coreos"
  public_key = "${file("${var.ssh_public_key}")}"
}

resource "digitalocean_tag" "collector" {
  name = "collector"
}

resource "digitalocean_droplet" "agent" {
  name  = "${format("agent-%02d", count.index)}"
  count = 5
  image = "coreos-stable"

  region = "${var.region}"
  size   = "4gb"

  user_data = "${file("userdata/agents.yaml")}"

  ssh_keys = ["${digitalocean_ssh_key.core.id}"]
}

resource "digitalocean_droplet" "collector" {
  name  = "${format("collector-%02d", count.index)}"
  count = 2
  image = "coreos-stable"

  region = "${var.region}"
  size   = "512mb"

  user_data = "${file("userdata/collectors.yaml")}"

  ssh_keys = ["${digitalocean_ssh_key.core.id}"]
  tags     = ["${digitalocean_tag.collector.id}"]
}

resource "digitalocean_droplet" "tick" {
  name  = "tick"
  image = "coreos-stable"

  region = "${var.region}"
  size   = "2gb"

  user_data = "${file("userdata/tick.yaml")}"

  ssh_keys = ["${digitalocean_ssh_key.core.id}"]
}

resource "digitalocean_record" "influx" {
  domain = "${var.domain}"
  type   = "A"
  name   = "influx"
  ttl    = 30
  value  = "${digitalocean_droplet.tick.ipv4_address}"
}
