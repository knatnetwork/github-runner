FROM ubuntu:20.04 as env

ARG GITHUB_RUNNER_VERSION=2.286.1
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root
RUN apt-get update && apt install wget -y
RUN wget https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz && rm -f actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz \
    && sed -i '3,9d' ./config.sh \
    && sed -i '3,8d' ./run.sh

FROM ubuntu:20.04 as runner

ARG DEBIAN_FRONTEND=noninteractive
ENV KMS_SERVER_ADDR ""
ENV RUNNER_REGISTER_TO ""
ENV RUNNER_WORKDIR "_work"
ENV RUNNER_LABELS ""
ENV ADDITIONAL_PACKAGES ""
ENV ADDITIONAL_FLAGS ""
ENV GOPROXY ""

RUN apt-get update \
    && apt-get install -y curl sudo jq iputils-ping zip libssl-dev libcurl4-gnutls-dev zlib1g-dev gettext make build-essential python3-pip wget cmake clang perl psmisc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.28.0.tar.gz && tar -xvzf git-2.28.0.tar.gz && cd git-2.28.0 && ./configure --prefix=/usr/ && make -j 8 && make install \
    && cd && rm -rf git-2.28.0.tar.gz git-2.28.0 \
    && curl https://download.docker.com/linux/static/stable/x86_64/docker-20.10.14.tgz --output docker-20.10.14.tgz \
    && tar xvfz docker-20.10.14.tgz \
    && mv docker/* /usr/bin/ \
    && rm -f docker-20.10.14.tgz 

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

USER root
WORKDIR /root/

COPY --from=env /root/ /root/
RUN  /root/bin/installdependencies.sh

COPY entrypoint.sh runsvc.sh ./
RUN sudo chmod u+x ./entrypoint.sh ./runsvc.sh

ENTRYPOINT ["./entrypoint.sh"]
