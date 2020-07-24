FROM docker.elastic.co/elasticsearch/elasticsearch:7.8.0

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/mintel/eck-elasticsearch-image" \
      org.label-schema.schema-version="1.0.0-rc1" \
      org.label-schema.name="eck-elasticsearch-image" \
      org.label-schema.description="An elasticsearch image to be used in eck bundling the plugins we use" \
      org.label-schema.vendor="Mintel LTD" \
      maintainer="Francesco Ciocchetti <fciocchetti@mintel.com>"

RUN set -ex \
    && bin/elasticsearch-plugin install --batch repository-gcs \
    && bin/elasticsearch-plugin install --batch repository-s3

# Reduce the number of rotated JVM GC logs we keep to avoid filling k8s ephemeral storage
RUN sed -r "s/NumberOfGCLogFiles=[0-9]+/NumberOfGCLogFiles=4/" -i /usr/share/elasticsearch/config/jvm.options \
  && sed -r "s/filecount=[0-9]+,filesize=[0-9]+[kmg]/filecount=4,filesize=64m/" -i /usr/share/elasticsearch/config/jvm.options
