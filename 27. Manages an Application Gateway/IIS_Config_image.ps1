import-module servermanager
add-windowsfeature web-server -includeallsubfeature
add-windowsfeature Web-Asp-Net45
add-windowsfeature NET-Framework-Features
New-Item -Path "D:\Azure Projects\Full Project\Own Github Project\1. Azure Terraform Labs\27. Manages an Application Gateway\images" -Name "images" -ItemType "directory"
Set-Content -Path "D:\Azure Projects\Full Project\Own Github Project\1. Azure Terraform Labs\27. Manages an Application Gateway\images\Default.html" -Value "This is the images server"