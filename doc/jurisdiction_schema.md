# Jurisdiction schema

The jurisdiction migrations prepare a new schema. They do not update application models, routes, views, factories, or seeds, and they do not convert existing jurisdiction references. Apply them to an empty database when that application work is ready. A populated database with offices, residences, or governing bodies requires its data to be cleared or converted first.

## Geographic entities

Country and State retain their existing tables. City becomes Municipality through a table rename. County and District are new tables.

| Table | Attributes and relationships |
| --- | --- |
| `countries` | Existing name, code, and description |
| `states` | Existing name, code, and country reference |
| `counties` | Name, optional code, and required state reference |
| `municipalities` | Existing name and state reference, plus an optional county reference |
| `districts` | Name and kind, such as ward, legislative district, or school district |

Each entity can own one `jurisdictions` record through the unique polymorphic `jurisdictionable` reference. This supports `has_one :jurisdiction` on each of the five entity models. A jurisdiction can reference a parent jurisdiction for nesting. Parent links do not determine all geographic memberships; separate district boundaries can overlap.

Office, Residence, and GoverningBody receive required foreign keys to `jurisdictions`. Their old polymorphic jurisdiction columns are removed without a data backfill. The subsequent [Election and Race migration](election_race_schema.md) gives Election its own Jurisdiction reference and moves the Office reference to Race.

## Spatial boundaries

`jurisdiction_boundaries` stores boundary history separately from the stable jurisdiction identity:

- `jurisdiction_id` references the owning jurisdiction.
- `geometry` is a required PostGIS `MultiPolygon` with SRID 4326, using longitude and latitude coordinates. Its GiST index supports spatial queries.
- `valid_from` is the first date the boundary applies.
- `valid_until` is the first date it no longer applies. A null value leaves the period open-ended.

The database rejects invalid or empty geometry, reversed or empty date periods, and overlapping effective periods for the same jurisdiction. Adjacent periods are allowed. Boundaries belonging to different jurisdictions may overlap geographically. Older boundary records can remain when a new boundary takes effect.

## Database dependencies

The Rails database adapter is `activerecord-postgis-adapter` 11.1 for Rails 8.1. PostgreSQL must have the PostGIS server package available before the migrations run. `EnablePostgis` enables `postgis` and `btree_gist`; the latter supports the boundary-period exclusion constraint.

RGeo uses GEOS for spatial objects. The application Dockerfile includes its build and runtime libraries, and the CI database service uses a PostGIS image. Database URLs using `postgres://` or `postgresql://` select the standard adapter and must use `postgis://` before spatial migrations or schema loading. For example, CI uses `postgis://postgres:postgres@localhost:5432/ascent_test`.

These migrations have not been applied to the development database. Seed updates, application association changes, and the City-to-Municipality code rename remain follow-up work.
