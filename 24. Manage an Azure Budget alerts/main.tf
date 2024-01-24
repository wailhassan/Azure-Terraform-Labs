/*
Manage an Azure Budget alerts       
By: Wail Hassan                  
https://github.com/wailhassan */


// Define the action group
resource "azurerm_monitor_action_group" "email_alert" {
  name                = "email-alert"
  resource_group_name = azurerm_resource_group.app_grp.name
  short_name          = "email-alert"

  email_receiver {
    name                    = "sendtoAdmin"
    // Put your email address that you want to receive notification  
    email_address           = ""
    use_common_alert_schema = true
  }

}

// Create an Azure Consumption Budget Resource Group

resource "azurerm_consumption_budget_resource_group" "Monthly_budget" {
  name              = "Monthly-budget"
  resource_group_id = azurerm_resource_group.app_grp.id

  amount     = 50
  time_grain = "Monthly"

  time_period {
    start_date = "2024-02-01T00:00:00Z"
    end_date   = "2024-12-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 70.0
    operator       = "EqualTo"
    threshold_type = "Forecasted"


    contact_groups = [
      azurerm_monitor_action_group.email_alert.id,
    ]
  }
}