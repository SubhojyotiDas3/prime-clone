Amazon Prime Clone Deployment Project
Overview
This project demonstrates how to deploy an Amazon Prime Video Clone application using a complete DevOps workflow. It showcases a modern CI/CD pipeline, leveraging powerful tools and technologies to ensure efficient, secure, and scalable deployments.

Key Technologies Used:
Terraform: Infrastructure as Code (IaC) for provisioning AWS resources like EC2 instances and EKS clusters.
GitHub: Source code version control.
Jenkins: CI/CD automation for build and deployment.
SonarQube: Static code analysis and quality gates.
NPM: Node.js package manager and build tool.
Trivy: Security vulnerability scanner for containerized applications.
Docker: Containerization to package the application.
AWS ECR: Docker image repository.
AWS EKS: Kubernetes-based container management service.
ArgoCD: Continuous delivery for Kubernetes applications.
Prometheus & Grafana: Monitoring and alerting tools for infrastructure health.

Pre-requisites
AWS Account: Create AWS Account.
AWS CLI: Install AWS CLI.
VS Code (Optional): Download VS Code.
Terraform: Install Terraform.


Project Workflow
1. AWS Setup
Create IAM User: Generate an access key and secret key for AWS CLI configuration.
Key Pair: Manually create a .pem key named key to enable secure SSH access.
2. Infrastructure Setup with Terraform
Clone the repository and navigate to the project directory:
bash
Copy code
git clone https://github.com/yourrepo/AmazonPrimeClone.git
cd AmazonPrimeClone
code .
Initialize and apply the Terraform configuration:
bash
Copy code
aws configure
terraform init
terraform apply --auto-approve
This step creates the Jenkins server, security groups, and other required resources.

3. Configure Jenkins
Add Credentials: Add AWS access keys and SonarQube tokens in Manage Jenkins → Credentials → System → Global Credentials.
Install Plugins: Install essential Jenkins plugins such as:
SonarQube Scanner
NodeJS
Docker
Pipeline Stage View
Prometheus Metrics
Global Tools Setup: Configure:
JDK 17
NodeJS (16.20.0)
SonarQube Scanner
Docker (Latest Version)
Pipeline Workflow
Pipeline Stages:
Git Checkout: Clone the source code from GitHub.
SonarQube Analysis: Perform static code analysis to ensure quality.
Quality Gate: Enforce code quality standards before proceeding.
Install NPM Dependencies: Install necessary Node.js packages.
Trivy Scan: Scan for vulnerabilities in the application.
Docker Build: Build a Docker image for the application.
Push to AWS ECR: Push Docker images to a private ECR repository.
Image Cleanup: Remove local Docker images from the Jenkins server to free up space.
Jenkins Pipeline Script
Add the following script to Jenkins to implement the pipeline:

groovy
Copy code
pipeline {
    agent any

    parameters {
        string(name: 'ECR_REPO_NAME', defaultValue: 'amazon-prime', description: 'Enter ECR Repository Name')
        string(name: 'AWS_ACCOUNT_ID', defaultValue: '123456789012', description: 'Enter AWS Account ID')
    }

    tools {
        jdk 'JDK 17'
        nodejs 'NodeJS 16.20.0'
    }

    environment {
        SCANNER_HOME = tool 'SonarQube Scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/yourrepo/AmazonPrimeClone.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=amazon-prime \
                    -Dsonar.projectKey=amazon-prime
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: true
            }
        }

        stage('Install npm Dependencies') {
            steps {
                sh "npm install"
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy fs . > trivy-results.txt"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${params.ECR_REPO_NAME} ."
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([string(credentialsId: 'access-key', variable: 'AWS_ACCESS_KEY'),
                                 string(credentialsId: 'secret-key', variable: 'AWS_SECRET_KEY')]) {
                    sh """
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
                    docker tag ${params.ECR_REPO_NAME} ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                    docker push ${params.AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/${params.ECR_REPO_NAME}:latest
                    """
                }
            }
        }

        stage('Image Cleanup') {
            steps {
                sh "docker rmi ${params.ECR_REPO_NAME}"
            }
        }
    }
}
Continuous Deployment with ArgoCD
EKS Cluster: Use Terraform to create an EKS cluster.
Deploy App: Configure ArgoCD to deploy the Amazon Prime clone on Kubernetes.
Monitoring: Install Prometheus and Grafana for infrastructure monitoring and alerting.
Monitoring Tools
Prometheus: Access Prometheus dashboards for resource metrics.
Grafana: Visualize cluster health and performance using Grafana dashboards.
Cleanup
To remove all resources, run:

bash
Copy code
terraform destroy
Conclusion
This project demonstrates the power of integrating DevOps tools for automating deployments. With tools like Terraform, Jenkins, and Kubernetes, we ensure a robust, scalable, and secure deployment process for applications like an Amazon Prime Video Clone.

