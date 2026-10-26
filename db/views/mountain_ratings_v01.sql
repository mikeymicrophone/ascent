SELECT
  ratings.id,
  ratings.voter_id,
  ratings.candidacy_id,
  candidacies.race_id,
  ratings.rating,
  voter_race_baselines.baseline,
  voter_race_baselines.counted_as,
  candidacies.primary_candidacy_id IS NOT NULL AS from_primary,
  ratings.rating > voter_race_baselines.baseline AS approved
FROM ratings
INNER JOIN candidacies ON candidacies.id = ratings.candidacy_id
INNER JOIN voter_race_baselines
  ON voter_race_baselines.voter_id = ratings.voter_id
  AND voter_race_baselines.race_id = candidacies.race_id
LEFT JOIN voter_race_preferences
  ON voter_race_preferences.voter_id = ratings.voter_id
  AND voter_race_preferences.race_id = candidacies.race_id
WHERE candidacies.primary_candidacy_id IS NULL
  OR voter_race_preferences.include_primary_candidates
