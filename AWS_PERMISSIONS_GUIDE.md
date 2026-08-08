# AWS S3 & RDS Configuration & Permissions Guide

This guide details the exact AWS IAM Policies, S3 CORS Policies, and S3 Bucket Policies required for **MyVault Website** and **MyVault Flutter Mobile App**.

---

## 1. 🪣 AWS S3 Bucket CORS Policy (`aws-s3-cors-policy.json`)

To allow web browsers to upload directly to Amazon S3 via presigned `PUT` URLs without CORS errors, apply the following CORS rule to your S3 bucket **`myvault-study-materials`**:

Go to **AWS Console → S3 → myvault-study-materials → Permissions → Cross-origin resource sharing (CORS)**:

```json
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "GET",
      "PUT",
      "POST",
      "DELETE",
      "HEAD"
    ],
    "AllowedOrigins": [
      "*"
    ],
    "ExposeHeaders": [
      "ETag",
      "Content-Length",
      "Content-Type",
      "x-amz-request-id",
      "x-amz-id-2"
    ],
    "MaxAgeSeconds": 3600
  }
]
```

---

## 2. 🔑 AWS IAM Policy (`aws-iam-policy.json`)

Attach this IAM policy to your IAM User (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`):

Go to **AWS Console → IAM → Users → Your User → Add Permissions → Create Inline Policy**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "MyVaultS3FullAccess",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketCors",
        "s3:PutBucketCors",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::myvault-study-materials",
        "arn:aws:s3:::myvault-study-materials/*"
      ]
    },
    {
      "Sid": "MyVaultRDSConnectAccess",
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": [
        "arn:aws:rds-db:ap-south-1:*:dbuser/*/*"
      ]
    }
  ]
}
```

---

## 3. 🌐 AWS S3 Bucket Public Read Policy (`aws-s3-bucket-policy.json`)

To allow direct public viewing of uploaded study materials:

Go to **AWS Console → S3 → myvault-study-materials → Permissions → Bucket Policy**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::myvault-study-materials/*"
    }
  ]
}
```

> **Note**: Also disable "Block all public access" under bucket permissions if you wish for public URLs to open directly.

---

## ⚡ Automated S3 Setup Command

You can automatically create the bucket and configure the CORS rules by running:

```bash
cd backend
node scripts/setup-aws-resources.mjs
```
