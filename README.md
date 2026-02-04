# ClawSaaS

A complete Rails 8 SaaS starter kit with authentication, subscriptions, and everything you need to launch your next big idea. Built with Rails, TailwindCSS, and DaisyUI.

## Features

- **Authentication**: Email/password and Google OAuth with Devise
- **Authorization**: Role-based access control with Pundit
- **Subscriptions**: Stripe integration with Checkout, webhooks, and customer portal
- **Dashboard**: Member dashboard with subscription management
- **Admin Panel**: User management, subscription oversight, and KPI tracking
- **UI**: Modern, responsive design with TailwindCSS and DaisyUI
- **Dark Mode**: Theme toggle with localStorage persistence
- **Testing**: RSpec, FactoryBot, VCR for API mocking
- **Security**: Rack::Attack rate limiting, CSP headers, CSRF protection

## Prerequisites

- Ruby 3.3+
- PostgreSQL 15+
- Node.js 20+
- Bun (for Tailwind CSS)
- Stripe CLI (for webhook testing)

## Setup

### 1. Clone and install dependencies

```bash
git clone <repository-url>
cd clawsaas
bundle install
yarn install
bun install
```

### 2. Configure environment variables

Copy the example environment file and configure your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

```env
# Database
DATABASE_URL=postgres://localhost:5432/clawsaas_development

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
STRIPE_PRICE_ID=price_xxx

# Google OAuth
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxx

# Email
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your-username
SMTP_PASSWORD=your-password

# Application
APP_HOST=localhost:3001
APP_PROTOCOL=http
```

### 3. Setup database

```bash
bin/rails db:create db:migrate db:seed
```

### 4. Start the development server

```bash
bin/dev
```

Visit `http://localhost:3001`

### Default Users (Development)

| Email | Password | Role |
|-------|----------|------|
| admin@example.com | password123 | Admin |
| member@example.com | password123 | Member |
| trialing@example.com | password123 | Member (Trial) |

## Stripe Setup

### 1. Create a Stripe account

Sign up at [stripe.com](https://stripe.com) and get your API keys from the Dashboard.

### 2. Create a product and price

In Stripe Dashboard:
1. Go to Products > Add Product
2. Create a subscription product (e.g., "Pro Plan - $29/month")
3. Copy the Price ID (starts with `price_`)

### 3. Configure webhook endpoint

For local development, use Stripe CLI:

```bash
stripe listen --forward-to localhost:3001/webhooks/stripe
```

Copy the webhook signing secret and add it to `.env` as `STRIPE_WEBHOOK_SECRET`.

### 4. Configure webhook events

In Stripe Dashboard (for production), add these events:
- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_failed`
- `invoice.payment_succeeded`

## Google OAuth Setup

### 1. Create OAuth credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Go to APIs & Services > Credentials
4. Create OAuth 2.0 Client ID
5. Add authorized redirect URIs:
   - Development: `http://localhost:3001/users/auth/google_oauth2/callback`
   - Production: `https://yourdomain.com/users/auth/google_oauth2/callback`

### 2. Enable Google+ API

In the API Library, enable the Google+ API for your project.

## Testing

```bash
# Run all tests
bundle exec rspec

# Run specific tests
bundle exec rspec spec/models/
bundle exec rspec spec/requests/

# Run with coverage
COVERAGE=true bundle exec rspec
```

## Deployment

### Coolify (with Nixpacks)

The project includes `nixpacks.toml` for automatic builds.

1. Connect your repository to Coolify
2. Set environment variables in Coolify dashboard
3. Deploy!

Required environment variables:
- `RAILS_MASTER_KEY`
- `DATABASE_URL`
- `STRIPE_*` variables
- `GOOGLE_*` variables
- `SMTP_*` variables

### Other Platforms

The project includes:
- `Dockerfile` for container deployments
- `Procfile` for Heroku-like platforms
- Standard Rails setup for traditional VPS deployment

## Project Structure

```
app/
├── controllers/
│   ├── admin/           # Admin panel controllers
│   ├── users/           # Devise overrides (OAuth callbacks)
│   ├── webhooks/        # Stripe webhook handling
│   ├── dashboard_controller.rb
│   ├── home_controller.rb
│   └── subscriptions_controller.rb
├── models/
│   ├── user.rb          # Devise user with roles/subscriptions
│   └── subscription_event.rb  # Webhook audit log
├── policies/            # Pundit authorization policies
├── services/
│   └── stripe/          # Stripe service objects
├── views/
│   ├── admin/           # Admin panel views
│   ├── dashboard/       # Member dashboard
│   ├── devise/          # Custom auth views
│   ├── home/            # Marketing pages
│   └── shared/          # Navbar, footer, flash
└── javascript/
    └── controllers/     # Stimulus controllers
```

## Security

See [SECURITY.md](SECURITY.md) for security practices and vulnerability reporting.

## License

MIT License
