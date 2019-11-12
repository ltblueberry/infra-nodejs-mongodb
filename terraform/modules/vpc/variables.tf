variable env_name {
  description = "Environment name"
}

variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}

variable app_tag {
  description = "Application instance tag"
}

variable db_tag {
  description = "DB instance tag"
}
