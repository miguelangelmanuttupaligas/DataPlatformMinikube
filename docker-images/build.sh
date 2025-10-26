cd docker-images

# Create Pyspark notebook image with Spark 3.5.0, Delta Lake 2.3.0 and Support S3
docker build -f Dockerfile.pyspark-notebook -t miguelmanuttupa/pyspark-notebook:3.5.0.1 .
docker push miguelmanuttupa/pyspark-notebook:3.5.0.1

# Create Pyspark K8S image with Spark 3.5.0, Delta Lake 2.3.0 and Support S3
mkdir -p ./spark

curl -L https://mirror.lyrahosting.com/apache/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz \
| sudo tar -xz -C ./spark --strip-components=1

# Add command Spark Jar to the image
cp Dockerfile.pyspark-k8s-python3.11 ./spark/kubernetes/dockerfiles/spark/bindings/python/Dockerfile
docker build -f ./spark/kubernetes/dockerfiles/spark/bindings/python/Dockerfile -t miguelmanuttupa/pyspark-k8s-python3.11:3.5.0 ./spark
docker push miguelmanuttupa/pyspark-k8s-python3.11:3.5.0

rm -rf ./spark

# Create Airflow K8s image with Support Spark 3.5
docker build -f Dockerfile.airflow -t miguelmanuttupa/airflow-k8s:3.0.2 .

# Create Kyuubi K8s image with Spark 3.5.0
mkdir -p ./kyuubi
curl -L https://dlcdn.apache.org/kyuubi/kyuubi-1.10.2/apache-kyuubi-1.10.2-bin.tgz | sudo tar -xz -C ./kyuubi --strip-components=1
export KYUUBI_HOME=$(pwd)/kyuubi
${KYUUBI_HOME}/bin/docker-image-tool.sh -r miguelmanuttupa/kyuubi-k8s -t 1.10.2 -b BASE_IMAGE=miguelmanuttupa/pyspark-k8s-python3.11:3.5.0 build
docker tag miguelmanuttupa/kyuubi-k8s:1.10.2 miguelmanuttupa/kyuubi-k8s:1.10.2
docker push miguelmanuttupa/kyuubi-k8s:1.10.2