# Firebase Cloud Messaging (FCM) Setup Guide

The FCM service has been updated to use the **FCM HTTP v1 API** (the legacy API was deprecated and shut down by Google, which was causing the 404 errors).

## Steps to Configure FCM

### 1. Download Firebase Service Account JSON

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on the gear icon ⚙️ → **Project settings**
4. Navigate to the **Service accounts** tab
5. Click **Generate new private key**
6. Save the downloaded JSON file (e.g., `firebase-service-account.json`)

### 2. Update passwords.yaml

You need to add two new entries to your `passwords.yaml` file:

```yaml
shared:
  # ... existing keys ...
  
  # Firebase Cloud Messaging Configuration
  fcmProjectId: 'your-firebase-project-id'  # e.g., 'my-coach-app-12345'
  fcmServiceAccount: '{
    "type": "service_account",
    "project_id": "your-project-id",
    "private_key_id": "...",
    "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-...@your-project-id.iam.gserviceaccount.com",
    "client_id": "...",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "..."
  }'
```

**Important:** 
- Replace the entire JSON content with your downloaded service account file
- Keep it as a single-line string (or use YAML multiline string syntax)
- You can remove the old `fcmServerKey` as it's no longer used

#### Alternative: Use Multiline YAML String

For better readability, you can use YAML multiline syntax:

```yaml
shared:
  fcmProjectId: 'your-firebase-project-id'
  fcmServiceAccount: |
    {
      "type": "service_account",
      "project_id": "your-project-id",
      "private_key_id": "...",
      "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-...@your-project-id.iam.gserviceaccount.com",
      "client_id": "...",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/certs",
      "client_x509_cert_url": "..."
    }
```

### 3. Install Dependencies

Run the following command to install the new `googleapis_auth` package:

```bash
cd my_coach_serverpod_challenge_server
dart pub get
```

### 4. Restart the Server

Restart your Serverpod server:

```bash
dart bin/main.dart --apply-migrations
```

## What Changed?

- ✅ **Migrated from Legacy FCM API to FCM HTTP v1 API**
- ✅ **OAuth2 authentication** instead of deprecated server keys
- ✅ **Token caching** to avoid unnecessary authentication requests
- ✅ **Better error messages** for configuration issues

## Troubleshooting

### Error: "FCM service account JSON not configured"
Make sure you've added `fcmServiceAccount` to your `passwords.yaml` file.

### Error: "FCM project ID not configured"
Make sure you've added `fcmProjectId` to your `passwords.yaml` file.

### Error: "Failed to parse FCM service account JSON"
Check that your JSON is properly formatted and escaped in the YAML file.

### Still getting 404 errors?
Ensure you've downloaded a fresh service account key and that your Firebase project is active.

## Testing

Once configured, the TaskDueChecker will automatically use the updated FCM service to send push notifications for overdue tasks.

You can monitor the logs to verify notifications are being sent successfully:
- Look for "FCM notification sent successfully" messages
- Any errors will be logged with details
