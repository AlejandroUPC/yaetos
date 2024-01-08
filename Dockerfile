FROM docker.io/bitnami/spark:3.5.0
# docker.io/bitnami/spark:3.1.3 -> spark 3.1.3, python 3.8.13, scala 2.12.10, https://github.com/bitnami/bitnami-docker-spark, https://hub.docker.com/r/bitnami/spark
# docker.io/bitnami/spark:3.5.0 -> spark 3.5.0, python 3.8.15, scala 2.xxx, https://github.com/bitnami/containers/tree/main/bitnami/spark, https://hub.docker.com/r/bitnami/spark
USER root


# Lib installs. Using local copy to tmp dir to allow checkpointing this step (no re-installs as long as requirements_base.txt doesn't change)
COPY yaetos/scripts/requirements_base.txt /tmp/requirements.txt
COPY yaetos/scripts/requirements_dev.txt /tmp/requirements_dev.txt
COPY conf/requirements_extra.txt /tmp/requirements_extra.txt

WORKDIR /tmp/
RUN apt update \
  && apt install -y git \
  && apt install -y g++ \
  && apt install -y nodejs
# 2 lines above for jupyterlab
RUN python -m pip install --upgrade pip \
  && pip3 install -r requirements.txt \
  && pip3 install -r requirements_dev.txt \
  && pip3 install -r requirements_extra.txt


WORKDIR /mnt/yaetos

ENV YAETOS_FRAMEWORK_HOME /mnt/yaetos/
ENV PYTHONPATH $YAETOS_FRAMEWORK_HOME:$PYTHONPATH
# ENV SPARK_HOME /usr/local/spark # already set in base docker image
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/build:$PYTHONPATH

ENV YAETOS_JOBS_HOME /mnt/yaetos_jobs/
ENV PYTHONPATH $YAETOS_JOBS_HOME:$PYTHONPATH

# Expose ports for monitoring.
# SparkContext web UI on 4040 -- only available for the duration of the application.
# Spark master’s web UI on 8080.
# Spark worker web UI on 8081.
# Jupyter web UI on 8888.
EXPOSE 4040 8080 8081 8888

# CMD ["/bin/bash"] # commented so the command can be sent by docker run

# Usage: docker run -it -p 4040:4040 -p 8080:8080 -p 8081:8081 -v ~/code/yaetos:/mnt/yaetos -v ~/.aws:/root/.aws -h spark <image_id>
# or update launch_env.sh and execute it.
