provider "azurerm" {
  features {}
  subscription_id = "59ded65e-7c57-44bb-b9b1-83d8b7fa1c32"
}

data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "resource_group" {
  name     = "rg_${var.project}_${var.environment_tag}"
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.project}storage"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_kind             = "Storage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "application_insight" {
  name                = "${var.project}-appinsight"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  application_type    = "other"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.project}-asp"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function_app" {
  name                        = "${var.project}-function-app"
  resource_group_name         = azurerm_resource_group.resource_group.name
  location                    = var.location
  service_plan_id             = azurerm_service_plan.app_service_plan.id
  storage_account_name        = azurerm_storage_account.storage_account.name
  storage_account_access_key  = azurerm_storage_account.storage_account.primary_access_key
  https_only                  = true
  functions_extension_version = "~4"
  app_settings = {
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "AzureWebJobsFeatureFlags"       = "EnableWorkerIndexing"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insight.instrumentation_key
  }

  lifecycle {
    replace_triggered_by = [terraform_data.function_app_package_sha]
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }

  }

  zip_deploy_file = data.archive_file.function.output_path
}

data "archive_file" "function" {
  type        = "zip"
  excludes    = split("\n", file("${path.root}/fastapi-on-azure-functions/.funcignore"))
  source_dir  = "${path.root}/../MyFuncProject"
  output_path = "${path.root}/example.zip"
}

resource "terraform_data" "function_app_package_sha" {
  # produce hashing of the .zip deployment file - only redeploy azfunc when sourcecode changes
  input = data.archive_file.function.output_md5
}