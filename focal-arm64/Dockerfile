FROM ubuntu:20.04 as env

ARG GITHUB_RUNNER_VERSION=2.286.1
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root
RUN apt-get update && apt install wget -y
RUN wget https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-arm64-${GITHUB_RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-arm64-${GITHUB_RUNNER_VERSION}.tar.gz && rm -f actions-runner-linux-arm64-${GITHUB_RUNNER_VERSION}.tar.gz \
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
    && apt-get install -y curl sudo jq iputils-ping zip gcc libssl-dev libcurl4-gnutls-dev zlib1g-dev make gettext wget docker-compose cmake clang perl psmisc software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.40.1.tar.gz && tar -xvzf git-2.40.1.tar.gz && cd git-2.40.1 && ./configure --prefix=/usr/ && make -j 8 && make install \
    && cd && rm -rf git-2.40.1.tar.gz git-2.40.1 \
    && wget https://github.com/Kitware/CMake/releases/download/v3.27.1/cmake-3.27.1.tar.gz \
    && tar xf cmake-3.27.1.tar.gz && cd cmake-3.27.1 && ./configure && make -j 8 && make install

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

USER root
WORKDIR /root/

COPY --from=env /root/ /root/
RUN  /root/bin/installdependencies.sh

COPY entrypoint.sh runsvc.sh ./
RUN sudo chmod u+x ./entrypoint.sh ./runsvc.sh

ENTRYPOINT ["./entrypoint.sh"]
