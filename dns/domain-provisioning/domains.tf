resource "dns_a_record_set" "a_record" {
  count = length(var.domains)

  zone      = var.zone
  name      = var.domains[count.index].name
  addresses = var.domains[count.index].addresses
  ttl       = var.ttl
}
