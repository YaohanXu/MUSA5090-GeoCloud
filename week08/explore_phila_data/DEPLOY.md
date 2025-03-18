## Deploying

_extract_phl_opa_properties_:

```shell
gcloud functions deploy extract_phl_opa_properties \
--gen2 \
--region=us-east1 \
--runtime=nodejs20 \
--source=. \
--entry-point=extract_phl_opa_properties \
--service-account=data-pipeline-robot-2025@musa-451221.iam.gserviceaccount.com \
--memory=4Gi \
--timeout=240s \
--set-env-vars=DATA_LAKE_BUCKET=yaohan_data_lake \
--trigger-http \
--no-allow-unauthenticated
```

```shell
gcloud functions call extract_phl_opa_properties --region=us-east1
```

```shell
gcloud functions logs read extract_phl_opa_properties --region=us-east1
```

_prepare_phl_opa_properties_:

```shell
gcloud functions deploy prepare_phl_opa_properties \
--gen2 \
--region=us-east1 \
--runtime=nodejs20 \
--source=. \
--entry-point=prepare_phl_opa_properties \
--service-account=data-pipeline-robot-2025@musa-451221.iam.gserviceaccount.com \
--memory=8Gi \
--timeout=480s \
--set-env-vars=DATA_LAKE_BUCKET=yaohan_data_lake \
--trigger-http \
--no-allow-unauthenticated
```

```shell
gcloud functions call prepare_phl_opa_properties --region=us-east1
```

```shell
gcloud functions logs read prepare_phl_opa_properties --region=us-east1
```

_run_sql_:

```shell
gcloud functions deploy run_sql \
--gen2 \
--region=us-east1 \
--runtime=nodejs20 \
--source=. \
--entry-point=run_sql \
--service-account=data-pipeline-robot-2025@musa-451221.iam.gserviceaccount.com \
--memory=8Gi \
--timeout=480s \
--set-env-vars=DATA_LAKE_BUCKET=yaohan_data_lake,DATA_LAKE_DATASET=data_lake \
--trigger-http \
--no-allow-unauthenticated
```

```shell
gcloud iam service-accounts add-iam-policy-binding data-pipeline-robot-2025@musa-451221.iam.gserviceaccount.com \
    --member="user:xuyaohan99@gmail.com" \
    --role="roles/iam.serviceAccountTokenCreator"
```

```shell
TOKEN=$(gcloud auth print-identity-token --impersonate-service-account=data-pipeline-robot-2025@musa-451221.iam.gserviceaccount.com)

curl -H "Authorization: Bearer $TOKEN" \
     "https://us-east1-musa-451221.cloudfunctions.net/run_sql?sql=data_lake/phl_opa_properties.sql"
```

```shell
curl -X POST 'https://run-sql-328262866095.us-east1.run.app?sql=data_lake/phl_opa_properties.sql' \
-H "Authorization: bearer $(gcloud auth print-identity-token)" \
-H "Content-Type: application/json"
```

pipeline workflow:

```shell
gcloud workflows deploy phl-property-data-pipeline \
--source=phl-property-data-pipeline.yaml \
--location=us-east1 \
--service-account='data-pipeline-robot-2025@musa-451221.iam.gserviceaccount.com'

gcloud scheduler jobs create http phl-property-data-pipeline \
--location=us-east1 \
--schedule='0 0 * * 2' \
--time-zone='America/New_York' \
--uri='https://workflowexecutions.googleapis.com/v1/projects/musa-451221/locations/us-east1/workflows/phl-property-data-pipeline/executions' \
--oauth-service-account-email='data-pipeline-robot-2025@musa-451221.iam.gserviceaccount.com'
```

```shell
gcloud workflows execute phl-property-data-pipeline --location=us-east1 --impersonate-service-account='data-pipeline-robot-2025@musa-451221.iam.gserviceaccount.com'
```