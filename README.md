# **CLO835-K8sAss2: Kubernetes Deployment of a Stateless Application**

## **Overview**
This repository contains Kubernetes manifests and configurations for deploying a stateless web application and a MySQL database on a **Kind-based Kubernetes cluster running on an AWS EC2 instance**. The project includes essential Kubernetes resources such as **Pods, ReplicaSets, Deployments, and Services** to manage the application effectively.

## **Prerequisites**
Ensure you have the following tools installed before proceeding with deployment:
- AWS EC2 instance running Amazon Linux 2
- Docker
- Kind (Kubernetes in Docker)
- Kubectl (Kubernetes CLI)
- AWS CLI (for ECR authentication)

## **Setup Instructions**
### **1️⃣ Set Up the Kind Cluster**

chmod +x init_kind.sh
./init_kind.sh
kubectl cluster-info
kubectl get nodes

### **2️⃣ Create Kubernetes Namespace**

kubectl apply -f mynamespace.yaml
kubectl get namespaces

### **3️⃣ Deploy ConfigMap & Secrets**

kubectl apply -f configmap.yaml
kubectl create secret generic mysql-credentials \
  --from-literal=DBPWD="adminpassword" \
  --namespace=assign2space

### **4️⃣ Deploy MySQL & WebApp Pods**

kubectl apply -f pod_manifests/mysql-pod.yaml
kubectl apply -f pod_manifests/webapp-pod.yaml
kubectl get pods -n assign2space

### **5️⃣ Deploy ReplicaSets**

kubectl apply -f replicaset_manifests/mysql-replicaset.yaml
kubectl apply -f replicaset_manifests/webapp-replicaset.yaml
kubectl get replicasets -n assign2space

### **6️⃣ Deploy MySQL & WebApp Using Deployments**
kubectl apply -f deployment_manifests/mysql-deployment.yaml
kubectl apply -f deployment_manifests/webapp-deployment.yaml
kubectl get deployments -n assign2space

### **7️⃣ Expose Services**
kubectl apply -f service_manifests/mysql-service.yaml
kubectl apply -f service_manifests/webapp-service.yaml
kubectl get services -n assign2space

### **8️⃣ Verify Application Accessibility**
Check the application status by retrieving logs:
kubectl logs -l app=employees -n assign2space
Access the web application using:
curl http://<EC2-PUBLIC-IP>:30000
Or open it in a browser:
http://<EC2-PUBLIC-IP>:30000

## **Updating the Web Application**
1. **Build and Push a New Image**
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 418213695712.dkr.ecr.us-east-1.amazonaws.com
   docker build -t 418213695712.dkr.ecr.us-east-1.amazonaws.com/clo835_assign2:webapp-v0.2 -f Dockerfile .
   docker push 418213695712.dkr.ecr.us-east-1.amazonaws.com/clo835_assign2:webapp-v0.2
2. **Update `webapp-deployment.yaml` to use the new image version:**
   image: 418213695712.dkr.ecr.us-east-1.amazonaws.com/clo835_assign2:webapp-v0.2
3. **Apply the update:**
   kubectl apply -f deployment_manifests/webapp-deployment.yaml
   kubectl rollout restart deployment/webapp-deployment -n assign2space
4. **Verify the new version is running:**
   kubectl get pods -n assign2space
   curl http://<EC2-PUBLIC-IP>:30000