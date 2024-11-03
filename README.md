# khodo

This is a project written using [Lucky](https://luckyframework.org). Enjoy!

## Quick setup

You can quickly get started with this app on Linux (Mac too possibly)
if you have the following available:
- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/)
- openssl (this is only needed to generate a random key - you can come up with your own)
- curl or something like wget (needed to download [this file](https://gitlab.com/ntumbuka/khodo/-/raw/develop/docker-compose-prod.yml?ref_type=heads -o docker-compose.yml))

Run the following instructions, once you have the above:

```sh
curl -L https://gitlab.com/ntumbuka/khodo/-/raw/develop/quick-setup.sh?ref_type=heads | sh -s
```

### Setting up the project for development

1. [Install required dependencies](https://luckyframework.org/guides/getting-started/installing#install-required-dependencies)
1. Update database settings in `config/database.cr`
1. Run `script/setup`
1. Run `lucky dev` to start the app

### Using Docker for development

1. [Install Docker](https://docs.docker.com/engine/install/)
1. Run `docker compose up`

The Docker container will boot all of the necessary components needed to run your Lucky application.
To configure the container, update the `docker-compose.yml` file, and the `docker/development.dockerfile` file.


### Learning Lucky

Lucky uses the [Crystal](https://crystal-lang.org) programming language. You can learn about Lucky from the [Lucky Guides](https://luckyframework.org/guides/getting-started/why-lucky).
