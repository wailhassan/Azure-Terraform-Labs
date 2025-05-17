# Azure Terraform Labs

Welcome to the **Azure Terraform Labs** repository!  
This collection of labs is designed to help you master the deployment and management of Azure resources using [Terraform](https://www.terraform.io/).  
Through hands-on exercises, you'll gain practical experience in infrastructure as code (IaC) within the Azure ecosystem.

## 📚 Lab Overview

Each lab focuses on a specific Azure service or scenario, providing step-by-step guidance to deploy and manage resources effectively.  
The labs are structured to progressively build your skills, from basic resource provisioning to more complex configurations.

### Available Labs

1. **Manage a Resource Group**
2. **Manage an Azure Storage Account**
3. **Manage a Virtual Network and Subnet**
4. **Manage a Network Interface**
5. **Manage a Public IP Address**
6. **Manage a Network Security Group**
7. **Manage a Virtual Machine**
8. **Manage a Virtual Machine Scale Set**
9. **Manage an Azure SQL Database**
10. **Manage an App Service Plan and App Service**
11. **Manage an App Service with Database Connection**
12. **Manage a Key Vault**
13. **Manage a Load Balancer**
14. **Manage an Azure Bastion Host**
15. **Manage a Public DNS Zone**
16. **Implement Custom Script Extensions**

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- An active [Azure subscription](https://azure.microsoft.com/en-us/free/)

### Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/wailhassan/Azure-Terraform-Labs.git
   cd Azure-Terraform-Labs
   ```

2. **Navigate to a Lab Directory**

   Each lab is contained within its own directory. For example:

   ```bash
   cd "1. Manages a Resource Group"
   ```

3. **Initialize Terraform**

   ```bash
   terraform init
   ```

4. **Review and Apply the Configuration**

   ```bash
   terraform plan
   terraform apply
   ```

   *Note: Always review the Terraform plan before applying changes to understand what resources will be created or modified.*

## 🧹 Cleanup

To remove the resources created during a lab:

```bash
terraform destroy
```

*Ensure you're in the correct lab directory before running the destroy command to avoid unintended deletions.*

## 📝 Contributing

Contributions are welcome! If you have suggestions for new labs or improvements to existing ones, please open an issue or submit a pull request.

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 📬 Contact

For questions or feedback, please contact [wailhassan](https://github.com/wailhassan).
