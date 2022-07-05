# Doppler SecretOps for PHP

![Doppler Environment Variables Secrets Management for Laravel with PHP-FPM and NGINX on Ubuntu](https://repository-images.githubusercontent.com/399783760/98fbf2ed-eab2-48cf-8be5-85672c2edcfa)

This sample repository will contains all the code required to use the [Doppler CLI](https://docs.doppler.com/docs/cli) for securely managing secrets in local development and production environments. It's a simple Laravel application using Docker Compose to simulate a live environment.

> NOTE: Maria DB is used instead of MySQL due to its support for ARM64 architectures.

## What is Doppler?

The [Doppler CLI](https://docs.doppler.com/docs/cli) provides easy access to secrets in every environment from local development to production and a single dashboard makes it easy for teams to centrally manage app configuration for any application, platform, and cloud provider.

Learn more at our [product website](https://doppler.com) and [documentation](https://docs.doppler.com/docs/).

## Requirements

- Docker Compose
- make
- macOS, Linux

## Initialize Project

To create and initialize the Doppler project from scratch and configure it in all environments run:

```sh
make doppler-project-init
```

## Build Laravel Environment

To create the Laravel Docker image, run:

```sh
make build
```

## Production with NGINX

While the below steps also work for any Development and Staging, we'll select the Production infra environment by running:

```sh
doppler setup --project laravel-sample-app --config infra_prd
```

In a real production environment, you would create a [Service Token](https://docs.doppler.com/docs/service-tokens) for the **infra_prd** environment and inject it as the `DOPPLER_TOKEN` environment variable in your deployment environment through a CI/CD deploy action or similar.

Then launch the application by running:

```sh
make run
```

The application will then be served through NGINX at http://localhost:8080/.

Leave the server running as we'll using it next to demonstrate automatic secrets syncing.

## Secrets Sync

Incorporating automatic secrets syncing just needs a scheduler (e.g. cron) and a single script:

```
* * * * * /usr/src/app/bin/sync-secrets.sh
```

To emulate cron using the `watch` command, open a new terminal window which checks for secret updates every 5 seconds:

```sh
make auto-sync-secrets
```

Now head open the [Doppler dashboard](https://dashboard.doppler.com/workplace/projects/laravel-sample-app/configs/prd) and change the **APP_NAME** value.

And by the time you refresh application in the previous browser tab, the change should already have come through.

## Database Migrations

While each team will have their own process for applying database migrations in live environments, a simple mechanism is demonstrated in the [php-fpm-start.sh](./laravel/bin/php-fpm-start.sh) script by checking if the `DB_FORCE_MIGRATE` environment variable has a value of `TRUE` and force-running the migration command accordingly.

## Local Development

Local development works exactly like you'd expect via `php artisan serve` command but you won't need to manually manage your .env files locally anymore.

If you've been following along so far, we'll need to start from a clean slate as the current database is configured with production credentials:

```sh
rm -fr ./volumes
```

Local development works by only using the Laravel and MySQL containers and uses a Docker Compose development-specific override file to execute the [php-artisan-init.sh](./laravel/bin/php-artisan-serve.sh) script.

Select the **dev_infra** environment:

```sh
doppler setup --project laravel-sample-app --config dev_infra
```

Then run the development server:

```sh
make run-dev
```

The application will then be served from the Laravel container at http://localhost:9090/.

If secrets change, simply restart the development server which will fetch the latest secrets updates.
