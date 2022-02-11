"""ODEModel

Extends AbstractModel by providing a `simulate`.
`simulate` also returns a function that handles timepoints unless given some timepoints.

Additionally provides fields:

- `tspan`: timespan to solve in

Additionally provides methods:

- `initial`
- `ratefun`

To implement an `ODEModel`, implement:

- `initial`
- `ratefun`
- `parameter_names`
"""
abstract type ODEModel <: AbstractModel end

# Empty model
function (::Type{T})(tspan::Tuple{Float64, Float64}) where {T <: ODEModel}
    T(tspan, Vector{Pair{Int64, Float64}}())
end
# Allow symbolic parameter fixation.
function (::Type{T})(tspan::Tuple{Float64, Float64}, fixed::AbstractDict{Symbol, N}) where {T <: ODEModel, N <: Number}
    names = parameter_names(T)
    fixed = filter(x -> x.first in names, fixed) # only keep keys that are in the names for this type
    fixed = [findfirst(key .== names) => value for (key, value) in fixed]
    T(tspan,  fixed)
end

initial(::ODEModel, x::AbstractVector) = @error "Not implemented"
ratefun(::ODEModel) = @error "Not implemented"

function simulate(t::ODEModel, x::AbstractVector)
    x = length(x) != parameter_count(t) ? parameter_array(t, x) : x
    u₀ = initial(t, x)
    rates! = ratefun(t)
    problem = DifferentialEquations.ODEProblem(rates!, u₀, t.tspan, x)
    solution = solve(problem)#, alg_hints=[:stiff])
    #times = LinRange(t.tspan[1], t.tspan[2], steps)
    times -> collect(hcat(DifferentialEquations.solution(times).u...)')
end
function simulate(t::ODEModel, x::AbstractVector, times::AbstractVector)
    simulate(t, x)(times)
end
simulate(t::ODEModel, x::AbstractDict{Symbol, N}, times::AbstractVector) where {N <: Number} = simulate(t, parameter_array(t, x), times)

#simulate_link(t::ODEModel, x::AbstractVector, times::AbstractVector) = simulate(t, x, times) |> link(t)
