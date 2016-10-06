FROM tomcat:8.0
MAINTAINER "neon-support@nextcentury.com"
# Add the elasticsearch repo, update apt, install the packages, and then clear out all of the caches
RUN mkdir /etc/sources.list.d && \
    wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list && \
    apt-get update && \
    apt-get install -y --fix-missing mongodb-server elasticsearch openjdk-7-jdk supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Get the war files in place
COPY ["neon.war", "neon-gtd.war", "/usr/local/tomcat/webapps/"]
RUN cd /usr/local/tomcat/webapps && \
    mkdir neon neon-gtd && \
    cd neon && \
    jar xf ../neon.war && \
    cd ../neon-gtd && \
    jar xf ../neon-gtd.war
# Load the data into Elasticsearch and MongoDB
COPY ["elasticsearch.yml", "/etc/elasticsearch/"]
COPY ["mongodb.conf", "/etc/"]
COPY ["data/elasticsearch/snapshots/", "/var/backups/snapshots/"]
COPY ["data/mongo-earthquakes-test", "/root/mongo-earthquakes-test/"]
RUN chown -R elasticsearch:elasticsearch /var/backups/snapshots/ && \
    service elasticsearch start && \
    service mongodb start && \
    sleep 15 && \
    curl -XPUT 'localhost:9200/_snapshot/my_backup' -d '{"type": "fs", "settings": {"location": "/var/backups/snapshots/my_backup/", "compress": true}}' && \
    curl -XPOST localhost:9200/_snapshot/my_backup/snapshot_1/_restore?wait_for_completion=true && \
    mongorestore /root/mongo-earthquakes-test/ && \
    sleep 5
# Put final config files in place
COPY ["config.yaml", "/usr/local/tomcat/webapps/neon-gtd/app/app/config/"]
COPY ["supervisord.conf", "/etc/"]
# Port 8888 is Tomcat, 9200 and 9300 are Elasticsearch, and 27017 is MongoDB
EXPOSE 8080
# supervisord will start Tomcat, Elasticsearch, and MongoDB
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
