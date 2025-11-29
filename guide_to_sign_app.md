# Guide to signed and notarized macOS

To distribute a signed and notarized macOS app via GitHub Actions, you'll need to set up several secrets and modify the workflow. Here's a complete guide:

## Prerequisites

You need an **Apple Developer Program** membership ($99/year) with:

- A **Developer ID Application** certificate
- An **App-specific password** for notarization

---

## Step 1: Export Your Developer ID Certificate

1. Open **Keychain Access** on your Mac
2. Find your "Developer ID Application: Your Name (TEAM_ID)" certificate
3. Right-click → **Export** → Save as `.p12` file with a strong password
4. Base64 encode the certificate:

   ```bash
   base64 -i Certificates.p12 | pbcopy
   ```

   This copies the encoded certificate to your clipboard

---

## Step 2: Create an App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in → **App-Specific Passwords** → **Generate**
3. Name it something like "GitHub Actions Notarization"
4. Save the generated password

---

## Step 3: Find Your Team ID

Run this in Terminal:

```bash
security find-identity -v -p codesigning
```

Look for the 10-character code in parentheses, e.g., `Developer ID Application: Your Name (ABC123XYZ0)`

---

## Step 4: Add GitHub Secrets

Go to your repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `APPLE_CERTIFICATE_BASE64` | The base64-encoded `.p12` certificate |
| `APPLE_CERTIFICATE_PASSWORD` | The password you set when exporting the `.p12` |
| `APPLE_TEAM_ID` | Your 10-character Team ID |
| `APPLE_ID` | Your Apple ID email |
| `APPLE_ID_PASSWORD` | The app-specific password from Step 2 |
