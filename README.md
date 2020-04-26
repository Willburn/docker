1. Building image: Clone the github to a directory and docker build . -t (your tag for example docker build -t local/cardano-node). You might need sudo access if you have not given the right permissions to use docker with your user.
2. You can also just pull the image from my repository https://hub.docker.com/repository/docker/eysteinh/cnode if you do not want to build yourself.
3. To run as a single container you also need to pass the CNODEIPV4 variable and you should also set a public port to the internal 3000 port each container use. example:
docker run -e CNODEIPV4=YOUR-PUBLIC-IP -v /yourlocalfolder/with/config/files:/srv/cardano/cardano-node/config/ -p (publicport):3000 -it (-it if you want to see the container running in an interactive terminal)

