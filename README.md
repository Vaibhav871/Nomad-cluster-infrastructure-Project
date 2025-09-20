# Nomad Cluster Infrastructure Project

A **production-ready, secure HashiCorp Nomad cluster** deployed on AWS using Terraform, with custom AMI builds via Packer and automated CI/CD pipelines. This project demonstrates infrastructure-as-code best practices, secure networking, and comprehensive observability.

## 🏗️ Architecture Overview

- **VPC with Private/Public Subnets** - Network isolation and security
- **Bastion Host** - Secure gateway for cluster access
- **Nomad Server** - Control plane with bootstrap configuration
- **Nomad Client** - Workload execution nodes with Docker
- **Custom AMIs** - Packer-built base images with pre-installed dependencies
- **Monitoring Stack** - Prometheus & Grafana for observability
- **CI/CD Pipeline** - Automated deployment with GitHub Actions

---
## Architecture 
![Nomad Architecture ](images/nomad-architecture.png)
---
## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform 
- SSH key pair for EC2 access
- GitHub repository with secrets configured

### 1. Clone and Initialize
```bash
git clone https://github.com/Vaibhav871/Nomad-cluster-infrastructure-Project.git
cd Nomad-cluster-infrastructure-Project
terraform init
```

### 2. Deploy Infrastructure
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

---

## 🔐 Secure Access Methods

### SSH Access via SSH Agent
**Secure authentication without exposing private keys on remote hosts:**

1. **Start SSH agent and add key**
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add /path/to/your-private-key.pem
   ```

2. **Connect to Bastion with agent forwarding**
   ```bash
   ssh -A ubuntu@<BASTION_PUBLIC_IP>
   ```

3. **Access internal nodes from Bastion**
   ```bash
   ssh ubuntu@<NOMAD_SERVER_PRIVATE_IP>
   ssh ubuntu@<NOMAD_CLIENT_PRIVATE_IP>
   ```

### Nomad UI Access via SSH Tunnel
**Securely access Nomad web interface through Bastion from your local machine:**

```bash
ssh -i .ssh/bastionkey -L 4646:<nomad-server-ip>:4646 ubuntu@<bastion-serevr-ip>
```

Then open: **http://localhost:4646** in your browser

### Prometheus & Grafana Access via SSH Tunnel
**Monitor cluster metrics securely:**

1. **Prometheus access**
   ```bash
   http://<bastion-public-ip>:9090
   ```

2. **Grafana dashboard access**
   ```bash
   http://<bastion-public-ip>:3000
   ```

---

## 📱 Application Access

### Deployed Application via Nomad Client
Applications deployed through Nomad are accessible via the client nodes:

1. **Check running jobs**
   ```bash
   nomad status
   nomad status nginix-web
   ```

2. **Access application**
   ```bash
   #  Application exposes port 8080
   <nomad_client_public_ip>:8080
   ```
   Access: **http://<client_public_ip>:8080**

---

## 🛡️ Security Best Practices Implemented

### Network Security
- **Private subnets** For Nomad Server
- **Bastion host** as single point of entry with restricted security groups
- **Security group rules** following principle of least privilege
- **No public IPs** on Nomad server instances

### Access Control
- **SSH key-based authentication** only 
- **SSH agent forwarding** to avoid private key exposure on remote hosts
- **IAM roles** with minimal required permissions for EC2 instances

### CI/CD Security
- **GitHub Secrets** used for sensitive variables (AWS credentials, SSH keys)
- **No hardcoded credentials** in Terraform or configuration files
- **Scoped IAM roles** for deployment automation
- **Terraform state** stored securely at remote backend S3

### ASG Configuration Highlights
- **Desired Count**: Defined as `TF_VAR_NOMAD_CLIENT_COUNT` to control initial and target client node count.

### 🗄️ Terraform Backend
- Used **S3 backend** to store and manage Terraform state.
- Ensures state is **centrally stored, durable, and accessible** to all team members.
- **Prevents local state loss** and enables **safe collaboration**.
- Uses **S3 for state locking** to avoid concurrent changes.

---

## 🏗️ Custom AMI with Packer

This project uses **Packer to build custom AMIs** with pre-installed dependencies:

### AMI Components
- **Base OS**: Ubuntu 22.04 LTS
- **Docker Engine**: Pre-installed and configured
- **System dependencies**: curl, wget, unzip, jq
- **Security hardening**: Automatic security updates, SSH configuration

### Building Custom AMI
```bash
cd packer/
packer build nomad-server.pkr.hcl -var-file=/.variables.pkr.hcl
```

---

## 🔄 CI/CD Pipeline Integration

### GitHub Secrets Configuration
Required secrets for automated deployment:

```
## 🔑 GitHub Secrets and Terraform Variables

### AWS and Region Settings
- `AWS_ACCESS_KEY_ID`  
- `AWS_SECRET_ACCESS_KEY`  
- `AWS_REGION`  

### AMI and Instance Configuration
- `BASE_AMI`  
- `INSTANCE_TYPE`  
- `ROOT_VOLUME_SIZE`    

### Nomad and Application Settings
- `NOMAD_DOWNLOAD_URL`  
- `NOMAD_VERSION`  

### SSH and Access Management
- `SSH_USERNAME`  

### Availability and Region Zones
- `TF_VAR_REGION`  
- `TF_VAR_AVAILABILITY_ZONE`  

### Terraform Variables
- `TF_VAR_S3_BUCKET_NAME`  
- `TF_VAR_VPC_CIDR`  
- `TF_VAR_BASTION_PUBLIC_KEY`  
- `TF_VAR_KEY_NAME`  
- `TF_VAR_NOMAD_AMI_ID`  
- `TF_VAR_NOMAD_CLIENT_COUNT`  
- `TF_VAR_PRIVATE_SUBNET_CIDR`  
- `TF_VAR_PUBLIC_SUBNET_CIDR`  
- `TF_VAR_REGION`  
- `TF_VAR_INSTANCE_TYPE`  
- `TF_VAR_ADMIN_CIDR`  
---

```

### Pipeline Features
- **Automated Terraform deployment** on push to the `main` branch, triggered only when changes are made in the `terraform` directory.  
- **Terraform destroy** can be executed via workflow dispatch. [In the future, approval-based Terraform runs will be implemented.] 
- **Infrastructure validation** integrated into the pipeline.  

---

## 📊 Monitoring & Observability

### Prometheus Metrics
- **Nomad cluster health** and job status
- **Application performance** metrics
``` <bastio_server_ip:9090> ```

### Grafana Dashboards
- **Nomad cluster overview** - Jobs, allocations, nodes
- **Application dashboards** - Service-specific metrics
``` <bastio_server_ip:3000> ```

---

## 🧹 Cleanup

Destroy all resources when no longer needed:
- **Terraform destroy** can be executed via workflow dispatch to destroy resources.
  
```bash
terraform destroy
```
---

## 📚 Additional Resources

- [HashiCorp Nomad Documentation](https://developer.hashicorp.com/nomad)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Packer Documentation](https://developer.hashicorp.com/packer)

![grafana dashboard](images/grafana.png)
![Nomad UI ](images/nomad-ui.png)

