"""ModelObjective <: AbstractRecursingData

ModelObjective is a functor that is constructed out of AbstractModelData and an
AbstractModel. It takes parameter vectors and returns an objective value.
"""
struct ModelObjective <: AbstractRecursingData
    d::AbstractData
    m::AbstractModel
end

child(m::ModelObjective) = m.d
model(m::ModelObjective) = m.m

# TODO: change this to not link to output and introduce simulate_link method that does this instead
function simulate(m::ModelObjective, x::AbstractArray)
    simulate(model(m), x, times(m)) |> link(model(m))
end

# TODO: deal with varying norms, currently only computes weighted euclidean distance.
# Possibly create different types of objectives for different norms?
function (m::ModelObjective)(x; ε=1e-10)
    x = parameter_array(model(m), x)
    b = bounds(model(m))
    fixed_indexes = [f.first for f in model(m).fixed]
    x = [i in fixed_indexes ? xi : min(max(xi, bi[1]+ε), bi[2]-ε) for (i, (bi, xi)) in enumerate(zip(b, x))]
    sim = [s[i] for (i, s) in zip(fields(m), eachrow(simulate(m, x)))]
    Distances.weuclidean(sim, vals(m), weights(m))
end

function starts(mo::ModelObjective; n=10, ε=1e-20, iters=200)
    mod = model(mo)
    param_bounds = map(free_parameters(mod)) do param
        bounds(mod, param)
    end
    param_values, _ = LatinHypercubeSampling.LHCoptim(n, length(param_bounds), iters)
    LatinHypercubeSampling.scaleLHC(param_values, [(b[1]+ε, b[2]-ε) for b in param_bounds])
end

function optimise(mo::ModelObjective, s::Vector; optimiser=Optim.NelderMead(), optimiser_options=Optim.Options(f_abstol=1e-2, time_limit=120))
    mod = model(mo)
    o = Optim.optimize(x -> mo(x), lower_bound(mod), upper_bound(mod), s,
                       Optim.Fminbox(optimiser), optimiser_options)
    o
end

function optimise(mo::ModelObjective, s::Matrix; optimiser=Optim.NelderMead(), optimiser_options=Optim.Options(f_abstol=1e-2, time_limit=120))
    map(eachrow(s)) do start
        optimise(mo, collect(start); optimiser=optimiser, optimiser_options=optimiser_options)
    end
end

function optimise(mo::ModelObjective; n=10, ε=1e-10, optimiser=Optim.NelderMead(), optimiser_options=Optim.Options(f_abstol=1e-2, time_limit=120))
    optimise(mo, starts(mo; n=n, ε=ε); optimiser=optimiser, optimiser_options=optimiser_options)
end
