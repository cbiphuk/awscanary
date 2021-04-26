variable "handler" {
  description = "Entry point to use for the source code when running the canary. This value must end with the string .handler. Be sure to set your canary’s script entry point as myCanaryFilename.handler to match the file name of your script’s entry point."
  type        = string
}

variable "name" {
  description = "Cloudwatch canary name"
  type        = string
}

variable "runtime_version" {
  description = "Runtime version to use for the canary. Versions change often so consult the Amazon CloudWatch documentation for the latest valid versions."
  type = string
}

variable "script_name" {
  description = "Archive name"
  type = string
}

