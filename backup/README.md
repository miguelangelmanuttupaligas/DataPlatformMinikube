# Modo de ejecución

- Ejecutar JupyterHub on K8s y relacionados 

```bash
kubectl apply -f deployment/namespace.yaml
kubectl apply -f deployment/storage/minio-bitnami.yaml
kubectl apply -f deployment/storage/postgres-jupyterhub.yaml
kubectl apply -f deployment/storage/postgres-metastore.yaml
kubectl apply -f deployment/storage/hive-metastore.yaml
kubectl apply -f deployment/process/jupyterhub-helm/jupyterhub-sa.yaml
kubectl apply -f deployment/process/jupyterhub-helm/spark-sa.yaml
helm upgrade --install jhub jupyterhub/jupyterhub --namespace jupyterhub --values deployment/process/jupyterhub-helm/jupyterhub-values.yaml
```
- Exponer puertos de acuerdo al Proxy de JupyterHub y NodePort de MinIO 

- Ignorar docker-images. Contiene comandos usados para crear las imagenes ya subidas en un repo publico
- Ignorar build.sh. Contiene comandos de prueba Spark on Kubernetes
