"""AbstractData

AbstractData provides data necessary for our ODE models.

Methods:

- `weights`
- `times`
- `fields`
- `vals`
"""
abstract type AbstractData end

for op in [:weights, :times, :fields, :vals]
    @eval $op(x::AbstractData) = error("`$($op)` not implement for $(typeof(x))")
end

"""AbstractRecursingData <: AbstractData

AbstractRecursingData provides methods for fetching data fields of `AbstractData` from a child object.

Methods:

- `child`
"""
abstract type AbstractRecursingData <: AbstractData end

child(x::AbstractRecursingData) = error("Not implemented")

# These functions defer to the child object in all cases except `ModelData`
for op in [:weights, :times, :fields, :vals]
    @eval $op(x::AbstractRecursingData) = $op(child(x))
end

"""ModelData <: AbstractData
"""
struct ModelData <: AbstractData
    x::Vector{Float64} # value
    t::Vector{Float64} # time
    f::Vector{Int64} # field
    w::Vector{Float64} # weight
    #fieldnames::Vector{String}
    ModelData(x, t, f, w) = length(t) == length(x) == length(f) == length(w) ? new(x, t, f, w) : @error "Mismatched lengths"
end

# ModelData does not have children and we fetch the values from the object itself.
weights(x::ModelData) = x.w
times(x::ModelData) = x.t
fields(x::ModelData) = x.f
vals(x::ModelData) = x.x

"""DataFrame(x::AbstractData)

Create a dataframe from a dataset
"""
function DataFrames.DataFrame(x::AbstractData) 
    DataFrames.DataFrame(:value => vals(x),
                         :time => times(x),
                         :fields => fields(x),
                         :weight => weights(x))
end

# Most important constructor.
function ModelData(d::DataFrames.DataFrame)
    fields = names(d)
    # Mandatory fields
    for field in ["time", "value"]
        if !(field in fields)
            @error "Missing column time"
        end
    end
    # Optional fields both default to 1 for every entry. This turns the
    # weighted euclidean into a regular euclidean.
    if "weight" in fields
        weight = d.weight
    else
        weight = [1 for _ in 1:size(d, 1)]
    end
    if "field" in fields
        field = d.field
    else
        field = [1 for _ in 1:size(d, 1)]
    end
    ModelData(d.value, d.time, field, weight)
end
