variable "tags" {
  description = "The tags to associate with your resources."
  type        = map
  default     = {
      Team      = "Reform-DevOps"
  }
}