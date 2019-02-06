variable "project" {
  description = "Project name."
  default     = "project"
}

variable "environment" {
  description = "Environment name."
  default     = "test"
}

variable "resource_identifier" {
  description = "By default resource identifier is a sum of project name and environment name. This variable allows to override this with custom name."
  default     = "none"
}

variable "load_balancer_arn" {
  description = "ARN of Load Balancer to assign this WAF"
}

variable "whitelist" {
  description = "List of IP's (in CIDR format) to whitelist"
  default     = []
  type        = "list"
}
