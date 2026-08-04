# Gallery site — setup guide

## 1. Put this online with GitHub Pages

1. Create a new **public** repo on GitHub (e.g. `gallery`).
2. Upload everything, keeping the folder structure:
   - `index.html`
   - `images/` folder (sample SVGs + `manifest.json`)
   - `.github/workflows/build-manifest.yml`
   - `scripts/build-manifest.sh`
3. In the repo: **Settings → Pages → Build and deployment → Source = Deploy from a branch**, branch `main`, folder `/ (root)`. Save.
4. GitHub gives you a live URL like `https://yourusername.github.io/gallery/` within a minute or two.

**Note:** the workflow watches the `main` branch. If your repo's default branch is named something else (e.g. `master`), edit that in `.github/workflows/build-manifest.yml`.

## 2. Add images — this is now fully automatic

1. Go to the `images` folder in your repo on github.com
2. **Add file → Upload files**, drag your photo(s) in, commit
3. That's it. A GitHub Action runs automatically, scans the folder, and rewrites `images/manifest.json` for you. The site picks up the new image on next page load (usually live within a minute).

The image's **title** is generated from the filename — dashes and underscores become spaces, each word capitalized. So:
- `catalina-sunset.jpg` → **Catalina Sunset**
- `2026_race_day_start.png` → **2026 Race Day Start**

Removing an image works the same way: delete the file from `images/` in GitHub, commit, and the manifest updates itself to drop it.

## 3. Point a custom domain at it

Once you've picked a domain name (from a registrar like Namecheap, same as `junkrigsaildesigner.com`):

1. In the repo: **Settings → Pages → Custom domain** → enter your domain → Save. This creates a `CNAME` file automatically.
2. At your registrar's DNS settings:
   - **Apex domain** (`example.com`): four **A records** pointing to:
     ```
     185.199.108.153
     185.199.109.153
     185.199.110.153
     185.199.111.153
     ```
   - **Subdomain** (`www.example.com`): a **CNAME record** pointing to `yourusername.github.io`.
3. Wait for DNS to propagate (usually under an hour), then check "Enforce HTTPS" in Pages settings once the certificate is ready.

## How the automation works (for reference)

- `scripts/build-manifest.sh` scans `images/`, builds a JSON list of every image file with a title (from filename) and a tag (file extension).
- `.github/workflows/build-manifest.yml` runs that script automatically on every push that touches the `images/` folder, then commits the updated `manifest.json` back to the repo.
- `index.html` fetches `images/manifest.json` on page load and renders the grid from it — no manual editing needed.
- Supported file types: jpg, jpeg, png, gif, webp, svg, avif.
- Avoid commas or quote marks in filenames — keep to letters, numbers, dashes, and underscores.

## Notes

- Because the page fetches `manifest.json`, opening `index.html` directly by double-clicking it won't show images (browsers block that fetch for local files). It works fine once hosted on GitHub Pages, or if you run a local server like `python3 -m http.server` while testing.
- Since you mentioned expanding this into a home page for other projects later, you can add new pages (e.g. `racemaster.html`) to the same repo and link them from the header whenever you're ready.
