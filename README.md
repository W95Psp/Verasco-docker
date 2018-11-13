# Verasco-docker
Ready to use docker image for Verasco

Inspired by https://github.com/proofengineering/coq-docker/blob/master/Dockerfile-xenial-coq8.5

 - Verasco 1.3, in root's path
 - SSH, password `hello`

`create.sh` creates a new docker with bindings (a working directory, and port 223 for SSH), and then put current user's SSH public key in `root`'s `authorized_keys` file on the docker.