variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map(any)

  validation {
    condition     = alltrue([for k, v in var.common_tags : length(k) <= 512 && length(tostring(v)) <= 256])
    error_message = "common_tags keys must be at most 512 characters and values at most 256 characters."
  }
}
