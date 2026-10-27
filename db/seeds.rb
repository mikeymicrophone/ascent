# `db:seed` is intentionally limited to reference data. It is safe for normal
# setup and provides the factual geographic and election-calendar foundation.
#
# Load the intentionally fictitious demo experience with:
#   bin/rails seed_data:simulated
require Rails.root.join("db", "seeds", "seed_layers")

SeedLayers.seed_reference!
