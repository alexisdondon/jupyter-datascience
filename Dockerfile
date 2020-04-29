FROM jupyter/datascience-notebook:lab-1.2.5

USER root

# checksum source for libmesos-bundle: https://downloads.mesosphere.com/libmesos-bundle/libmesos-bundle-1.14-alpha.tar.gz.sha256
ARG HADOOP_HOME="/opt/hadoop"
ARG HADOOP_MAJOR_VERSION="3.2"
ARG HADOOP_SHA256="2d62709c3d7144fcaafc60e18d0fa03d7d477cc813e45526f3646030cd87dbf010aeccf3f4ce795b57b08d2884b3a55f91fe9d74ac144992d2dfe444a4bbf34ee"
ARG HADOOP_URL="https://downloads.apache.org/hadoop/common/hadoop-3.2.1/"
ARG HADOOP_VERSION=3.2.1
ARG HADOOP_AWS_URL="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws"
ARG SPARK_URL="https://downloads.apache.org/spark/spark-2.4.5/"
ARG SPARK_VERSION=2.4.5

ENV SPARK_HOME="/opt/spark"

RUN apt-get -y update && \
    apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p $HADOOP_HOME $SPARK_HOME

RUN cd /tmp \
    && wget ${HADOOP_URL}hadoop-${HADOOP_VERSION}.tar.gz \
    && tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C $HADOOP_HOME --owner root --group root --no-same-owner --strip-components=1 \
    && wget ${HADOOP_AWS_URL}/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar \
    && mkdir -p $HADOOP_HOME/share/lib/common/lib \
    && mv hadoop-aws-${HADOOP_VERSION}.jar $HADOOP_HOME/share/lib/common/lib \
    && wget ${SPARK_URL}spark-${SPARK_VERSION}-bin-without-hadoop.tgz \
    && tar xzf spark-${SPARK_VERSION}-bin-without-hadoop.tgz -C $SPARK_HOME --owner root --group root --no-same-owner --strip-components=1 \
    && rm -rf /tmp/*

RUN pip install s3fs

RUN pip install jupyterlab-git jupyterlab_latex & \
    jupyter labextension install --no-build @jupyterlab/git @jupyterlab/latex & \
    jupyter serverextension enable --sys-prefix jupyterlab_latex jupyterlab_git

RUN jupyter lab build

VOLUME ["/home/jovyan"]