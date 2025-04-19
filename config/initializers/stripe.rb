Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")

Rails.configuration.stripe = {
  publishable_key: ENV.fetch("STRIPE_PUBLIC_KEY"),
  secret_key:      ENV.fetch("STRIPE_SECRET_KEY")
}