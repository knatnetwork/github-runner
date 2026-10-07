ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} AS env

ARG GITHUB_RUNNER_VERSION=2.338.0
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root
RUN apt-get update \
    && apt-get install -y wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "${arch}" in \
      amd64) runner_arch=x64 ;; \
      arm64) runner_arch=arm64 ;; \
      *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    wget -q "https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-${runner_arch}-${GITHUB_RUNNER_VERSION}.tar.gz"; \
    tar xzf "./actions-runner-linux-${runner_arch}-${GITHUB_RUNNER_VERSION}.tar.gz"; \
    rm -f "./actions-runner-linux-${runner_arch}-${GITHUB_RUNNER_VERSION}.tar.gz"

FROM ubuntu:${UBUNTU_VERSION} AS runner

ARG DEBIAN_FRONTEND=noninteractive
ENV KMS_SERVER_ADDR="" \
    RUNNER_REGISTER_TO="" \
    RUNNER_WORKDIR="_work" \
    RUNNER_LABELS="" \
    ADDITIONAL_PACKAGES="" \
    ADDITIONAL_FLAGS="" \
    GOPROXY="" \
    RUNNER_ALLOW_RUNASROOT="1"

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        jq \
        iputils-ping \
        zip \
        libssl-dev \
        libcurl4-gnutls-dev \
        zlib1g-dev \
        gettext \
        make \
        build-essential \
        python3-pip \
        wget \
        cmake \
        clang \
        perl \
        psmisc \
        software-properties-common \
        git \
        ca-certificates \
    && curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* get-docker.sh

USER root
WORKDIR /root/

COPY --from=env /root/ /root/
RUN /root/bin/installdependencies.sh

COPY entrypoint.sh runsvc.sh ./
RUN chmod u+x ./entrypoint.sh ./runsvc.sh

ENTRYPOINT ["./entrypoint.sh"]
