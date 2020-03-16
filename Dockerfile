FROM docker.elastic.co/elasticsearch/elasticsearch:7.5.2

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

RUN sed -i -E "s/(8:-XX:NumberOfGCLogFiles=)\w+/\14/" /usr/share/elasticsearch/config/jvm.options \
  && sed -i -E "s/(9-:-Xlog:gc.+filecount=)[^:,]+(.*)/\14\2/" /usr/share/elasticsearch/config/jvm.options 
