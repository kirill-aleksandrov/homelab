variable "server" {
  type = string
}

variable "key_name" {
  type = string
}

variable "key_algorithm" {
  type = string
}

variable "key_secret" {
  type      = string
  sensitive = true
}

variable "zone" {
  type = string
}

variable "ttl" {
  type = number
}

variable "domains" {
  type = list(object({
    name      = string
    addresses = list(string)
  }))
}
