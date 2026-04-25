# Google Sign-In Setup Guide

End-to-end setup for Google authentication in SplitEase using **native Google Sign-In + Supabase `signInWithIdToken`**. Mobile-only (Android + iOS); no browser OAuth flow.

This guide covers:
1. [Google Cloud Console](#1-google-cloud-console) — OAuth project + three Client IDs (Web, iOS, Android)
2. [Supabase Dashboard](#2-supabase-dashboard) — enable Google provider with the right config
3. [Flutter App](#3-flutter-app) — what's already wired in this repo
4. [Testing](#4-testing)
5. [Rotating Secrets & Client IDs](#5-rotating-secrets--client-ids) ← read this if anything was leaked or rotated
6. [Troubleshooting](#6-troubleshooting)

---

## How the flow works (read this first)

When the user taps the Google button on the login or register page:

1. The app calls `GoogleSignIn(serverClientId: WEB_CLIENT_ID, clientId: IOS_CLIENT_ID).signIn()`.
2. Google shows the account chooser. User picks an account.
3. Google issues an **ID token** whose `aud` (audience) claim equals the **Web Client ID** (because we passed it as `serverClientId`).
4. The app passes that ID token to `supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: ...)`.
5. Supabase verifies:
   - The token's `aud` is in the **Client IDs** allowlist on the Google provider page.
   - The token is signed by Google.
   - The nonce matches (or is skipped if "Skip nonce checks" is on).
6. If all checks pass, Supabase creates/updates the user, returns a session.
7. The app stores the session in `AppUserCubit` and navigates to home.

The most common failure mode is step 5: an audience or signature mismatch caused by a config drift between Google Cloud and Supabase.

---

## 1. Google Cloud Console

### 1.1. Create / select a Google Cloud project

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or select an existing one. Project name doesn't matter.
3. Note the project ID (top of page) — you'll see it in URLs.

### 1.2. Configure the OAuth consent screen

Required before creating OAuth Client IDs.

1. Go to **APIs & Services → OAuth consent screen**.
2. **User Type**: External (for public apps) or Internal (Google Workspace only). Pick External unless you're shipping inside an org.
3. Fill in:
   - **App name**: `SplitEase` (or whatever you ship).
   - **User support email**: your email.
   - **Developer contact**: your email.
4. **Scopes**: leave at defaults (Google adds `email`, `profile`, `openid` automatically for sign-in).
5. **Test users** (only if app is in *Testing* mode): add the Google accounts that are allowed to sign in during dev. While in Testing mode, only listed accounts work; production mode requires Google verification for some scopes.
6. Save.

### 1.3. Create OAuth Client IDs (need three)

Go to **APIs & Services → Credentials → Create Credentials → OAuth client ID**.

You will create **three** OAuth clients. The reasons each is needed:

| Client | Purpose | Used by |
|---|---|---|
| **Web application** | Issues the ID token's `aud` claim. Supabase uses this ID + Secret to verify tokens. | Supabase backend; passed as `serverClientId` in Flutter. |
| **iOS** | Configures Google Sign-In iOS SDK. The reversed ID becomes a URL scheme. | iOS app (via `Info.plist` and `clientId` parameter). |
| **Android** | Binds your Android app's package name + SHA-1 fingerprint so Google trusts it. Not used in Flutter code directly — it's a "permission" entry. | Android app (resolved by Google's runtime via SHA-1 + package match). |

#### 1.3.a. Web application

1. Click **Create Credentials → OAuth client ID → Application type: Web application**.
2. Name: `SplitEase Web` (or any).
3. **Authorized JavaScript origins**: leave empty (no web app).
4. **Authorized redirect URIs**: leave empty for now — you'll add one after creating the Supabase provider in [step 2.3](#23-paste-the-callback-url-back-into-google-cloud).
5. Create. Copy the **Client ID** and **Client Secret** — you'll paste both into Supabase.

#### 1.3.b. iOS

1. Click **Create Credentials → OAuth client ID → Application type: iOS**.
2. Name: `SplitEase iOS`.
3. **Bundle ID**: must match your iOS app's bundle identifier exactly. For this project, see `ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`).
4. Create. Copy the **iOS Client ID**. The Web Client Secret does **not** apply here.

#### 1.3.c. Android

1. Click **Create Credentials → OAuth client ID → Application type: Android**.
2. Name: `SplitEase Android`.
3. **Package name**: must match `applicationId` in `android/app/build.gradle.kts`. For this project: `com.example.split_ease` (Flutter default — change before production).
4. **SHA-1 certificate fingerprint**: get yours by running:
   ```sh
   cd android && ./gradlew signingReport
   ```
   Look under `Variant: debug` → `SHA1`. Paste it here.
   - You'll need to repeat this with your **release** keystore SHA-1 before publishing to Play Store.
5. Create. Copy the **Android Client ID** (although you won't paste it in Flutter code — it's used implicitly via SHA-1 + package match).

After this section you have three IDs:
- Web Client ID (`...rc9cp...` for this project)
- iOS Client ID (`...7bo375...`)
- Android Client ID (`...6iu4pj...`)

…plus one Web Client **Secret** (`GOCSPX-...`) — only the Web client has a secret.

---

## 2. Supabase Dashboard

### 2.1. Open the Google provider config

1. Go to [Supabase dashboard](https://supabase.com/dashboard) → your project.
2. **Authentication → Providers → Google**.
3. Click to open the modal.

### 2.2. Fill in the fields

| Field | Value |
|---|---|
| **Enable Sign in with Google** | ON |
| **Client IDs** | Comma-separated list of **Web Client ID, iOS Client ID, Android Client ID**. No spaces, no trailing comma. |
| **Client Secret (for OAuth)** | The **Web Client Secret** from the Web OAuth client (`GOCSPX-...`). |
| **Skip nonce checks** | ON |
| **Allow users without an email** | OFF |
| **Callback URL (for OAuth)** | Pre-filled by Supabase. Don't edit — copy it for [step 2.3](#23-paste-the-callback-url-back-into-google-cloud). |

**Click `Save` at the bottom-right.** This step is the most common failure point. Wait for the success toast.

**Why all three Client IDs:** Supabase rejects tokens whose `aud` isn't in this list. With our current Flutter setup (`serverClientId: WEB_CLIENT_ID`), the `aud` is always the Web Client ID — so technically only the Web ID is required. Listing all three is defensive: if the SDK behavior changes or you add a new platform, no breakage.

**Why "Skip nonce checks":** The `google_sign_in` Flutter package on iOS doesn't expose the nonce used to mint the ID token, so Supabase's nonce verification will reject legitimate iOS sign-ins. This setting is the standard tradeoff for native mobile flows.

### 2.3. Paste the callback URL back into Google Cloud

The Callback URL Supabase showed you (e.g. `https://<project-ref>.supabase.co/auth/v1/callback`) must be registered on the Web OAuth client.

1. Go back to Google Cloud Console → **Credentials** → click your **Web** OAuth client.
2. Under **Authorized redirect URIs**, click **Add URI** and paste the Callback URL.
3. Save.

Even though the mobile native flow doesn't actually hit this redirect, Google validates the OAuth client config end-to-end and Supabase needs the relationship intact.

---

## 3. Flutter App

Already wired in this repo. The pieces:

### 3.1. Dependencies (`pubspec.yaml`)

```yaml
google_sign_in: ^6.2.1
```

Run `flutter pub get` after pulling.

### 3.2. Client IDs (`lib/core/secrets/app_secrets.dart`)

Public Client IDs live here as constants (`googleWebClientId`, `googleIosClientId`). The Web Client **Secret** never goes here — it lives only in Supabase dashboard.

### 3.3. iOS URL scheme (`ios/Runner/Info.plist`)

Adds `CFBundleURLTypes` with the **reversed** iOS Client ID so the OS routes the OAuth callback back to the app. Format:

```
com.googleusercontent.apps.<iOS Client ID without ".apps.googleusercontent.com">
```

### 3.4. Android — nothing in app code

The Android OAuth client is bound by package name + SHA-1 in Google Cloud. No Flutter code change. If you change `applicationId` or your signing keystore, you must update the Android OAuth client in Google Cloud accordingly.

### 3.5. Auth layer

| File | Purpose |
|---|---|
| `lib/features/auth/data/datasources/auth_remote_data_source.dart` | `signInWithGoogle()` runs Google chooser → Supabase `signInWithIdToken`. Returns null on cancellation. |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Interface. Returns `Either<Failure, UserEntity?>`. |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Wraps datasource, maps exceptions. |
| `lib/features/auth/domain/usecases/google_sign_in_usecase.dart` | `UseCase<UserEntity?, NoParams>`. |
| `lib/features/auth/presentation/login/bloc/login_bloc.dart` | `GoogleSignInRequested` event + handler. |
| `lib/features/auth/presentation/register/bloc/register_bloc.dart` | Same. Uses `RegisterGoogleSuccess` to skip the email-verification page. |
| `lib/injection_container.dart` | `_auth()` — `GoogleSignInUseCase` registered + bloc factories updated. |

---

## 4. Testing

### 4.1. Android

1. Run on a real device or an emulator **with Google Play Services** (not a "Google APIs"-less image).
2. The Google account on the device must be signed in to Google.
3. Tap the Google button → account chooser → select → app should land on home.

### 4.2. iOS

1. `cd ios && pod install` — required after first install of `google_sign_in_ios`.
2. `flutter run` on a simulator (iOS 17+) or device.
3. The simulator must have a Google account configured in Settings, or you'll get an empty chooser.

### 4.3. Quick verification checklist

- [ ] `flutter pub get` ran without errors.
- [ ] iOS: `pod install` ran without errors.
- [ ] Android: `./gradlew signingReport` debug SHA-1 matches what's in the Android OAuth client.
- [ ] Supabase Google provider is **enabled**, Client IDs saved, Skip nonce checks ON, Save was clicked, success toast appeared.
- [ ] The Web Client Secret in Supabase matches the current secret in Google Cloud.
- [ ] Authorized redirect URI on the Web OAuth client equals Supabase's Callback URL.

---

## 5. Rotating Secrets & Client IDs

> **Rule of thumb:** if a credential ever appears anywhere outside Google Cloud Console + Supabase Dashboard (logs, screenshots, chat, commit history, third-party CI), rotate it. Trust nothing — rotate everything that leaked.

### 5.1. When to rotate

- **Always rotate immediately if:** the value was pasted into a chat, posted in a screenshot, committed to git, sent in an email, or otherwise transmitted in plain text.
- **Periodically rotate** the Web Client Secret as a routine hygiene practice (every 6–12 months).
- **Rotate after offboarding** anyone with prior access to Google Cloud or Supabase dashboards.

### 5.2. Rotating the Web Client **Secret**

This is the most common rotation. The Web Client Secret is the only true secret in this setup — Client IDs are public.

**Steps:**

1. Go to Google Cloud Console → **APIs & Services → Credentials**.
2. Click your **Web application** OAuth client.
3. On the right side, click **Reset Secret** (or **Add Secret** then revoke the old one — the latter is preferred because it gives a brief grace period).
4. Confirm. Google generates a new `GOCSPX-...` value.
5. **Copy the new secret.**
6. Go to Supabase → Authentication → Providers → Google → paste the new secret into **Client Secret (for OAuth)** → **Save**.
7. Test sign-in immediately. If it works, the rotation is complete.
8. **No app code change needed** — the secret never lives in Flutter code.

**Impact:**
- Existing user sessions are **not** invalidated (sessions are JWTs Supabase already issued).
- New sign-in attempts will start using the new secret as soon as Supabase persists it.
- Browser/web OAuth flow (if you ever add one) will use the new secret on next request.

### 5.3. Rotating a **Client ID** (Web, iOS, or Android)

Rotating a Client ID is heavier than rotating a secret because the ID is referenced in multiple places. Do this if a Client ID is compromised in a way you can't otherwise contain (e.g. someone published a malicious app using your Android package + SHA-1).

#### 5.3.a. Rotating the **Web Client ID**

1. **Create a new Web OAuth client** in Google Cloud (don't delete the old one yet).
   - Reuse your project, OAuth consent screen, and authorized redirect URIs.
2. **Add the new Web Client ID to Supabase** Client IDs field — keep the old one in the list during the transition.
3. **Update `lib/core/secrets/app_secrets.dart`** → change `googleWebClientId` to the new value.
4. **Copy the new Web Client Secret** from Google Cloud → paste into Supabase → save.
5. **Build + ship** the new app version. Users on the old version will keep working because the old Web Client ID is still in Supabase's allowlist.
6. Once **all** users are on the new version (typically wait 2–4 weeks for forced upgrades), **delete the old Web OAuth client** in Google Cloud → **remove the old ID** from Supabase's Client IDs field → save.

#### 5.3.b. Rotating the **iOS Client ID**

1. Create a new iOS OAuth client in Google Cloud — same Bundle ID.
2. Update `lib/core/secrets/app_secrets.dart` → `googleIosClientId`.
3. Update `ios/Runner/Info.plist` → `CFBundleURLSchemes` → use the new reversed iOS Client ID.
4. Add the new iOS Client ID to Supabase's Client IDs list.
5. Ship the new app version. Once adoption is full, delete the old iOS OAuth client and remove the old ID from Supabase.

#### 5.3.c. Rotating the **Android Client ID**

1. Create a new Android OAuth client in Google Cloud — same package name and SHA-1.
2. **No Flutter code change needed** — Android resolves the client via SHA-1 + package, not by ID string.
3. Add the new Android Client ID to Supabase's Client IDs list (defensive — even though `aud` won't be the Android ID with current setup).
4. Delete the old Android OAuth client in Google Cloud → remove from Supabase.

### 5.4. Rotating SHA-1 (when you change the Android signing keystore)

1. Get the new SHA-1: `cd android && ./gradlew signingReport`.
2. Google Cloud → **Credentials** → click your **Android** OAuth client → **Add fingerprint** → paste new SHA-1.
3. **Keep the old SHA-1 too** during transition if you have users on the old build.
4. Once all users have upgraded, remove the old SHA-1.
5. Repeat for release keystore SHA-1 before publishing to Play Store.

### 5.5. Rotating Supabase keys (if relevant)

Outside the scope of Google sign-in, but related:

- **Anon key** (`AppSecrets.supabaseAnonKey`): Supabase dashboard → **Settings → API** → reset. Update `lib/core/secrets/app_secrets.dart`. Ship a new app version.
- **Service role key**: never ships in the app. If leaked, reset it from the same page. Update wherever it's used (server-side functions, CI).

### 5.6. Cleaning up after a leak

If a secret was leaked in chat, screenshot, or git history:

1. **Rotate first** (as above) — this is the only action that *contains* the leak.
2. **Then** clean up the source if practical (delete the screenshot, force-push to scrub git history). But cleanup *after* rotation, never instead of it. Leaked credentials in cached or backed-up data may be retained beyond your control; only rotation makes the leaked value useless.
3. If git history was force-pushed to remove a secret, notify all collaborators to re-clone — old clones may still hold the leaked value.

---

## 6. Troubleshooting

### Error: `Unacceptable audience in id_token: [...]`

- **Cause:** The token's `aud` claim isn't in Supabase's Client IDs allowlist.
- **Fix:** Go to Supabase → Auth → Providers → Google. Confirm the Web Client ID is in the **Client IDs** field (no spaces around commas). Click **Save** and wait for the toast. Reopen the modal to verify the value persisted.

### Error: `Invalid login credentials` or `JWT signature invalid`

- **Cause:** The Web Client Secret in Supabase doesn't match the current secret in Google Cloud.
- **Fix:** Go to Google Cloud → reset the Web Client Secret (or copy the existing one if visible) → paste into Supabase → save.

### Android: `com.google.android.gms.common.api.ApiException: 10` ("DEVELOPER_ERROR")

- **Cause:** Package name + SHA-1 mismatch between the Android OAuth client config and the actual signing certificate of the running APK.
- **Fix:**
  1. Run `cd android && ./gradlew signingReport` — copy the **debug** variant SHA-1.
  2. Compare it to the SHA-1 on the Android OAuth client in Google Cloud Console.
  3. If they differ, add the correct SHA-1 in Google Cloud → save → wait ~5 minutes for Google to propagate → fully kill and relaunch the app.
- Also confirm `applicationId` in `android/app/build.gradle.kts` exactly matches the Android OAuth client's package name.

### iOS: app crashes when tapping Google button

- **Cause:** Most often a missing or wrong URL scheme in `Info.plist`.
- **Fix:** Verify `CFBundleURLTypes` → `CFBundleURLSchemes` contains the reversed iOS Client ID (e.g. `com.googleusercontent.apps.903953714490-7bo375...`). Run `cd ios && pod install` after any plugin changes.

### Sign-in succeeds but app doesn't navigate / `AppUserCubit` not updated

- **Cause:** Bloc handler emitted the wrong state, or the page's `BlocListener` doesn't listen for it.
- **Check:**
  - `LoginBloc` emits `LoginStatus.success` → login page navigates to `AppRoutes.home`.
  - `RegisterBloc` emits `RegisterGoogleSuccess` → register page navigates to `AppRoutes.home` (separate from `RegisterSuccess`, which goes to the email-verify page).

### Sign-in returns "cancelled" every time

- **Cause:** The user actually tapped outside the chooser, OR the Google account is misconfigured on the device.
- **Fix:** On simulator, ensure a Google account is signed in via Settings. On Android emulator, use a "Google Play"-enabled image.

### Token works on iOS but fails on Android (or vice versa)

- **Cause:** Only one of the two OAuth clients is properly configured.
- **Fix:**
  - iOS-only failure → check Info.plist URL scheme + iOS OAuth client Bundle ID.
  - Android-only failure → check SHA-1 + package name in Android OAuth client.

### Need a fresh chooser every time during testing

The `signInWithGoogle()` method already calls `GoogleSignIn.signOut()` before `signIn()` — this forces a fresh chooser. If you remove that, Google will silently reuse the previously selected account.

---

## Reference

- Supabase Google provider docs: <https://supabase.com/docs/guides/auth/social-login/auth-google>
- `google_sign_in` package: <https://pub.dev/packages/google_sign_in>
- Google Cloud Console: <https://console.cloud.google.com/apis/credentials>
- Supabase dashboard: <https://supabase.com/dashboard>
