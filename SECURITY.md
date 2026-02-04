# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it by emailing security@example.com. Do not open a public GitHub issue.

We will acknowledge receipt within 48 hours and provide a detailed response within 7 days indicating the next steps for handling your report.

## Security Measures

### Authentication

- **Password hashing**: Bcrypt with cost factor 12 (Devise default)
- **Email confirmation**: Required before account activation
- **Session management**: Secure cookies with `SameSite=Lax`
- **CSRF protection**: Enabled by default in Rails
- **OAuth**: Google OAuth 2.0 with verified email requirement

### Authorization

- **Role-based access**: Pundit policies enforce member/admin separation
- **Controller authorization**: `after_action :verify_authorized` ensures all actions are authorized
- **Subscription gating**: Dashboard access requires active or trialing subscription

### Rate Limiting

Rate limiting is implemented via Rack::Attack:

| Endpoint | Limit |
|----------|-------|
| Login attempts | 5 per 20 seconds per IP |
| Sign up | 3 per minute per IP |
| Password reset | 3 per minute per IP |
| General API | 300 per 5 minutes per IP |

Blocked requests receive HTTP 429 (Too Many Requests).

### Content Security Policy

Strict CSP headers are configured via `config/initializers/content_security_policy.rb`:

- `default-src 'self'`
- `script-src 'self'` (with nonce for inline scripts)
- `style-src 'self' 'unsafe-inline'` (required for Tailwind)
- `img-src 'self' data: https:`
- `connect-src 'self' https://api.stripe.com`
- `frame-src https://js.stripe.com https://hooks.stripe.com`

### Stripe Security

- **Webhook verification**: All webhooks verified using Stripe signature
- **Idempotency**: Webhook events are deduplicated via `stripe_event_id`
- **Audit logging**: All subscription events recorded in `subscription_events` table
- **No card storage**: Payment details handled entirely by Stripe

### Data Protection

- **Encryption at rest**: Relies on PostgreSQL and hosting provider
- **Encryption in transit**: HTTPS enforced in production via `config.force_ssl = true`
- **Sensitive data**: Stripe IDs stored, not payment details
- **Password requirements**: Minimum 6 characters (Devise default)

## Security Headers

The following headers are set in production:

```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: interest-cohort=()
```

## Dependency Management

### Automated Scanning

- **Brakeman**: Static analysis for Rails security vulnerabilities (CI)
- **bundler-audit**: Checks for known CVEs in Ruby gems (CI)
- **Dependabot**: Automated dependency updates (configure in GitHub)

### Manual Checks

Run security scans locally:

```bash
# Rails security vulnerabilities
bin/brakeman

# Gem vulnerabilities
bin/bundler-audit --update

# Update gems
bundle update --conservative
```

## Secret Management

### Required Secrets

| Secret | Purpose |
|--------|---------|
| `RAILS_MASTER_KEY` | Decrypt credentials |
| `STRIPE_SECRET_KEY` | Stripe API access |
| `STRIPE_WEBHOOK_SECRET` | Verify webhook signatures |
| `GOOGLE_CLIENT_SECRET` | Google OAuth |
| `SMTP_PASSWORD` | Email delivery |

### Rotation Procedures

1. **Rails master key**: Re-encrypt credentials with `rails credentials:edit`
2. **Stripe keys**: Rotate in Stripe Dashboard, update environment
3. **Google OAuth**: Regenerate in Google Cloud Console
4. **Database credentials**: Coordinate with hosting provider

### Best Practices

- Never commit secrets to version control
- Use environment variables or encrypted credentials
- Rotate secrets periodically (quarterly recommended)
- Use different secrets for development/staging/production

## Incident Response

### If You Suspect a Breach

1. Rotate all secrets immediately
2. Review Stripe Dashboard for unauthorized activity
3. Check `subscription_events` for anomalies
4. Review server access logs
5. Notify affected users if data was exposed

### Logging

Security-relevant events are logged:

- Failed login attempts
- Password changes
- Subscription status changes
- Webhook processing errors

## Development Security

### Local Development

- Use `.env` for local secrets (gitignored)
- Test Stripe webhooks via `stripe listen --forward-to localhost:3000/webhooks/stripe`
- Never use production API keys in development

### Code Review Checklist

- [ ] No hardcoded secrets
- [ ] Authorization checks present
- [ ] Input validation for user data
- [ ] SQL injection prevention (use parameterized queries)
- [ ] XSS prevention (escape output)
- [ ] CSRF tokens on state-changing forms

## Compliance Notes

This starter provides a foundation but may require additional measures for:

- **GDPR**: Add data export/deletion features
- **PCI DSS**: Handled by Stripe (no card data touches your servers)
- **SOC 2**: Requires additional logging and access controls

Consult with a security professional for compliance requirements specific to your jurisdiction and industry.
