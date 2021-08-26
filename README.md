# Doppler Environment Variables Secrets Management for Laravel with PHP-FPM and NGINX on Ubuntu

![Doppler Environment Variables Secrets Management for Laravel with PHP-FPM and NGINX on Ubuntu](https://repository-images.githubusercontent.com/399783760/98fbf2ed-eab2-48cf-8be5-85672c2edcfa)

This guide will show you how to use the [Doppler CLI](https://docs.doppler.com/docs/cli) to generate a `.env` file for Laravel applications.

> NOTE: If setting up a server from scratch, take a look at the [init.sh script](bin/init.sh) which although is used for testing purposes, contains all the commands required to set up PHP-FPM, NGINX, and Laravel on Ubuntu or Debian.

## What is Doppler?

The [Doppler CLI](https://docs.doppler.com/docs/cli) provides easy access to secrets in every environment from local development to production and a single dashboard makes it easy for teams to centrally manage app configuration for any application, platform, and cloud provider.

Learn more at our [product website](https://doppler.com) or [documentation](https://docs.doppler.com/docs/).

## Requirements

- Debian or Ubuntu machine or container
- [Doppler CLI](https://docs.doppler.com/docs/cli)
- [jq](https://stedolan.github.io/jq/download/)

## Create Project

If you haven't already, the first step is to create a project in Doppler for your application. 

Doppler works best when it is the single source of truth. This means using the Doppler CLI to fetch your application's secrets for a specific environment to then, dynamically generate the `.env` file.

This can be done during deployment or when updating in place.

You can create a Doppler project using the [dashboard](https://dashboard.doppler.com) or using the [Doppler CLI](https://docs.doppler.com/docs/enclave-installation) on your local machine:

```sh
# 1. Ensure CLI is authenticated
doppler login

# 2. Create project
doppler projects create your-app

# 3. Select project and environment
doppler setup
```

## Import Environment Variables

The next step is to import the environment variables from your existing Laravel `.env` files into Doppler.

This can be done via the [dashboard](https://dashboard.doppler.com) or [CLI](https://docs.doppler.com/docs/enclave-installation):

```sh
# 1. Ensure correct Project and Envirionment are selected.
doppler setup

# 2. Import .env file
doppler import /path/to/.env
```

Then repeat this process for other environments, e.g. staging and production.

## Install Doppler CLI in Ubuntu

With the .env file for each environmennt now imported, it's time to install and configure the Doppler CLI on the machines hosting your Laravel application.

To install the Doppler CLI, run:

```sh
curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | apt-key add -
echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list
apt-get update && apt-get install doppler
```

## Service Token

A Doppler Service Token provides the Doppler CLI with read-only access to a specific Project and Config.

Follow the instructions for [creating a Service Token](https://docs.doppler.com/docs/enclave-service-tokens#generating-a-service-token) and copy the value.

Then configure the Doppler CLI on Ubuntu to use the Service Token by running:

> NOTE: If multiple applications are on a single machine, change `--scope` to be the directory for each application
```sh
# Replace "dp.st.xxx" wth your Service Token value
doppler configure set token "dp.st.xxx" --scope /
```

You can then test the Doppler CLI is configured correctly by running:

```sh
doppler secrets
```

## Generate .env File

With everything in place, you can now generate the '.env` file with a single Doppler CLI command:

```sh
doppler secrets download --no-file --format env-no-quotes > /path/to/laravel/app/.env
```

This command could be run during deployment, as well as in place to sync the latest version of your secrets Doppler to the existing `.env` file.
