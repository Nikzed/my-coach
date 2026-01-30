# Deployment Guide

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and authenticated (`gcloud auth login`)
- Project: `my-coach-flutter`
- Region: `europe-central2`
- Artifact Registry: `europe-central2-docker.pkg.dev/my-coach-flutter/serverpod/my-coach-server`
- Cloud Run service: `my-coach-server`

## Deploy Server to Cloud Run

### 1. Build and push Docker image

Increment the version tag each time (e.g., v8, v9, v10...): IMPORTANT. CHECK THE CURRENT VERSION!

```powershell
gcloud builds submit --tag europe-central2-docker.pkg.dev/my-coach-flutter/serverpod/my-coach-server:v8 my_coach_serverpod_challenge_server
```

### 2. Deploy to Cloud Run

```powershell
gcloud run deploy my-coach-server --image europe-central2-docker.pkg.dev/my-coach-flutter/serverpod/my-coach-server:v8 --region europe-central2 --project my-coach-flutter
```

### 3. Verify deployment

```powershell
gcloud run services describe my-coach-server --region europe-central2 --project my-coach-flutter --format="value(status.url)"
```

Server URL: https://my-coach-server-726428908817.europe-central2.run.app

## View Logs

```powershell
# Recent logs (full detail)
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=my-coach-server" --project=my-coach-flutter --limit=50

# Errors and warnings only
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=my-coach-server AND severity>=WARNING" --project=my-coach-flutter --limit=50

# Live log tailing (requires beta component)
gcloud beta run services logs tail my-coach-server --project=my-coach-flutter --region=europe-central2
```

## Update Secrets (passwords.yaml)

Cloud Run mounts `passwords.yaml` from Google Cloud Secret Manager, not from the Docker image.
If you change `config/passwords.yaml`, you **must** update the secret before deploying:

```powershell
gcloud secrets versions add serverpod-passwords --data-file="C:\Users\nikita\Desktop\flutter_serverpod_challenge\my_coach_serverpod_challenge\my_coach_serverpod_challenge_server\config\passwords.yaml" --project=my-coach-flutter
```

Then redeploy (step 2 above) so the new revision picks up the updated secret.

## Database

- Cloud SQL public IP: `34.116.220.188`
- Database name: `my_coach_serverpod_challenge`
- Migrations are applied automatically on server startup (`--apply-migrations`)
