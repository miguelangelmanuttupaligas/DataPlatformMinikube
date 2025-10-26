# Pasos para automatizar Notebooks en Airflow

## Cambios a la plataforma antes de la automatizacion
- Modificación a "06.01_jupyterhub_accounts.yaml"
- Modificación a "08.02_airflow_accounts.yaml"
- Modificación a "08.04_helm_airflow_values.yaml"


## (Opcional) Crear datos en SQL Server

```sql
CREATE DATABASE origendemo;
USE origendemo;

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE
);
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100),
    Price DECIMAL(10, 2),
    StockQuantity INT
);

INSERT INTO Users (FirstName, LastName, Email) VALUES
('John', 'Doe', 'john.doe@example.com'),
('Jane', 'Smith', 'jane.smith@example.com'),
('Peter', 'Jones', 'peter.jones@example.com');
INSERT INTO Products (ProductName, Price, StockQuantity) VALUES
('Laptop', 1200.00, 50),
('Mouse', 25.50, 200),
('Keyboard', 75.00, 100);

```

## Clonar repositorio en Jupyter Notebook

Clonar repositorio Cmachyo-Lakehouse, y realizar los arreglos que se encontrarán en la fuente "origendemo". Los cambios son:

1. Reemplazar la ruta relativa ".." por "../.." en las primeras lineas de los notebooks, ya que se agregó una jerarquía adicional de carpetas "ddl" y "etl"
2. En los notebooks que empiecen por ETL se agrega más variables que reciben su valor por variables de entorno, esto para habilitar el dinamismo de origenes desde Airflow
3. En la carpeta utils/spark.py se agregaron validaciones y la configuración de hive metastore

---Cmachyo-Lakehouse/
    |---src/
        |----brz/
            |---origendemo/
                |--Dockerfile
                |---users/
                |   |---ddl/
                |   |   |---brz_origendemo_users_ddl.ipynb
                |   |---etl/
                |       |---brz_origendemo_users_etl.ipynb
                |---products/
                |   |---ddl/
                |   |---brz_origendemo_products_ddl.ipynb
                |   |---etl/
                |       |---brz_origendemo_products_etl.ipynb
                |---utils/

## Convertir Notebooks a Python Scripts

```sh
# Situarse en la ruta:
cd /home/usuario1/Cmachyo-Lakehouse/src/brz/origendemo
# Ejecutará la conversión recursiva de notebooks a python
# Esto funciona para la mayoría de casos, salvo donde se usen celdas mágicas cuyo contenido no sea código python como los %%sparksql
find . -type f -name "*.ipynb" -exec jupyter nbconvert --to python {} \;
```

## Crear Dockerfile, .dockerignore y requirements.txt

```sh
# Situarse en la ruta:
cd /home/usuario1/Cmachyo-Lakehouse/src/brz/origendemo

touch Dockerfile

#FROM miguelmanuttupa/pyspark-k8s-python3.11:3.5.0
#ARG APP_DIR=/opt/spark/app
#WORKDIR ${APP_DIR}
#COPY . ${APP_DIR}
#USER root
#RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi
#USER 185

cat > .dockerignore << 'EOF'
__pycache__/
.ipynb_checkpoints/
*.ipynb
*.parquet
*.csv
*.log
.env
.git
EOF

touch requirements.txt
# Agregar las librerias extra si se usaron
```

## Subir cambios a Repositorio

## Descargar repositorio en un ambiente con Docker y generar imágen

```sh
git clone git@github.com:Atokongo-Technologies/Cmachyo-Lakehouse.git
cd Cmachyo-Lakehouse/src/brz/origendemo

docker build -f Dockerfile -t miguelmanuttupa/lchcimage-brz-origendemo .
docker push miguelmanuttupa/lchcimage-brz-origendemo
```

## Construir DAG en Python

Ver archivo origendemo-malla.py

## Ver Repositorio de Notebooks
- https://github.com/Atokongo-Technologies/Cmachyo-Lakehouse/tree/main/src/brz/origendemo

## Ver Repositorio de DAGS
- https://github.com/miguelangelmanuttupaligas/dags-sync/tree/master

## Ver Repositorio de Imagenes
- https://hub.docker.com/repository/docker/miguelmanuttupa/lchcimage-brz-origendemo/general

## Ver Repositorio de Plataforma de datos
- 