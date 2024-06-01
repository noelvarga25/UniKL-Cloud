# Steps to install TwentyCRM on Azure

## Preparation

- Go to the official website and go to the [documentation](https://docs.twenty.com/start/self-hosting/cloud-providers) section where you will find all the files.
- Copy all the necessary files into a directory and edit them to fit your project if needed. (I only changed the name, server locations and server type to have a stronger back-end)
- Install all required dependencies like [Terraform](https://developer.hashicorp.com/terraform/install) and [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

## Mandatory setup

1. **Log in to Azure:**
   ```bash
   az login
   ```

2. **Navigate to project directory:**
   ```bash
   cd <folder_name>
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Create Terraform plan:**
   ```bash
   terraform plan -out tfplan
   ```

5. **Apply Terraform plan:**
   ```bash
   terraform apply tfplan
   ```

6. **Initialise the database:**
   ```bash
   az containerapp exec --name twenty-server -g <resource_groupe_name> --command "yarn database:init:prod"
   ```

7. **Get frontend URL:**
	- Go to the [Azure Portal](https://portal.azure.com/)
	- Click on the resource group
	- Click on the front end application
	- Get the link

## (Optional) Prevent new sign-ups

8. **Update environment variables (optional):**
   - Modify `backend.tf` to disable signups:
     ```json
     env {
       name  = "IS_SIGN_UP_DISABLED"
       value = "true"
     }
     ```

9. **Reapply Terraform configuration (if environment variables updated):**
   ```bash
   terraform plan -out tfplan
   terraform apply tfplan
   ```
