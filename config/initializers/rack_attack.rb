class Rack::Attack
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/api/v1/login" && req.post?
  end

  throttle("requests/ip", limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  self.throttled_responder = lambda do |_request|
    [ 429, { "Content-Type" => "application/json" }, [ { error: "Too many requests. Try again later." }.to_json ] ]
  end
end
