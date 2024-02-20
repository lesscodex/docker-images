FROM docker.elastic.co/logstash/logstash:7.13.2

RUN ./bin/logstash-plugin install logstash-output-logservice