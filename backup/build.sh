# This script builds a Spark image for Kubernetes and deploys it on Minikube.
minikube start --kubernetes-version stable --cpus 8 --memory 12000 --cni calico

eval $(minikube docker-env)

kubectl apply -f spark-k8s.yaml

# Test Spark Pi example with Spark 3.5.0 on Kubernetes - JAR
/opt/spark/bin/spark-submit \
  --master k8s://https://192.168.49.2:8443 \
  --deploy-mode cluster \
  --name sparkpi-test3 \
  --class org.apache.spark.examples.SparkPi \
  --conf spark.kubernetes.namespace=spark \
  --conf spark.kubernetes.driver.pod.name=spark-test3-pi \
  --conf spark.kubernetes.container.image=miguelmanuttupa/pyspark-k8s:3.5.0 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.executor.instances=2 \
  --conf spark.executor.memory=2g \
  --conf spark.executor.cores=1 \
  --conf spark.kubernetes.executor.request.cores=1 \
  --conf spark.kubernetes.memoryOverheadFactor=0.5 \
  --conf spark.driver.memory=1g \
  --verbose \
  local:///opt/spark/examples/jars/spark-examples_2.12-3.5.0.jar 1000

kubectl logs -n spark spark-test3-pi | grep "Pi is roughly"

# Test Spark Pi example with Spark 3.5.0 on Kubernetes - Python
/opt/spark/bin/spark-submit \
  --master k8s://https://192.168.49.2:8443 \
  --deploy-mode cluster \
  --name sparkpi-test4 \
  --conf spark.kubernetes.namespace=spark \
  --conf spark.kubernetes.driver.pod.name=spark-test4-pi \
  --conf spark.kubernetes.container.image=miguelmanuttupa/pyspark-k8s:3.5.0 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.executor.instances=2 \
  --conf spark.executor.memory=2g \
  --conf spark.executor.cores=1 \
  --conf spark.kubernetes.executor.request.cores=1 \
  --conf spark.kubernetes.memoryOverheadFactor=0.5 \
  --conf spark.driver.memory=1g \
  --verbose \
  local:///opt/spark/examples/src/main/python/pi.py 1000

kubectl logs -n spark spark-test4-pi | grep "Pi is roughly"

# Delete pods
kubectl delete pod spark-test3-pi -n spark
kubectl delete pod spark-test4-pi -n spark


helm uninstall jupyterhub --namespace jupyterhub
helm upgrade --cleanup-on-fail \
--install jupyterhub jupyterhub/jupyterhub \
--namespace jupyterhub \
--create-namespace \
--values helm/jupyterhub-values.yaml

kubectl get pods -A -n jupyterhub
kubectl port-forward proxy-8686c6cf75-4wnr6 -n jupyterhub  8001:8000 # Set your pod name



spark-submit \
  --master k8s://https://kubernetes.default.svc \
  --deploy-mode cluster \
  --name sparkpi-test5 \
  --class org.apache.spark.examples.SparkPi \
  --conf spark.kubernetes.namespace=jupyterhub \
  --conf spark.kubernetes.driver.pod.name=spark-test5-pi \
  --conf spark.kubernetes.container.image=miguelmanuttupa/pyspark-k8s:3.5.0 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.executor.instances=2 \
  --conf spark.executor.memory=2g \
  --conf spark.executor.cores=1 \
  --conf spark.kubernetes.executor.request.cores=1 \
  --conf spark.kubernetes.memoryOverheadFactor=0.5 \
  --conf spark.driver.memory=1g \
  --verbose \
  local:///opt/spark/examples/jars/spark-examples_2.12-3.5.0.jar 1000

spark-submit \
  --master k8s://https://kubernetes.default.svc \
  --deploy-mode cluster \
  --name sparkpi-test6 \
  --class org.apache.spark.examples.SparkPi \
  --conf spark.kubernetes.namespace=jupyterhub \
  --conf spark.kubernetes.driver.pod.name=spark-test6-pi \
  --conf spark.kubernetes.container.image=miguelmanuttupa/pyspark-k8s:3.5.0 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.executor.instances=2 \
  --conf spark.executor.memory=2g \
  --conf spark.executor.cores=1 \
  --conf spark.kubernetes.executor.request.cores=1 \
  --conf spark.kubernetes.memoryOverheadFactor=0.5 \
  --conf spark.driver.memory=1g \
  --verbose \
  local:///opt/spark/examples/src/main/python/pi.py 1000