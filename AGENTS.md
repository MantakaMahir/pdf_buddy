# Repository Guide

- This is a Flutter web app. Keep PDF processing in the browser.
- Use the existing dependencies and patterns; avoid adding packages without a clear need.
- Never commit `.env` files, credentials, or generated build output.
- Firebase has been removed; deployments use Cloudflare Pages.
- Before finishing code changes, run `flutter analyze` and `flutter test`; for web changes also run `flutter build web --release`.
