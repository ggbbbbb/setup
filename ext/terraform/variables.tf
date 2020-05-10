variable "google" {
  type    = string
  default = "us-central1"
}

variable "db_table_name" {
  type    = string
  default = "google-table"
}

variable "db_read_capacity" {
  type    = number
  default = 1
}

variable "db_write_capacity" {
  type    = number
  default = 1
}

variable "tag_user_name" {
  type = string
  default = "bbbbb"
}
