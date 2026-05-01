# Add PDF Upload Feature

## Goal Description

Implement the ability for admins to upload news articles as PDF files. The PDFs will be stored in Supabase Storage and linked from Firestore. End‑users can open or download the PDF from the homepage news detail view.

## User Review Required

> [!IMPORTANT]
> This plan introduces a new Supabase storage bucket (`article-pdfs`) and changes the Firestore document schema (adds `pdfUrl`). Please confirm that:
> - Public read access (or signed‑URL policy) for PDFs is acceptable.
> - Existing Firestore security rules allow adding the new field.
> - You are okay with adding the `file_picker` dependency to the project.

## Open Questions

> [!WARNING]
> - **Bucket visibility**: Should the PDF bucket be public, or should we generate signed URLs for each request?
> - **File size limits**: Is there a maximum PDF size you want to enforce?
> - **UI placement**: On which screen should the PDF picker appear (currently `admin_upload_tab.dart`)?

## Proposed Changes

---
### Supabase Configuration (no code files, admin actions)
- Create a new storage bucket named `article-pdfs` in the Supabase Dashboard.
- Set the bucket to **public** (or define a signed‑URL policy if you prefer private access).
- Add a storage policy that allows `INSERT` and `SELECT` for authenticated users.

---
### Flutter – Add Dependency
- Update `pubspec.yaml` to include `file_picker: ^8.0.0` (or latest).

---
### Service Layer – `lib/services/news_service.dart`
- **[MODIFY]** `NewsService`:
  - Add constant `kSupabasePdfBucket = 'article-pdfs';`
  - Implement `Future<String> uploadPickedPdf(FilePickerResult result)` that:
    1. Validates the file has `.pdf` extension.
    2. Reads bytes, uploads with `contentType: 'application/pdf'` using `client.storage.from(kSupabasePdfBucket).uploadBinary(...)`.
    3. Returns `client.storage.from(kSupabasePdfBucket).getPublicUrl(objectPath)` (or signed URL if bucket private).
  - Extend `uploadArticle` signature to accept `String? pdfUrl` and store it in Firestore (`'pdfUrl': pdfUrl`).

---
### UI – Admin Upload Tab (`lib/screens/admin_tabs/admin_upload_tab.dart`)
- Add a “Select PDF” button that uses `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'])`.
- Show the selected PDF filename.
- When the admin presses **Submit**, call the new `uploadPickedPdf` method, capture the returned URL, and pass it to `uploadArticle`.

---
### UI – News Detail Screen (`lib/screens/news_detail_screen.dart` or similar)
- When rendering an article, check for `pdfUrl` field.
- If present, display a **“Open PDF”** button that launches the URL via `url_launcher`.
- Provide a **“Download PDF”** button (same URL, `launchUrl` with `LaunchMode.externalApplication`).

---
### Firestore Schema Update
- No migration needed for existing docs; new docs will simply include the optional `pdfUrl` field.
- Ensure Firestore security rules allow the new field (e.g., `allow write: if request.resource.data.keys().hasAll(['title','category','content','imageUrl','pdfUrl',...])`).

---
### Tests
- Add unit test for `uploadPickedPdf` (mock Supabase client).
- Add integration test that verifies PDF URL appears in the news detail view.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure all existing tests pass.
- Execute new unit tests for PDF upload logic.

### Manual Verification
- **Admin flow**: Open admin upload screen, pick a PDF, submit article, confirm Firestore document contains `pdfUrl` and the file appears in Supabase bucket.
- **User flow**: Open homepage, tap a news item with PDF, verify the “Open PDF” button launches the PDF in the browser and the file downloads correctly.
- Check that PDF loads on both web and mobile platforms.
