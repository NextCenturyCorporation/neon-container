This is the build information to make a container that includes Neon, Neon GTD, Elasticsearch, and
MongoDB, along with some sample earthquake data to try out Neon. To build it, run

docker build --tag neon-qs .

Then run it with

docker run -p 8080:8080 neon-qs

And point your web browser to http://localhost:8080/neon-gtd/app/
