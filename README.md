# Despliegue de plataforma de datos open source en Kubernetes (Minikube)

## Instalar

- Kubectl
- Helm

## Despliegue de Cluster Kubernetes

```sh
minikube start \
  --cpus=10 \
  --memory=18000 \
  --cni=calico \
  --driver=docker
```

## Instalación temporal de mc (MinIO Client)

```sh
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

mc --help
```

## Creación de carpetas en Minikube

```sh
minikube ssh
sudo su
cd /mnt/
mkdir nfs-minio
mkdir nfs-postgres-dev-metastore
mkdir nfs-postgres-prd-metastore
mkdir nfs-postgres-jhub
mkdir nfs-postgres-airflow
mkdir nfs-logs-airflow
chown 50000:0 /mnt/nfs-logs-airflow
chmod 775 /mnt/nfs-logs-airflow
exit
exit
```

## Despliegue de Servicios

```sh
# Namespaces
kubectl apply -f deployments/01.01_namespaces.yaml
```

```sh
# OpenLDAP
kubectl apply -f deployments/01.02_openldap.yaml
```

```sh
# MinIO Single Instance -  Single Volume
kubectl apply -f deployments/02.01_minio_configmap.yaml
kubectl apply -f deployments/02.01_minio_secret.yaml
kubectl apply -f deployments/02.02_minio.yaml
kubectl apply -f deployments/02.03_minio_services.yaml

# Wait for the pod to display
# Create connection with mc
mc alias set local http://$(minikube ip):30900 as9824fASD29SDGLKJ v1sdf8a9s8df7a9s8df7a9s8df7

# Attach policies for auth with openldap
mc idp ldap policy attach local readwrite --group='cn=devs,ou=DataModelers,ou=DataAnalytics,ou=Groups,dc=cajafinanciera,dc=com'
mc idp ldap policy attach local consoleAdmin --group='cn=admins,ou=DataModelers,ou=DataAnalytics,ou=Groups,dc=cajafinanciera,dc=com'

mc admin user svcacct add local as9824fASD29SDGLKJ --access-key hive-key-dev-4g78923 --secret-key hive-secret-dev-d249824g98 --policy deployments/policies_minio/readwrite.json
mc admin user svcacct add local as9824fASD29SDGLKJ --access-key hive-key-prd-132fsad --secret-key hive-secret-prd-13rfsdfsadf --policy deployments/policies_minio/readwrite.json
mc admin user svcacct add local as9824fASD29SDGLKJ --access-key kyuubi-key-dev-fsd78 --secret-key kyuubi-secret-dev-7u8123dhi --policy deployments/policies_minio/readwrite.json
mc admin user svcacct add local as9824fASD29SDGLKJ --access-key kyuubi-key-prd-35yg4 --secret-key kyuubi-secret-prd-34gsdfsa --policy deployments/policies_minio/readwrite.json
```

```sh
##########################################################################################
##########################################################################################
#################################### DEV ENVIRONMENT #####################################
##########################################################################################
##########################################################################################

# Postgres Metastore DEV
kubectl apply -f deployments/03.01_pg_metastore_dev_configmap.yaml
kubectl apply -f deployments/03.01_pg_metastore_dev_secret.yaml
kubectl apply -f deployments/03.02_pg_metastore_dev.yaml
kubectl apply -f deployments/03.03_pg_metastore_dev_services.yaml

# Hive Metastore DEV
kubectl apply -f deployments/04.01_hive_metastore_dev_configmap.yaml
kubectl apply -f deployments/04.01_hive_metastore_dev_secret.yaml
kubectl apply -f deployments/04.02_hive_metastore_dev.yaml
kubectl apply -f deployments/04.03_hive_metastore_dev_services.yaml

# Postgres Jupyterhub
kubectl apply -f deployments/05.01_pg_jupyterhub_configmap.yaml
kubectl apply -f deployments/05.01_pg_jupyterhub_secret.yaml
kubectl apply -f deployments/05.02_pg_jupyterhub.yaml
kubectl apply -f deployments/05.03_pg_jupyterhub_services.yaml

# Service Accounts / Jupyterhub
kubectl apply -f deployments/06.01_jupyterhub_accounts.yaml

# Helm JupyterHub
helm repo add jupyterhub https://hub.jupyter.org/helm-chart/
helm repo update
helm upgrade --install jhub jupyterhub/jupyterhub --namespace jupyterhub --values deployments/06.02_helm_jupyterhub_values.yaml --timeout 15m --wait

# Apache Kyuubi - Dev Environment
kubectl create serviceaccount kyuubi --namespace=kyuubi
kubectl create clusterrolebinding kyuubi-role --clusterrole=edit --serviceaccount=kyuubi:kyuubi --namespace=kyuubi
#helm install kyuubi deployments/kyuubi -n kyuubi -f deployments/09.02_helm_kyuubi.yaml
helm upgrade --install kyuubi deployments/kyuubi -n kyuubi -f deployments/09.02_helm_kyuubi.yaml --timeout 15m --wait

##########################################################################################
##########################################################################################
################################### PROD ENVIRONMENT #####################################
##########################################################################################
##########################################################################################
# Postgres Metastore PRD
kubectl apply -f deployments/03.01_pg_metastore_prd_configmap.yaml
kubectl apply -f deployments/03.01_pg_metastore_prd_secret.yaml
kubectl apply -f deployments/03.02_pg_metastore_prd.yaml
kubectl apply -f deployments/03.03_pg_metastore_prd_services.yaml

# Hive Metastore PRD
kubectl apply -f deployments/04.01_hive_metastore_prd_configmap.yaml
kubectl apply -f deployments/04.01_hive_metastore_prd_secret.yaml
kubectl apply -f deployments/04.02_hive_metastore_prd.yaml
kubectl apply -f deployments/04.03_hive_metastore_prd_services.yaml

# Postgres Airflow
kubectl apply -f deployments/07.01_pg_airflow_configmap.yaml
kubectl apply -f deployments/07.01_pg_airflow_secret.yaml
kubectl apply -f deployments/07.02_pg_airflow.yaml
kubectl apply -f deployments/07.03_pg_airflow_services.yaml
# Pre Airflow
kubectl apply -f deployments/08.01_airflow_secrets.yaml
kubectl apply -f deployments/08.02_airflow_accounts.yaml
kubectl apply -f deployments/08.03_airflow_pv.yaml
# Helm Airflow
helm repo add apache-airflow https://airflow.apache.org
helm repo update
helm upgrade --install airflow apache-airflow/airflow --namespace airflow -f deployments/08.04_helm_airflow_values.yaml
# Apache Kyuubi
kubectl create serviceaccount kyuubi-prd --namespace=kyuubi-prd
kubectl create clusterrolebinding kyuubi-prd-role --clusterrole=edit --serviceaccount=kyuubi-prd:kyuubi-prd --namespace=kyuubi-prd
#helm install kyuubi deployments/kyuubi -n kyuubi -f deployments/09.02_helm_kyuubi.yaml
helm upgrade --install kyuubi deployments/kyuubi -n kyuubi-prd -f deployments/09.02_helm_kyuubi_prd.yaml --timeout 15m --wait

# [OPTIONAL] SQL Server
kubectl apply -f deployments/10.01_sqlserver.yaml
```

## Creación de Connections en Airflow (De momento, paso manual)
- Logueo en UI:
  - Admin
    - Connections
      - Add Connection
        - connection_id: spark_conn
        - connection_type: spark
        - standard_fields:
          - host: k8s://https://kubernetes.default
          - port: 443
        - extra_fields:
          - deploy_mode: cluster
          - spark_binary: spark-submit
          - kubernetes_namespace: airflow