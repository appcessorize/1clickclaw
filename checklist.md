# MVP Setup Checklist

## 1. Google OAuth Setup

- [ ] Go to [Google Cloud Console](https://console.cloud.google.com)
- [ ] Create a new project (or select existing)
- [ ] Navigate to **APIs & Services > Credentials**
- [ ] Click **Create Credentials > OAuth 2.0 Client ID**
- [ ] Select **Web application**
- [ ] Add authorized redirect URI: `http://localhost:3001/users/auth/google_oauth2/callback`
- [ ] Copy **Client ID** to `.env` as `GOOGLE_CLIENT_ID`
- [ ] Copy **Client Secret** to `.env` as `GOOGLE_CLIENT_SECRET`
- [ ] Enable the **Google+ API** in API Library (may be called "Google People API")

## 2. Stripe Account Setup

- [ ] Create account at [stripe.com](https://stripe.com)
- [ ] Go to **Developers > API Keys**
- [ ] Copy **Publishable key** to `.env` as `STRIPE_PUBLISHABLE_KEY`
- [ ] Copy **Secret key** to `.env` as `STRIPE_SECRET_KEY`

## 3. Stripe Product & Price Setup

- [ ] Go to **Products** in Stripe Dashboard
- [ ] Click **Add Product**
- [ ] Enter product name (e.g., "Pro Plan")
- [ ] Set pricing (e.g., $29/month recurring)
- [ ] Save the product
- [ ] Copy the **Price ID** (starts with `price_`) to `.env` as `STRIPE_PRICE_ID`

## 4. Stripe Webhook Setup (Local Development)

- [ ] Install [Stripe CLI](https://stripe.com/docs/stripe-cli)
- [ ] Run: `stripe login`
- [ ] Run: `stripe listen --forward-to localhost:3001/webhooks/stripe`
- [ ] Copy the webhook signing secret (starts with `whsec_`) to `.env` as `STRIPE_WEBHOOK_SECRET`

## 5. Database Setup

- [ ] Ensure PostgreSQL is running
- [ ] Run: `bin/rails db:create`
- [ ] Run: `bin/rails db:migrate`
- [ ] Run: `bin/rails db:seed` (creates test users)

## 6. Start the App

- [ ] Run: `bin/rails server -p 3001`
- [ ] Visit: http://localhost:3001
- [ ] Click "Continue with Google" to sign in

## 7. Test the Full Flow

- [ ] Sign in with Google
- [ ] Navigate to Pricing page
- [ ] Click Subscribe (redirects to Stripe Checkout)
- [ ] Use test card: `4242 4242 4242 4242` (any future date, any CVC)
- [ ] Complete checkout
- [ ] Verify redirect to Dashboard with active subscription

---

## Stripe Test Cards

| Card Number | Description |
|-------------|-------------|
| 4242 4242 4242 4242 | Success |
| 4000 0000 0000 0002 | Declined |
| 4000 0000 0000 3220 | Requires 3D Secure |

Use any future expiry date and any 3-digit CVC.

---

## Production Checklist (Later)

- [ ] Switch Stripe to live mode keys
- [ ] Add production redirect URI to Google OAuth
- [ ] Set up Stripe webhook endpoint in Dashboard (not CLI)
- [ ] Configure real SMTP for emails
- [ ] Set `RAILS_MASTER_KEY` for credentials
- [ ] Deploy to Coolify/hosting
