FROM ubuntu:xenial

# Inspired by https://github.com/proofengineering/coq-docker/blob/master/Dockerfile-xenial-coq8.5

RUN apt-get -qqy update \
    && apt-get -qqy install software-properties-common git make m4 aspcud ocaml opam libgmp3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && opam init --compiler=4.02.0 --yes --auto-setup \
    && eval `opam config env` \
    && opam repo add coq-released https://coq.inria.fr/opam/released
# We need ocaml 8.4.5
RUN opam pin add coq 8.4.5 --yes
# file `configure` mentions menhir version 20151110
RUN opam pin add menhir 20151112 --yes
RUN opam install menhir --yes

# For zarith, nothing is mentionned
RUN opam install zarith --yes
RUN opam install ocamlfind --yes

# Let's download verasco 1.3
RUN mkdir ~/verasco \
    && wget -qO- http://compcert.inria.fr/verasco/release/verasco-1.3.tgz | tar xvz -C ~/verasco

# First do proof only (then docker makes a snapshoot)
# opam binaries seems not to be in $path
RUN export PATH="$PATH:/root/.opam/4.02.0/bin/" \
    && eval `opam config env` \
    && cd ~/verasco/verasco* \
    && ./configure ia32-linux \
    && make proof


RUN export PATH="$PATH:/root/.opam/4.02.0/bin/" \
    && eval `opam config env` \
    && cd ~/verasco/verasco* \
    && ./configure ia32-linux \
    && make

USER root
RUN apt-get -qqy update && apt-get install -qqy openssh-server
RUN mkdir /var/run/sshd
RUN mkdir /root/workdir
RUN echo 'root:hello' | chpasswd

RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
VOLUME /root/workdir

RUN echo "PATH=\"\$PATH:/root/verasco/verasco-1.3/\"" >> /root/.profile

CMD ["/usr/sbin/sshd", "-D"]