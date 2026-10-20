# Jurisdiction schema

The jurisdiction migrations define the schema used by the updated models and factories. They do not convert existing jurisdiction references. Routes, views, and seeds still need updates before applying the migrations to the working application. A populated database with offices, residences, or governing bodies requires its data to be cleared or converted first.

## Geographic entities

Country and State retain their existing tables. City becomes Municipality through a table rename. County and District are new tables.

| Table | Attributes and relationships |
| --- | --- |
| `countries` | Existing name, code, and description |
| `states` | Existing name, code, and country reference |
| `counties` | Name, optional code, and required state reference |
| `municipalities` | Existing name and state reference, plus an optional county reference |
| `districts` | Name and kind, such as ward, legislative district, or school district |

Each entity includes `JurisdictionOwner` and can own one `jurisdictions` record through the unique polymorphic `jurisdictionable` reference. The concern provides `has_one :jurisdiction` and access to offices, elections, residences, and voters. A jurisdiction can reference a parent jurisdiction for nesting; the model rejects cycles. Parent links do not determine all geographic memberships; separate district boundaries can overlap.

`active_elections_count` and `total_offices_count` include the owner's jurisdiction and its explicitly linked descendants. An Election containing several Races is counted once. These statistics require the parent links to be populated; the civic State and Municipality associations do not automatically create spatial Jurisdiction records or links. Jurisdictions with dependent offices, elections, residences, governing bodies, or children cannot be destroyed through the model until those references are resolved.

Office, Residence, and GoverningBody receive required foreign keys to `jurisdictions`. Their old polymorphic jurisdiction columns are removed without a data backfill. The subsequent [Election and Race migration](election_race_schema.md) gives Election its own Jurisdiction reference and moves the Office reference to Race.

## Spatial boundaries

`jurisdiction_boundaries` stores boundary history separately from the stable jurisdiction identity:

- `jurisdiction_id` references the owning jurisdiction.
- `geometry` is a required PostGIS `MultiPolygon` with SRID 4326, using longitude and latitude coordinates. Its GiST index supports spatial queries.
- `valid_from` is the first date the boundary applies.
- `valid_until` is the first date it no longer applies. A null value leaves the period open-ended.

The database rejects invalid or empty geometry, reversed or empty date periods, and overlapping effective periods for the same jurisdiction. Adjacent periods are allowed. Boundaries belonging to different jurisdictions may overlap geographically. Older boundary records can remain when a new boundary takes effect.

The models validate geometry and effective periods before saving. `Jurisdiction.covering(longitude, latitude, on: date)` returns all jurisdictions whose effective boundary covers the point. It includes points on the boundary and respects polygon holes and disconnected areas. `JurisdictionBoundary.effective_on(date)` uses an inclusive start and exclusive end date.

## Database dependencies

The Rails database adapter is `activerecord-postgis-adapter` 11.1 for Rails 8.1. PostgreSQL must have the PostGIS server package available before the migrations run. `EnablePostgis` enables `postgis` and `btree_gist`; the latter supports the boundary-period exclusion constraint.

RGeo uses GEOS for spatial objects. The application Dockerfile includes its build and runtime libraries, and the CI database service uses a PostGIS image. Database URLs using `postgres://` or `postgresql://` select the standard adapter and must use `postgis://` before spatial migrations or schema loading. For example, CI uses `postgis://postgres:postgres@localhost:5432/ascent_test`.

The models now use Municipality, County, District, Jurisdiction, and JurisdictionBoundary. Residence still permits one active residence per voter; this update does not add address coordinates or classify district eligibility. These migrations have not been applied to the development database. Seed updates and the controller, route, and view changes remain follow-up work.
