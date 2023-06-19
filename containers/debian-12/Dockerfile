FROM debian:12-slim

LABEL maintainer="Akkadius <akkadius1@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

ENV TZ=US/Central

#############################################
# non-root user (eqemu)
#############################################
RUN apt-get update -yqq && \
    groupadd -g ${PGID} eqemu && \
    useradd -u ${PUID} -g eqemu -m eqemu -G eqemu && \
    usermod -p "*" eqemu

RUN apt-get update && apt-get install -y sudo

RUN echo "eqemu ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

ENV GO_VERSION 1.19.1

#############################################
# install dependencies
#############################################
RUN apt-get update && apt-get install -y \
    tree \
    wget \
    procps \
    default-jre \
 && rm -rf /var/lib/apt/lists/*

#############################################
# install go
#############################################
RUN cd /tmp && wget --quiet https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
	&& tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && rm -rf /tmp/*

RUN mkdir -p /home/go && chown eqemu:eqemu /home/go

#############################################
# set go env vars
# https://golang.org/doc/code.html
#############################################
ENV GOPATH=/home/go
ENV GOROOT=/usr/local/go/
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
ENV CGO_ENABLED 0

USER eqemu

#############################################
# download go utilities
#############################################
RUN go install github.com/google/wire/cmd/wire@latest

#############################################
# for testing installation runs
#############################################
RUN mkdir -p /tmp/server/ && cd /tmp/server
RUN echo 'alias build="cd /opt/eqemu-install-v2/spire && go build -o /tmp/spire && cd /tmp/server"' >> /home/eqemu/.bashrc
RUN echo 'alias spire="build && SKIP_UPDATE_CHECK=true RUN_INSTALLER=true /tmp/spire"' >> /home/eqemu/.bashrc

#############################################
# user
#############################################
USER eqemu
WORKDIR /home/eqemu

CMD /bin/bash