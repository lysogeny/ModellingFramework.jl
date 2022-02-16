struct ModelFit <: AbstractRecursingData
    obj::ModelObjective # objective function used
    fits::Array # all fits
    best#::Optim.OptimizationResults # best fit
end

child(m::ModelFit) = m.obj
model(m::ModelFit) = model(m.obj)

function ModelFit(mo::ModelObjective; n=10, ε=1e-10, optimiser=Optim.NelderMead(), optimiser_options=Optim.Options(f_abstol=1e-2, time_limit=120))
    opts = optimise(mo, n=n, ε=ε, optimiser=optimiser, optimiser_options=optimiser_options)
    best = opts[minimum(minimum.(opts)) .== minimum.(opts)][1].minimizer
    ModelFit(mo, opts, best)
end

function parameter_array(mf::ModelFit)
    parameter_array(model(mf.obj), mf.best)
end

function parameter_dict(mf::ModelFit)
    parameter_dict(model(mf.obj), mf.best)
end

function simulate(mf::ModelFit)
    fun = mf.obj
    times = LinRange(fun.m.tspan..., 100) |> collect
    simulate(mf.obj.m, mf.best)(times) |> link(mf.obj.m)
end

residuals(x::ModelFit) = x.obj(x.best)
sample_size(x::ModelFit) = length(x.obj.d.x)
free_parameter_count(x::ModelFit) = free_parameter_count(x.obj.m)
function AIC(x::ModelFit)
    r = residuals(x)
    n = sample_size(x)
    k = free_parameter_count(x)
    n * log(r/n)+2*k+(2*k^2+2*k) / (n-k-1)
end
