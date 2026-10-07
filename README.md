# Simple Self-Hosted GitHub Actions Runner

No Operator, No CRD, No need to blindly apply a `yml` to K8s cluster, only a simple self-hosted GitHub Actions Runner that just works!

## Images

This repo provides the following images. Each tag is multi-arch (amd64 and arm64):

- `knatnetwork/github-runner:jammy-<tag>`
- `ghcr.io/knatnetwork/github-runner:jammy-<tag>`
- `knatnetwork/github-runner:noble-<tag>`
- `ghcr.io/knatnetwork/github-runner:noble-<tag>`
- `knatnetwork/github-runner:resolute-<tag>`
- `ghcr.io/knatnetwork/github-runner:resolute-<tag>`

`<tag>` follows https://github.com/actions/runner/tags. Runner `v2.338.0` is published as `knatnetwork/github-runner:noble-2.338.0`.

## Specs

- `github-runner:jammy-<tag>` images are based on Ubuntu 22.04. This line is deprecated: GitHub retires the `ubuntu-22.04` hosted image on 17 April 2027, and Ubuntu 22.04 standard support ends in May 2027. New deployments should use `noble` or `resolute`.
- `github-runner:noble-<tag>` images are based on Ubuntu 24.04
- `github-runner:resolute-<tag>` images are based on Ubuntu 26.04
- `github-runner:latest` tracks `github-runner:noble-<tag>`

## Usage

1. Prepare your GitHub Personal Access Token, which looks like `ghp_xxxxxxxxxxxxx` with `admin:org` permission(If you'd like to register runner to repo, your user must have Admin permission on the related repo), if you don't know how to do it, you can refer to [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
2. If you'd like to register runner on a single machine, you can follow the quick start below.
3. If you need to spread multiple runners on multiple nodes using K8s, please take a look at the [documentation](https://runner.knat.network).

### Docker compose Quick Start

This is a quick start example for people to register a runner on single machine using Docker Compose.

First you need to create a `docker-compose.yml` file and write the following content.

```yml
services:
  runner:
    image: knatnetwork/github-runner:latest
    restart: always
    environment:
      RUNNER_REGISTER_TO: 'knatnetwork'
      RUNNER_LABELS: 'docker,knat'
      KMS_SERVER_ADDR: 'http://kms:3000'
      GOPROXY: 'http://goproxy.knat.network,https://proxy.golang.org,direct'
      ADDITIONAL_FLAGS: '--ephemeral'
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - kms

  kms:
    image: knatnetwork/github-runner-kms:latest
    restart: always
    environment:
      PAT_knatnetwork: 'ghp_Lxxxxxxxxxx2NUk5F'
      PAT_rust-lang: 'ghp_Lxxxxxxxxxx2NUk5F'
```

(If your org's name is `org_name`, then `environment` should be `PAT_org_name: 'ghp_Lxxxxxxxxxx2NUk5F'`)

After that you can use `docker-compose up -d` to start the runner, and now the runner should be registered on `knatnetwork` Org now.

![](./demo.png)

Notes:

- If you want to run runner without docker support inside it, just delete the `volumes`
- If you don't want ephemeral runner(ref: [GitHub Actions: Ephemeral self-hosted runners & new webhooks for auto-scaling](https://github.blog/changelog/2021-09-20-github-actions-ephemeral-self-hosted-runners-new-webhooks-for-auto-scaling/), just remove `ADDITIONAL_FLAGS: '--ephemeral'` line.)
- If you want to register runner to a repo only, you can just change value of `RUNNER_REGISTER_TO` to `<org_name>/<repo_name>`, and use `PAT_<org_name>` as `environment` in `kms` container.

## Further Reading

For more instructions, please take a look at the [documentation](https://runner.knat.network).

## License

GPL
