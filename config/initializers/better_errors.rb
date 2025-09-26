if defined?(BetterErrors)
  # libera o console para qualquer IP (cuidado, apenas em dev)
  BetterErrors::Middleware.allow_ip! "0.0.0.0/0"
end
