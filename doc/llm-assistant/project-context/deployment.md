# Railway production

Project `ascent`: `960d98ac-f430-4165-9f9e-28d00f2b9b6d`.
Production environment: `259bfed3-8ac2-4f04-a90b-26f00942cbca`.
App service `ascent-production`: `7fe0c497-152a-4143-bec6-238ef030ca3d`.
Database service `Postgres-3s-_`: `323955e2-00b7-4dcc-9105-bd1b8150abad`.

The app uses the root Dockerfile and listens on port 80 with `PORT=80` and `HTTP_PORT=80`.
The health check is `/up`. Database preparation runs through `./bin/rails db:prepare`
before deployment, with a 3600-second timeout. Initial preparation loads the reference
seeds; subsequent releases migrate the existing databases. Never run the simulated
seed task in production.

`DATABASE_URL` must use the `postgis://` scheme so Rails selects the spatial adapter.
`CACHE_DATABASE_URL`, `QUEUE_DATABASE_URL`, and `CABLE_DATABASE_URL` use separate
databases on the same PostgreSQL service. `RAILS_ENV=production` and
`SOLID_QUEUE_IN_PUMA=true` enable the production configuration and background jobs.
The app's persistent upload volume is mounted at `/rails/storage`.

The PostgreSQL service uses the image built from `docker/postgres/Dockerfile`.
It extends Railway's PostgreSQL 18 image with PostGIS while retaining the `pgaudit`
module required by the existing database configuration. Its persistent data volume
is mounted at `/var/lib/postgresql/data`, with `PGDATA` set to its `pgdata` subdirectory.
Do not replace this build with the unmodified PostgreSQL image, which lacks PostGIS,
or the staging image, which lacks the required audit module.

Deploy the app from the repository root, targeting the production IDs explicitly.
To rebuild the database image, deploy `docker/postgres` with `--path-as-root` and
target the database service. The app and database have different Dockerfiles.
Verify the submitted deployment ID reaches `SUCCESS`, the app's `/up` and public
pages respond successfully, and the database can execute `SELECT postgis_full_version()`.

Runtime secrets belong in Railway variables. Generate a distinct `SECRET_KEY_BASE`
for production. `POSTSHIBA_API_KEY` comes from Doppler project `ascent`, config `prd`.
Mail links target `https://ascent.ing`; delivered email and those links require
verification after DNS setup.

The temporary public origin is `https://ascent-production-production.up.railway.app`.
Google sign-in requires `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` at app boot.
Register the chosen origin followed by `/voters/auth/google_oauth2/callback` with Google.
Umami reads `UMAMI_SCRIPT_URL` and `UMAMI_WEBSITE_ID`; without the website ID, the
tracker is omitted. Custom DNS, Google credentials, and Umami setup are separate
follow-up steps after the initial production release.
