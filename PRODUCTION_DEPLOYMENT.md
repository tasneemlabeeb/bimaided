# Production Deployment Guide

## ✅ Production-Ready Checklist

### 1. Database Security ✅
- **Contact Inquiries Table**: RLS disabled (public-facing form)
- **Security Layers**:
  - ✅ Honeypot field (hidden from users, catches bots)
  - ✅ Timing check (submissions < 3 seconds = spam)
  - ✅ Spam keyword detection
  - ✅ Link count validation (max 3 links)
  - ✅ Content length validation
  - ✅ Email format validation
  - ✅ Caps lock detection
  - ✅ Google reCAPTCHA v3

### 2. Google reCAPTCHA v3 Setup 🔄

**Current Status**: Using test keys (always pass)

**Production Setup Required**:
1. Visit: https://www.google.com/recaptcha/admin
2. Click "+ Create"
3. Settings:
   - **Label**: `bimaided.com`
   - **reCAPTCHA type**: reCAPTCHA v3
   - **Domains**: 
     - `bimaided.com`
     - `www.bimaided.com`
     - `localhost` (for testing)
4. Click "Submit"
5. Copy the keys:
   - **Site Key**: Replace `NEXT_PUBLIC_RECAPTCHA_SITE_KEY` in .env.local and Docker deployment
   - **Secret Key**: Replace `RECAPTCHA_SECRET_KEY` in .env.local and Docker deployment

**Test Keys (Current)**:
```bash
NEXT_PUBLIC_RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
RECAPTCHA_SECRET_KEY=6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe
```

### 3. Environment Variables

**Required for Production**:
```bash
# Supabase (Self-hosted on VPS)
NEXT_PUBLIC_SUPABASE_URL=http://supabasekong-n4g4og0cos0ocwg0ss8cswss.72.60.222.97.sslip.io
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...

# Supabase Service Role (Server-side only)
SUPABASE_SERVICE_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...

# Email Configuration (Gmail App Password)
EMAIL_USER=bimaided.website@gmail.com
EMAIL_PASSWORD=rwgy biho ilda memw
EMAIL_TO=tasneemlabeeb@gmail.com

# Google reCAPTCHA v3 (⚠️ REPLACE WITH PRODUCTION KEYS)
NEXT_PUBLIC_RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
RECAPTCHA_SECRET_KEY=6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe

# App Configuration
NEXT_PUBLIC_APP_URL=https://bimaided.com
NODE_ENV=production
```

### 4. Build and Deploy

**Step 1: Update .env.local with production reCAPTCHA keys**
```bash
# Edit .env.local
nano .env.local
```

**Step 2: Build Docker Image**
```bash
docker build -t tasneemlabeeb/bimsync-portal:latest .
```

**Step 3: Push to Docker Hub**
```bash
docker push tasneemlabeeb/bimsync-portal:latest
```

**Step 4: Deploy to Production Server**
```bash
export SSHPASS='lWV,S'"'"'8A+&grKvQlQ,7E' && sshpass -e ssh -o StrictHostKeyChecking=no root@72.60.222.97 << 'ENDSSH'
echo "Pulling latest image..."
docker pull tasneemlabeeb/bimsync-portal:latest

echo "Stopping current container..."
docker stop bimsync-portal-live 2>/dev/null || true
docker rm bimsync-portal-live 2>/dev/null || true

echo "Starting production container..."
docker run -d \
    --name bimsync-portal-live \
    --network coolify \
    --restart unless-stopped \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.bimaided-https.rule=Host(\`bimaided.com\`) || Host(\`www.bimaided.com\`)" \
    --label "traefik.http.routers.bimaided-https.entrypoints=https" \
    --label "traefik.http.routers.bimaided-https.tls=true" \
    --label "traefik.http.routers.bimaided-https.tls.certresolver=letsencrypt" \
    --label "traefik.http.routers.bimaided-http.rule=Host(\`bimaided.com\`) || Host(\`www.bimaided.com\`)" \
    --label "traefik.http.routers.bimaided-http.entrypoints=http" \
    --label "traefik.http.services.bimaided.loadbalancer.server.port=3000" \
    -e NODE_ENV=production \
    -e NEXT_PUBLIC_SUPABASE_URL="http://supabasekong-n4g4og0cos0ocwg0ss8cswss.72.60.222.97.sslip.io" \
    -e NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoiYW5vbiJ9.TuGXG83THiqENV8Nern5GwkiS7R6OCY4SGcB9cD-6XE" \
    -e SUPABASE_SERVICE_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoic2VydmljZV9yb2xlIn0.-X1sUGnaBrVLPeh3ZTgJN5SqEb55aI_mauvyKUyE4P8" \
    -e EMAIL_USER="bimaided.website@gmail.com" \
    -e EMAIL_PASSWORD="rwgy biho ilda memw" \
    -e EMAIL_TO="tasneemlabeeb@gmail.com" \
    -e NEXT_PUBLIC_RECAPTCHA_SITE_KEY="YOUR_PRODUCTION_SITE_KEY_HERE" \
    -e RECAPTCHA_SECRET_KEY="YOUR_PRODUCTION_SECRET_KEY_HERE" \
    -e NEXT_PUBLIC_APP_URL="https://bimaided.com" \
    tasneemlabeeb/bimsync-portal:latest

echo ""
echo "Waiting for container to start..."
sleep 5

echo ""
echo "Container status:"
docker ps | grep bimsync-portal-live

echo ""
echo "Testing website..."
curl -I https://bimaided.com | head -5
ENDSSH
```

### 5. Testing

**Local Testing** (http://localhost:3000):
- ✅ Contact form submission
- ✅ reCAPTCHA verification
- ✅ Email notifications
- ✅ Admin dashboard contact inquiries

**Production Testing** (https://bimaided.com):
- [ ] Contact form submission
- [ ] reCAPTCHA score > 0.3
- [ ] Email received
- [ ] Data in admin dashboard

### 6. Security Features

**Contact Form Protection**:
1. **Client-side**:
   - Honeypot field
   - Form timing analysis
   - Content validation
   - reCAPTCHA v3 (invisible)

2. **Server-side**:
   - reCAPTCHA score validation
   - Email format validation
   - Spam keyword detection
   - Rate limiting (via reCAPTCHA)

3. **Database**:
   - No RLS on contact_inquiries (public form)
   - RLS enabled on all other tables
   - Authenticated access required for admin dashboard

### 7. Monitoring

**Check logs**:
```bash
# Production container logs
ssh root@72.60.222.97
docker logs -f bimsync-portal-live

# Database logs
docker logs -f supabase-db-n4g4og0cos0ocwg0ss8cswss
```

**Check contact submissions**:
```bash
# Connect to database
ssh root@72.60.222.97
docker exec -it supabase-db-n4g4og0cos0ocwg0ss8cswss psql -U supabase_admin -d postgres

# View recent submissions
SELECT id, name, email, subject, status, created_at 
FROM public.contact_inquiries 
ORDER BY created_at DESC 
LIMIT 10;
```

## 🚀 Quick Deploy Command

Once you have production reCAPTCHA keys, run:

```bash
# 1. Update .env.local with real keys
# 2. Build and deploy
docker build -t tasneemlabeeb/bimsync-portal:latest . && \
docker push tasneemlabeeb/bimsync-portal:latest && \
./deploy.sh  # Or use the SSH command above
```

## 📝 Notes

- Test keys always return score of 1.0 (perfect human)
- Production keys return actual scores (0.0 = bot, 1.0 = human)
- Recommended threshold: 0.3 (anything below is likely spam)
- Contact inquiries table has RLS disabled for public access
- All other tables have RLS enabled for security
