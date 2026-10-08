# ERCS Deploy

Docker Compose setup for deploying ERCS, including the `backend`, `frontend`, and `cms` applications. The web applications are served through nginx, with Traefik handling the external routing.

## Setup

Before starting the services, initialize the Git submodules and create the required environment files:

```bash
git submodule update --init --recursive

cp .env.sample .env

cp env/backend.env.sample env/backend.env

cp env/frontend.env.sample env/frontend.env

cp env/cms.env.sample env/cms.env
```

Fill in the required values in the environment files before starting the deployment.

> **Note:** The external Traefik network specified by `TRAEFIK_NETWORK` must already exist.

## Profiles

The Compose setup is divided into profiles:

| Profile      | Services                                                            |
| ------------ | ------------------------------------------------------------------- |
| `core`       | postgres, redis, ollama, web, worker, worker-beat, nginx            |
| `web-builds` | frontend, cms (one-shot builds that output to `./data/web-builds/`) |


## Running the Deployment

The two profiles are independent and do not depend on each other.

### 1. Build the web applications

Run the frontend and CMS builds:

```bash
docker compose run --rm --build frontend

docker compose run --rm --build cms
```

These commands build the applications and place the generated files under `./data/web-builds/`.

### 2. Start the core services

Once the web applications have been built, start the core services:

```bash
docker compose --profile core up -d
```

nginx serves the contents of `./data/web-builds/` directly. Therefore, whenever the frontend or CMS needs to be redeployed, simply repeat step 1 to rebuild the relevant application.

## Running Migrations

Run the database migrations with:

```bash
docker compose exec web ./manage.py migrate
```

## Creating a Superuser

To create a new superuser:

```bash
docker compose exec web ./manage.py createsuperuser
```

## Loading Seed Data

The `seed_data/db.json` fixture contains initial data for ERCS, including:

* A pre-created admin user.
* A set of external dashboards (Power BI embeds) used in the **Capacity & Resources** section.

Load the fixture with:

```bash
docker compose exec web ./manage.py loaddata seed_data/db.json
```

> **Note:** The fixture includes a pre-created admin account: `admin@togglecorp.com`.
>
> If a superuser with the same email already exists in the database, loading the fixture will fail with a conflict. In that case, either delete the existing user first or skip the user fixture when loading the seed data.

## Syncing Geographic Data

Administrative areas such as countries, regions, and zones are sourced from the IFRC GO API.

To synchronize the geographic data with the database, run:

```bash
docker compose exec web ./manage.py sync_geo
```

## Syncing Kobo Data

The `sync_kobo` command fetches ERCS EOC Kobo submissions and reconciles them with the database.

It supports the following forms:

* Emergency Alert
* Rapid Needs Assessment
* Emergency Field

To synchronize all forms:

```bash
docker compose exec web ./manage.py sync_kobo
```

To synchronize only a specific form, for example the Emergency Alert form:

```bash
docker compose exec web ./manage.py sync_kobo --form alert
```
