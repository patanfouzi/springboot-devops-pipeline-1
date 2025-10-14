# 🚀 Spring Boot DevOps Pipeline – Automated Infrastructure & Deployment

### 🌐 Repository

**GitHub:** [mehziya0352/springboot-devops-pipeline](https://github.com/mehziya0352/springboot-devops-pipeline)

---

## 📖 Overview

This project demonstrates a **complete DevOps automation pipeline** for deploying the **Spring Boot Petclinic** application using:

* **Terraform** for infrastructure provisioning (App + MySQL servers on AWS)
* **Ansible** for configuration management and deployment
* **GitHub Actions** for CI/CD orchestration
* **Trivy** for image and artifact vulnerability scanning
* **S3 + DynamoDB** for remote Terraform state management

Everything — from creating EC2 instances to running the application — is **fully automated** through GitHub Actions workflows.

---
## 📁 Repository Structure

springboot-devops-pipeline/
├── terraform/
│ ├── main.tf
│ ├── backend.tf
│ ├── variables.tf
│ ├── outputs.tf
├── scripts/
│ └── tf-to-inventory.py
├── ansible/
│ ├── inventory.ini (auto-generated)
│ ├── playbooks/
│ │ ├── app.yml
│ │ └── mysql.yml
│ ├── roles/
│ │ ├── docker/
│ │ ├── mysql/
│ │ └── spring-petclinic/
│ └── ...
├── create-backend.sh
└── .github/workflows/final-deploy.yml

## 🧩 Architecture

**Workflow summary:**

1. Terraform provisions:

   * App Server (for Docker or Tomcat)
   * MySQL Server
   * Security Groups, Key Pairs, etc.
   * Remote backend: S3 bucket + DynamoDB for state locking

2. A script (`scripts/tf-to-inventory.py`) dynamically extracts instance IPs and generates **Ansible inventory**.

3. Ansible configures:

   * **MySQL Server:** installs, configures bind-address automatically, creates DB + user.
   * **App Server:** installs either **Docker** (for containerized deployment) or **Tomcat/Java** (for JAR deployment).

4. GitHub Actions pipeline:

   * Builds JAR via Maven
   * Replaces MySQL IP dynamically inside `application.properties`
   * Copies files to the App server
   * Runs Ansible for deployment
   * Performs Trivy security scans on both JAR and Docker image

---

## 🏗️ Infrastructure Setup (Terraform)

### 🔹 Key Features

* Provisions **two EC2 instances**:

  * `app-server` → for Tomcat or Docker deployment
  * `mysql-server` → for database

* Configures Security Groups, Key Pairs, and networking.

* Uses **remote backend** for Terraform state:

  ```hcl
  backend "s3" {
    bucket         = "your-tfstate-bucket"
    key            = "springboot-devops-pipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
  ```

* Outputs are used by `tf-to-inventory.py` to generate Ansible inventory dynamically.

---

## ⚙️ Configuration Management (Ansible)

### 📂 Roles

#### 1️⃣ **docker/**

* Installs and configures Docker + dependencies.
* Used when deploying the app as a **Docker container**.

#### 2️⃣ **spring-petclinic/**

* Deploys the Spring Boot app either on:

  * **Tomcat (JAR-based)** deployment, or
  * **Docker (containerized)** deployment.

* **Tomcat-only deployment** can be done by using this modified `tasks/main.yml`:

  ```yaml
  ---
  - name: Install Java 17
    become: yes
    apt:
      name: openjdk-17-jre
      state: present
      update_cache: yes

  - name: Ensure app directory exists
    file:
      path: /opt/spring-petclinic
      state: directory
      mode: '0755'
      owner: ubuntu
      group: ubuntu

  - name: Copy Spring Petclinic JAR to server
    copy:
      src: files/spring-petclinic.jar
      dest: /opt/spring-petclinic/spring-petclinic.jar
      owner: ubuntu
      group: ubuntu
      mode: '0755'

  - name: Copy application.properties to app server
    copy:
      src: files/application.properties
      dest: /opt/spring-petclinic/application.properties
      owner: ubuntu
      group: ubuntu
      mode: '0644'

  - import_tasks: systemd.yml
  ```

#### 3️⃣ **mysql/**

* Installs and configures MySQL.
* Automatically updates bind-address to allow remote connections.
* Creates database, user, and assigns privileges.

---

## 🧠 Dynamic Inventory

The file `scripts/tf-to-inventory.sh` fetches instance IPs from Terraform outputs and generates an Ansible inventory like:

```ini
[mysql]
34.205.63.80 ansible_user=ubuntu

[app]
52.91.42.100 ansible_user=ubuntu

```

This ensures **zero manual inventory management** after Terraform apply.

---

## 🔄 CI/CD Pipeline (GitHub Actions)

### ✅ Workflow Stages

| Stage           | Description                                                                                 |
| --------------- | ------------------------------------------------------------------------------------------- |
| **mysql-setup** | Initializes backend, provisions infra with Terraform, runs MySQL configuration via Ansible. |
| **build-jar**   | Builds Petclinic JAR using Maven, updates DB IP, runs Trivy FS scan, uploads JAR artifact.  |
| **deploy**      | Downloads artifacts, regenerates inventory, deploys app container with Ansible.             |


1. **Terraform Apply**

   * Initializes remote backend (S3 + DynamoDB)
   * Provisions infrastructure

2. **Generate Dynamic Inventory**

   * Runs `tf-to-inventory.sh` to fetch IPs

3. **Configure MySQL Server**

   * Executes Ansible role `mysql`

4. **Build Application**

   * Runs `mvn clean package`
   * Dynamically updates `application.properties` with MySQL private IP

5. **Deploy Application**

   * Runs Ansible role `spring-petclinic` (Tomcat or Docker)

6. **Trivy Scan**

   * Scans JAR and Docker image for vulnerabilities

---

🌐 Accessing the Application

After successful deployment, the workflow prints the App server’s public IP:

Application will be available at: http://<APP_PUBLIC_IP>:8080

## 🧰 Tools & Technologies

| Category            | Tools Used                         |
| ------------------- | ---------------------------------- |
| Infrastructure      | Terraform (AWS EC2, S3, DynamoDB)  |
| Configuration       | Ansible (roles, dynamic inventory) |
| CI/CD Orchestration | GitHub Actions                     |
| App Build           | Maven                              |
| Security Scanning   | Trivy                              |
| Runtime Environment | Java 17, Tomcat / Docker           |
| Database            | MySQL                              |

---

## 🚦 How to Run Locally (Optional)

You can test this setup locally using your own AWS credentials:
🧰 Prerequisites (for local testing)

AWS account with an existing EC2 key pair.

GitHub repository with the following secrets configured:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

SSH_PRIVATE_KEY

KEY_NAME

Terraform ≥ 1.9.0

Ansible ≥ 2.16

Python ≥ 3.8

AWS CLI configured (for backend setup)

```bash
terraform init
terraform apply -auto-approve

bash scripts/tf-to-inventory.sh

ansible-playbook -i inventory mysql.yml
ansible-playbook -i inventory app.yml
```

---

## 🧹 Cleanup

To destroy all infrastructure:

```bash
terraform destroy -auto-approve
```

---

## 🛡️ Security Highlights

* Remote state stored in **S3 + DynamoDB** for reliability and locking
* No hardcoded IPs — everything is dynamically generated
* Application properties and credentials managed securely via Ansible
* Vulnerability scanning integrated in CI/CD with **Trivy**

---

## 📈 Future Enhancements

* Integrate **SonarQube** for static code analysis
* Add **AWS ALB** + **Auto Scaling Group** for high availability
* Add **Monitoring & Alerts** using Prometheus + Grafana

---

## 👤 Author

**Mehziya Shaik**
DevOps Engineer | AWS | Terraform | Ansible | CI/CD | Docker | Kubernetes
🔗 [GitHub Profile](https://github.com/mehziya0352)

