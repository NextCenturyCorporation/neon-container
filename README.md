This is the build information to make a container that includes Neon, Neon GTD, Elasticsearch, and
MongoDB, along with some sample earthquake data to try out Neon. To build it, run

    docker build --tag neon-qs .

Then run it with

    docker run -p 8080:8080 neon-qs

And point your web browser to <http://localhost:8080/neon-gtd/app/>

If you want to access the MongoDB and Elasticsearch so that you can load your own data, you need to
expose those ports when you run the container, like this

    docker run -p 8080:8080 -p 9200:9200 -p 27017:27017 neon-qs

Finally, if you want create your own dashboard configurations, you will need to put them in a
directory and mount that directory when you run docker use the `-v` option, like this

    docker run -p 8080:8080 -v /path/to/config-directory/:/usr/local/tomcat/webapps/neon-gtd/app/app/config/ neon-qs
