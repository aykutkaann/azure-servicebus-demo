variable "resource_group_name" {
	description = "Resource Group Name"
	type = string
	default = "rg-eventdriven-demo"

}

variable "location" {
	description = "Azure Region"
	type = string
	default = "eastus"
}

variable "servicebus_namespace" {
  description = "Service Bus namespace adı"
  type        = string
  default     = "sb-eventdriven-demo"
}

variable "servicebus_queue" {
  description = "Kuyruk adı"
  type        = string
  default     = "order-processing-queue"
}

variable "acr_name" {
  description = "Azure Container Registry adı"
  type        = string
  default     = "acreventdrivendemo"
}

variable "aca_env_name" {
  description = "Container Apps Environment adı"
  type        = string
  default     = "cae-eventdriven-demo"
}

variable "job_name" {
  description = "Container Apps Job adı"
  type        = string
  default     = "job-message-processor"
}

