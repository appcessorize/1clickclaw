# frozen_string_literal: true

class Rack::Attack
  # Throttle login attempts by IP address
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle password reset requests by email
  throttle("password_resets/email", limit: 5, period: 1.hour) do |req|
    if req.path == "/users/password" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle registration attempts by IP
  throttle("registrations/ip", limit: 10, period: 1.hour) do |req|
    if req.path == "/users" && req.post?
      req.ip
    end
  end

  # Block suspicious requests
  blocklist("block suspicious requests") do |req|
    # Block requests with suspicious user agents
    Rack::Attack::Fail2Ban.filter("suspicious-agent/#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      req.user_agent.to_s.match?(/curl|wget|python|java|perl|ruby/i) && req.path.match?(/\.(php|asp|aspx|jsp|cgi)$/i)
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    [
      429,
      { "Content-Type" => "application/json" },
      [{ error: "Rate limit exceeded. Please try again later." }.to_json]
    ]
  end

  # Custom response for blocked requests
  self.blocklisted_responder = lambda do |request|
    [
      403,
      { "Content-Type" => "application/json" },
      [{ error: "Access denied." }.to_json]
    ]
  end
end

# Enable Rack::Attack
Rails.application.config.middleware.use Rack::Attack
