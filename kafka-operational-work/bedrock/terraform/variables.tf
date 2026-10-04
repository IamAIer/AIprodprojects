variable "aws_region" {
  description = "AWS Region for the Jira answer bot."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Short name used to label this bot deployment."
  type        = string
  default     = "demo"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment must use lowercase letters, numbers, and hyphens."
  }
}

variable "jira_project_key" {
  description = "Jira project key whose issue comments the bot may answer."
  type        = string
}

variable "trigger_phrase" {
  description = "Text users include in a Jira comment to invoke the bot."
  type        = string
  default     = "/kafka"
}

variable "bedrock_model_id" {
  description = "Bedrock model ID or inference profile ID/ARN used by the Converse API."
  type        = string
}

variable "bedrock_model_arns" {
  description = "Bedrock resource ARN(s) allowed for invocation. Cross-Region inference profiles may need the profile and destination foundation model ARNs."
  type        = list(string)
}

variable "sop_prefix" {
  description = "S3 folder containing approved SOPs. Only this prefix is readable by the bot."
  type        = string
  default     = "approved/"

  validation {
    condition     = can(regex("^[A-Za-z0-9/_-]+/$", var.sop_prefix))
    error_message = "SOP prefix must contain simple path characters and end with a slash."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain bot Lambda logs."
  type        = number
  default     = 30
}
