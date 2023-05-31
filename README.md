# Terraform Script for Automating Wordpress Deployment on AWS
This Terraform script deploys a dockerized WordPress application on AWS with an EC2 instance, an RDS MySQL instance,
and an Elastic IP. Attaches your custom domain to the wordpress application with an SSL certificate.    
Installs phpmyadmin to access the MySQL Database.

### Requirements
- Terraform
- AWS Account
- AWS CLI    

The user account authenticated with AWS CLI should have administrative privilleges inorder create the resources on AWS.

![image](https://github.com/rogdex24/terraform-wordpress-automation/assets/51379457/0a731114-f6bc-41a1-ad4b-ca44e4cedc45)


## Deployment Steps

-> Create a `secrets.tfvars` file in root directory based on the `secrets.tfvars.template` provided.    
Else you can input them when prompted by `terraform apply`    

Initialize Terraform 
```bash
terraform init
```

Run the script to install wordpress and phpmyadmin
```bash
terraform apply --var-file=secrets.tfvars
```
#### Sample Output:   
Here I gave my domain as `rogdex.co` and subdomain as `www`.

![image](https://user-images.githubusercontent.com/51379457/232780982-f5de918e-30a6-4b4c-8ea2-9f82b94205fe.png)

Now you can access your wordpress page through wordpress-link and the phpmyadmin through phpmyadmin-link.

#### Important Note:   
-  If porkbun is not your domain name registrar you can Ignore the `api_key` and the `secret_api_key` in the `secrets.tfvars` file.  
-  But then you should manually update your DNS record of your domain with the `web_public_ip` of the EC2 instance from the output received. 

### Rollback and Deletion:     
What if terraform apply paritally fails ?   
This is a current problem with terraform at the moment which is yet to be fixed.   

**Case I : Due to any wrong configuration of resources the script breaks and terraforms exits itself.**  
      - The state is persisted till that point    
      - And the created resources can be removed by `terraform destroy`    
      - For this case we can use the script [terraform-run.sh](https://github.com/rogdex24/terraform-wordpress-automation/blob/main/terraform-run.sh)
        which runs terraform destroy whenever terraform apply fails   
      
**Case II: If the terraform process is abruptly killed for any reason, rather than exiting itself.**  
      - The state is not persisted    
      - Manually findout and cleanup the resources created.  
      - A [PR](https://github.com/hashicorp/terraform/pull/32680) has been merged to periodically persist intermediate state snaspshots
        and is anitcipated to be realeased in Terraform v1.5




