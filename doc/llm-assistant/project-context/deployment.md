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

## Initial release verification

The October 31, 2026 app deployment `743ffab3-8ae9-4c77-8308-1ac96da9cd95`
reached `SUCCESS`. Database deployment `6498b65c-d5e5-49e4-96dd-3f49d9e18931`
also succeeded, providing PostGIS 3.7.0 and retaining the audit module.

The release used a working-tree snapshot based on app commit `141899f` and seed
commit `a4e4c5f979dd41fbb54c4a9de2124f85d6fd9ced`. Its file checksum manifest is
retained locally at `/private/tmp/ascent-production-20261031-manifest.json`.
While the deployment ran, the checkout moved to `main` at `6d5a9e3`; the changed
runtime source files differed from the deployed snapshot only in comments.

All 418 manifests validated, covering 141,861 source records. Initial reference
seeding created 141,259 records, reported 602 unchanged records and zero conflicts,
and gathered 4,438 candidacies from primaries. The completed database contained
141,311 entity codes, 22,291 people, 17,202 races, and 35,136 candidacies, with no
fictional people. Initial database preparation took about 17 minutes.

`/up`, `/`, `/voters/sign_in`, `/mountains`, `/positions`, and the compiled homepage
stylesheet returned HTTP 200. The queue supervisor, dispatcher, and worker had live
heartbeats. Cache and upload storage passed reversible write/read checks. The
focused local suite passed 65 examples with zero failures. Google and Umami remained
unconfigured; delivered email was not tested.

The full catalog exposed a performance issue in `/mountains`: the response was
17,230,691 bytes, and Rails reported about 5.9 seconds and 17,934 queries, including
cached queries. `MountainsController#index` loads every active race. Server-side
pagination and reducing repeated queries remain follow-up work.
