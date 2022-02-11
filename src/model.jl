"""AbstractModel

`AbstractModel`s consist of the following interface:

- θ -> D, called `simulate`. Takes parameters and returns model output.
- D -> D*, called `link`. Takes model output and returns observed data.

To create a model, implement at least:

- `parameter_names`, a function that returns a vector of names for the parameter vector
- `simulate`, a function that takes a parameter vector and returns simulations.

Optionally:

- `link` (defaults to identity)
- `output_names` (not technically used)
- `link_names` (not technically used)
"""
abstract type AbstractModel end
# TODO: consider moving links into separate type `AbstractLink` as they don't make much sense in this function

output_names(t::AbstractModel) = @error "Not implemented"
link_names(t::AbstractModel) = @error "Not implemented"

"""simulate(t::AbstractModel, x)
simulate(t::AbstractModel, x::AbstractVector)
simulate(t::AbstractModel)::Function

Simulate a model using parameters provided in `x`
"""
simulate(t::AbstractModel, x::AbstractVector) = @error "Not implemented"# = simulate(t, x...)
simulate(t::AbstractModel, x::AbstractDict{Symbol, N}) where {N <: Number} = simulate(t, parameter_array(t, x))
simulate(t::AbstractModel) = x -> simulate(t, x)

"""link(t::AbstractModel, x::AbstractArray)
link(t::AbstractModel)::Function

Takes model outputs and applies transformations to it to make it appear like
the data that the user provided.
Defaults to `identity`, overload at your leisure.

Provides a curried version, `link(::AbstractModel)::Function`
"""
link(t::AbstractModel, x::AbstractArray) = identity(x)
link(t::AbstractModel) = x -> link(t, x)

"""parameter_names(t::AbstractModel)

Returns the names for the parameter vector(s)
"""
parameter_names(t::Type{AbstractModel}) = @error "Not implemented"
parameter_names(t::AbstractModel) = parameter_names(typeof(t))

"""free_parameters(t::AbstractModel)

Return vector of fittable (i.e. non-fixed) parameter Symbols for model `t`
"""
function free_parameters(t::AbstractModel)
    parameters_should = parameter_names(t)
    parameters_have = [parameters_should[fix.first] for fix in t.fixed]
    setdiff(parameters_should, parameters_have)
end

"""free_parameter_count(t::AbstractModel)

How many parameters are free in model `t`
"""
function free_parameter_count(t::AbstractModel)
    length(free_parameters(t))
end

"""parameter_count(t::AbstractModel)

How many parameters are present in model `t` (total)
"""
function parameter_count(t::AbstractModel)
    length(parameter_names(t))
end

"""parameter_index(t::AbstractModel, name::Symbol)

Return index of parameter `name` in model `t`
"""
function parameter_index(t::AbstractModel, name::Symbol)
    findfirst(parameter_names(t) .== name)
end

"""parameter_array(t::AbstractModel, d::Dict{Symbol, Number})
parameter_array(t::AbstractModel, x::Array)

Create a parameter array (full) for model `t` from either a dict `d` or an array.
"""
function parameter_array(t::AbstractModel, d::AbstractDict{Symbol, N}; eltype=Float64) where {N <: Number}
    n = parameter_count(t)
    parameters = zeros(eltype, n)
    for (name, value) in d
        parameters[parameter_index(t, name)] = value
    end
    for (index, value) in t.fixed
        parameters[index] = value
    end
    parameters
end
function parameter_array(t::AbstractModel, x::AbstractArray; eltype=Float64)
    n = parameter_count(t)
    parameters = zeros(eltype, n)
    skipindices = map(x -> x.first, t.fixed)
    xi = 1
    for i=1:n
        if i in skipindices
            continue
        end
        parameters[i] = x[xi]
        xi +=1
    end
    for (index, value) in t.fixed
        parameters[index] = value
    end
    parameters
end

"""parameter_dict(t::AbstractModel, x::AbstractArray)

Create a dictionary with parameters
"""
function parameter_dict(t::AbstractModel, x::AbstractArray)
    free = Dict(
         k => v
         for (v, k) in zip(x, free_parameters(t))
    )
    fix = Dict(
        parameter_names(t)[x.first] => x.second
        for x in t.fixed
    )
    merge(free, fix)
end
function parameter_dict(t::AbstractModel, x::AbstractDict)
    fix = Dict(
        parameter_names(t)[x.first] => x.second
        for x in t.fixed
    )
    merge(x, fix)
end

"""bounds(t::AbstractModel)::Vector{Tuple{Number, Number}}

Bounds for the models optimiser space
"""
bounds(t::AbstractModel) = @error "Not implemented"
bounds(t::AbstractModel, parameter::Integer) = bounds(t)[parameter]
bounds(t::AbstractModel, parameter::Symbol) = bounds(t)[parameter_index(t, parameter)]
lower_bound(t::AbstractModel) = map(param -> bounds(t, param)[1], free_parameters(t))
upper_bound(t::AbstractModel) = map(param -> bounds(t, param)[2], free_parameters(t))
