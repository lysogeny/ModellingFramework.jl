exponential_decay(x₀, β, x) = x₀ * exp(-β*x)
flattening_curve(x₀, β, x) = 0.5 * (1 + exp(-β*x) * (2*x₀-1))
hill(k, n, x) = 1/(1+(k/x)^n)
hill(k, n) = x -> hill(k, n, x)
