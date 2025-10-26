Asumiendo que la IP donde se expondra MinIO sea: 192.168.2.90:9000
Asumiendo que la IP donde se expondran los servicios de K8s sea: 192.168.2.100

Pasos:
1. Eliminar 02.01_minio_configmap.yaml
2. Eliminar 02.01_minio_secret.yaml
3. Eliminar 02.02_minio.yaml
4. Eliminar 02.03_minio_services.yaml

5. Establecer dentro de la configuracion de MinIO NFS
      MINIO_ROOT_USER=as9824fASD29SDGLKJ
      MINIO_ROOT_PASSWORD=v1sdf8a9s8df7a9s8df7a9s8df7
      MINIO_IDENTITY_LDAP_LOOKUP_BIND_PASSWORD: "24f98ifwe9ua"
      MINIO_IDENTITY_LDAP_SERVER_ADDR: "openldap.data-services.svc.cluster.local:389" #192.168.2.100:31389 Reemplazar por IP del servicio expuesto
      MINIO_IDENTITY_LDAP_LOOKUP_BIND_DN: "cn=ldapreader24g890uwef,ou=Users,dc=cajafinanciera,dc=com"
      MINIO_IDENTITY_LDAP_USER_DN_SEARCH_BASE_DN: "ou=Users,dc=cajafinanciera,dc=com"
      MINIO_IDENTITY_LDAP_USER_DN_SEARCH_FILTER: "(uid=%s)"
      MINIO_IDENTITY_LDAP_GROUP_SEARCH_BASE_DN: "ou=DataModelers,ou=DataAnalytics,ou=Groups,dc=cajafinanciera,dc=com"
      MINIO_IDENTITY_LDAP_GROUP_SEARCH_FILTER: "(&(objectClass=groupOfNames)(member=%d))"
      MINIO_IDENTITY_LDAP_TLS_SKIP_VERIFY: "on"
      MINIO_IDENTITY_LDAP_SERVER_INSECURE: "on"

6. Conectarse a MinIO desde MC (Debe volverse un script que se ejecuta posterior a inicializar MinIO)
      export MC_ALIAS_USER="${MINIO_ROOT_USER}" && \
      export MC_ALIAS_PASS="${MINIO_ROOT_PASSWORD}" && \
      sleep 5 && \
      mc alias set local http://localhost:9000 "$MC_ALIAS_USER" "$MC_ALIAS_PASS" && \
      mc admin config reset local identity_openid:_ && \
      mc mb local/warehouse-dev || true && \
      mc mb local/warehouse-prd || true && \
      mc mb local/kyuubi || true && \
      mc mb local/lhchdev || true && \
      mc mb local/lhchprd || true

7. Modificar en 04.01_hive_metastore_dev_configmap.yaml
      S3_ENDPOINT: http://minio.data-services.svc.cluster.local:9000
      S3_ENDPOINT: http://192.168.2.90:9000

8. Modificar en 04.01_hive_metastore_prd_configmap.yaml
      S3_ENDPOINT: http://minio.data-services.svc.cluster.local:9000
      S3_ENDPOINT: http://192.168.2.90:9000

9. Modificar 06.02_helm_jupyterhub_values.yaml -> Linea 97
      S3_ENDPOINT_URL: "http://minio.data-services.svc.cluster.local:9000"
      S3_ENDPOINT_URL: "http://192.168.2.90:9000"

10. Modificar 08.04_helm_airflow_values.yaml -> Linea 50
      S3_ENDPOINT_URL: "http://minio.data-services.svc.cluster.local:9000"
      S3_ENDPOINT_URL: "http://192.168.2.90:9000"

11. Modificar 09.02_helm_kyuubi_prd.yaml -> Linea 95
      spark.hadoop.fs.s3a.endpoint=http://minio.data-services.svc.cluster.local:9000
      spark.hadoop.fs.s3a.endpoint=http://192.168.2.90:9000

12. Modificar 09.02_helm_kyuubi.yaml -> Linea 95
      spark.hadoop.fs.s3a.endpoint=http://minio.data-services.svc.cluster.local:9000
      spark.hadoop.fs.s3a.endpoint=http://192.168.2.90:9000


