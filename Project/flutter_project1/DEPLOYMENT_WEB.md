# Web Deployment Guide - AutoCompanion

This guide will help you deploy your Flutter web app to various hosting platforms.

## 🚀 Quick Start

### Step 1: Build for Production

```bash
cd a:\Project\flutter_project1
flutter build web --release
```

This creates optimized files in `build/web/` directory.

### Step 2: Test the Build Locally

```bash
# Install a simple HTTP server (if not already installed)
dart pub global activate dhttpd

# Serve the built web app
dhttpd --path=build/web
```

Open `http://localhost:8080` to test.

---

## 🌐 Deployment Options

### Option 1: Firebase Hosting (Recommended - Free Tier Available)

**Advantages:**
- Free tier with generous limits
- CDN included
- Custom domain support
- HTTPS by default
- Easy rollback

**Steps:**

1. **Install Firebase CLI:**
```bash
npm install -g firebase-tools
```

2. **Login to Firebase:**
```bash
firebase login
```

3. **Initialize Firebase in your project:**
```bash
cd a:\Project\flutter_project1
firebase init hosting
```

**Configuration choices:**
- What do you want to use as your public directory? → `build/web`
- Configure as a single-page app? → `Yes`
- Set up automatic builds? → `No`
- File build/web/index.html already exists. Overwrite? → `No`

4. **Deploy:**
```bash
flutter build web --release
firebase deploy --only hosting
```

5. **Your app will be live at:**
```
https://your-project-id.web.app
https://your-project-id.firebaseapp.com
```

**Custom Domain (Optional):**
- Go to Firebase Console → Hosting
- Click "Add custom domain"
- Follow DNS configuration steps

---

### Option 2: Netlify (Easy & Free)

**Advantages:**
- Super easy deployment
- Free tier
- Continuous deployment from Git
- Custom domains

**Method A: Drag & Drop (Easiest)**

1. Build your app: `flutter build web --release`
2. Go to [app.netlify.com](https://app.netlify.com)
3. Drag the `build/web` folder to Netlify
4. Done! Your site is live

**Method B: Netlify CLI**

1. **Install Netlify CLI:**
```bash
npm install -g netlify-cli
```

2. **Deploy:**
```bash
cd a:\Project\flutter_project1
flutter build web --release
netlify deploy --prod --dir=build/web
```

3. **Follow prompts to create/link site**

**netlify.toml** (create this file in your project root):
```toml
[build]
  publish = "build/web"
  command = "flutter build web --release"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

---

### Option 3: Vercel (Fast & Free)

**Advantages:**
- Extremely fast CDN
- Free tier
- Great performance
- Easy GitHub integration

**Steps:**

1. **Install Vercel CLI:**
```bash
npm install -g vercel
```

2. **Deploy:**
```bash
cd a:\Project\flutter_project1
flutter build web --release
vercel --prod
```

3. **Follow prompts**
   - Set build output directory: `build/web`

**vercel.json** (create in project root):
```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "devCommand": "flutter run -d web-server --web-port=3000",
  "routes": [
    {
      "handle": "filesystem"
    },
    {
      "src": "/.*",
      "dest": "/index.html"
    }
  ]
}
```

---

### Option 4: GitHub Pages (Free)

**Steps:**

1. **Build your app:**
```bash
flutter build web --release --base-href "/your-repo-name/"
```

2. **Push to GitHub:**
```bash
cd build/web
git init
git add .
git commit -m "Deploy web app"
git branch -M gh-pages
git remote add origin https://github.com/yourusername/your-repo-name.git
git push -u origin gh-pages --force
```

3. **Enable GitHub Pages:**
   - Go to repo Settings → Pages
   - Source: Deploy from branch
   - Branch: `gh-pages` / root
   - Save

4. **Access at:** `https://yourusername.github.io/your-repo-name/`

---

### Option 5: Traditional Web Hosting (Hostinger, Bluehost, etc.)

**Steps:**

1. **Build your app:**
```bash
flutter build web --release
```

2. **Upload files:**
   - Use FTP/SFTP client (FileZilla, WinSCP)
   - Upload all files from `build/web/` to your hosting's `public_html` or `www` directory

3. **Configure:**
   - Ensure server redirects all routes to `index.html`
   - Enable HTTPS

**.htaccess** (for Apache servers):
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

---

## 🔧 Build Optimization Tips

### 1. Optimize Build Size

```bash
flutter build web --release --web-renderer html
# or for better performance on desktop
flutter build web --release --web-renderer canvaskit
```

### 2. Enable PWA (Progressive Web App)

Update `web/manifest.json`:
```json
{
  "name": "AutoCompanion",
  "short_name": "AutoCompanion",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0175C2",
  "theme_color": "#0175C2",
  "description": "Your intelligent travel companion",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### 3. Add Service Worker for Offline Support

The Flutter build automatically includes a service worker. Ensure it's registered in `web/index.html`.

---

## 🌍 Environment Configuration

For different environments (dev, staging, production):

**1. Create environment files:**

`lib/config/env_config.dart`:
```dart
class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://your-backend-dev.com',
  );
  
  static String get baseUrl => isProduction 
    ? 'https://your-backend-prod.com' 
    : apiUrl;
}
```

**2. Build with environment:**

```bash
# Development
flutter build web --release --dart-define=API_URL=https://dev-api.example.com

# Production
flutter build web --release --dart-define=PRODUCTION=true --dart-define=API_URL=https://api.example.com
```

---

## ✅ Pre-Deployment Checklist

- [ ] Test app in production mode locally
- [ ] Verify all API endpoints use production URLs
- [ ] Check Firebase/Supabase configuration for production
- [ ] Test on different browsers (Chrome, Firefox, Safari, Edge)
- [ ] Test responsive design on mobile browsers
- [ ] Verify all images and assets load correctly
- [ ] Check console for errors
- [ ] Test authentication flows
- [ ] Verify external links work
- [ ] Check loading performance
- [ ] Enable analytics (Google Analytics, Firebase Analytics)
- [ ] Set up error tracking (Sentry, Firebase Crashlytics)
- [ ] Configure CORS if needed for API calls
- [ ] Add robots.txt and sitemap.xml for SEO
- [ ] Test PWA functionality (offline mode, install prompt)

---

## 🔒 Security Considerations

1. **Environment Variables:**
   - Never commit API keys to repository
   - Use environment variables for sensitive data
   - Use Firebase Remote Config for dynamic configuration

2. **HTTPS:**
   - Always use HTTPS in production
   - Most hosting platforms provide free SSL

3. **API Keys:**
   - Restrict Firebase API keys to your domain
   - Set up CORS properly on your backend

---

## 📊 Monitoring & Analytics

**Add Google Analytics:**

1. Get tracking ID from [Google Analytics](https://analytics.google.com)

2. Add to `web/index.html`:
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

**Firebase Analytics:**
Already configured if using Firebase!

---

## 🚨 Troubleshooting

**Issue: Blank page after deployment**
- Check browser console for errors
- Verify base-href is correct
- Check server redirects to index.html

**Issue: Images not loading**
- Verify asset paths in pubspec.yaml
- Check image URLs are relative, not absolute
- Clear browser cache

**Issue: API calls failing**
- Check CORS configuration
- Verify API URLs are production URLs
- Check browser console for network errors

**Issue: Firebase Auth not working**
- Add your domain to Firebase Console → Authentication → Settings → Authorized domains

---

## 📞 Support

- Flutter Web Docs: https://flutter.dev/docs/deployment/web
- Firebase Hosting: https://firebase.google.com/docs/hosting
- Netlify Docs: https://docs.netlify.com
- Vercel Docs: https://vercel.com/docs

---

**Your web app is ready to deploy! Choose a platform and follow the steps above. Firebase Hosting is recommended for beginners.** 🚀
