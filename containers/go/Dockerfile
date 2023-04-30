FROM debian:latest

LABEL maintainer="Akkadius <akkadius1@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

ENV TZ=US/Central

#############################################
# non-root user (go)
#############################################
RUN apt-get update -yqq && \
    groupadd -g ${PGID} go && \
    useradd -u ${PUID} -g go -m go -G go && \
    usermod -p "*" go

RUN apt-get update && apt-get install -y sudo

RUN echo "go ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

ENV GO_VERSION 1.19.1

#############################################
# install dependencies
#############################################
RUN apt-get update && apt-get install -y \
    tree \
    wget \
    procps \
 && rm -rf /var/lib/apt/lists/*

#############################################
# install go
#############################################
RUN cd /tmp && wget --quiet https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
	&& tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && rm -rf /tmp/*

RUN mkdir -p /home/go && chown go:go /home/go

#############################################
# set go env vars
# https://golang.org/doc/code.html
#############################################
ENV GOPATH=/home/go
ENV GOROOT=/usr/local/go/
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
ENV CGO_ENABLED 0

USER go

#############################################
# user
#############################################
USER go
WORKDIR /home/go

CMD /bin/bash