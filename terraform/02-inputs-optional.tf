variable "tags" {
  description = "The tags to associate with your resources."
  type        = "map"
  default     = {
      createdby = "James.Matthews"
      Team      = "Reform-DevOps"
  }
}