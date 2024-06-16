gcloud data-catalog tag-templates create new_york_datasets --display-name="New York Datasets" --location=$REGION --field=id=contains_pii,display-name="Contains PII",type='enum(None|Birth date|Gender|Geo location)' --field=id=data_owner_team,display-name="Data Owner Team",type='enum(Marketing|Data Science|Sales|Engineering)',required=TRUE

gcloud config set project $PROJECT_ID_2

bq query --use_legacy_sql=false \
'SELECT
  contributing_factor_vehicle_1 AS collision_factor,
  COUNT(*) AS num_collisions
FROM
  `new_york_mv_collisions.nypd_mv_collisions`
WHERE
  contributing_factor_vehicle_1 != "Unspecified"
  AND contributing_factor_vehicle_1 != ""
GROUP BY
  collision_factor
ORDER BY
  num_collisions DESC
LIMIT 10;'