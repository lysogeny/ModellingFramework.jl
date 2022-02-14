module ModellingFramework

import DataFrames
import LatinHypercubeSampling
import DifferentialEquations
import Optim
import Distances
import Plots

include("model_data.jl")
include("model.jl")
include("ode_model.jl")
include("model_objective.jl")
include("model_fit.jl")
include("helpers.jl")
include("plots.jl")

# Types
export ModelData,
    ModelFit,
    ModelObjective,
    ODEModel,
    # Helpers
    parameter_array,
    parameter_dict,
    parameter_index,
    link_styles,
    # Model methods
    initial,
    ratefun,
    bounds,
    lower_bound,
    upper_bound,
    link,
    simulate,
    starts,
    output_names,
    link_names,
    child,
    model,
    # Data methods
    weights,
    times,
    fields,
    vals,
    residuals,
    sample_size,
    free_parameter_count,
    AIC,
    # Maths
    exponential_decay,
    flattening_curve,
    hill

end # module
