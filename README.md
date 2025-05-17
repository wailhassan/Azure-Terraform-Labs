Azure Terraform Labs
Welcome to the Azure Terraform Labs repository! This collection of labs is designed to help you master the deployment and management of Azure resources using Terraform. Through hands-on exercises, you'll gain practical experience in infrastructure as code (IaC) within the Azure ecosystem.

📚 Lab Overview
Each lab focuses on a specific Azure service or scenario, providing step-by-step guidance to deploy and manage resources effectively. The labs are structured to progressively build your skills, from basic resource provisioning to more complex configurations.

Available Labs
Manage a Resource Group

Manage an Azure Storage Account

Manage a Virtual Network and Subnet

Manage a Network Interface

Manage a Public IP Address

Manage a Network Security Group

Manage a Virtual Machine

Manage a Virtual Machine Scale Set

Manage an Azure SQL Database

Manage an App Service Plan and App Service

Manage an App Service with Database Connection

Manage a Key Vault

Manage a Load Balancer

Manage an Azure Bastion Host

Manage a Public DNS Zone

Implement Custom Script Extensions

🚀 Getting Started
Prerequisites
Before you begin, ensure you have the following installed:

Terraform

Azure CLI

An active Azure subscription

Setup Instructions
Clone the Repository

bash
Copy
Edit
git clone https://github.com/wailhassan/Azure-Terraform-Labs.git
cd Azure-Terraform-Labs
Navigate to a Lab Directory

Each lab is contained within its own directory. For example:

bash
Copy
Edit
cd "1. Manages a Resource Group"
Initialize Terraform

bash
Copy
Edit
terraform init
Review and Apply the Configuration

bash
Copy
Edit
terraform plan
terraform apply
Note: Always review the Terraform plan before applying changes to understand what resources will be created or modified.

🧹 Cleanup
To remove the resources created during a lab:

bash
Copy
Edit
terraform destroy
Ensure you're in the correct lab directory before running the destroy command to avoid unintended deletions.

📝 Contributing
Contributions are welcome! If you have suggestions for new labs or improvements to existing ones, please open an issue or submit a pull request.

📄 License
This project is licensed under the MIT License.

📬 Contact
For questions or feedback, please contact wailhassan.

