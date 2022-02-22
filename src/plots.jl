RecipesBase.@recipe function f(md::ModelData)
    panels = fields(md) |> unique
    d = DataFrames.DataFrame(md)
    pans = [(label=i, blank=false) for i in 1:length(panels)]
    layout --> reshape(pans, 1, length(pans))
    markercolor --> :black
    seriestype := :scatter
    xlabel --> "Time"
    for panel in panels
        x = d[d.fields .== panel, "time"]
        y = d[d.fields .== panel, "value"]
        RecipesBase.@series begin
            subplot := panel
            label --> ""
            seriestype := :scatter
            (x, y)
        end
    end
end

RecipesBase.@recipe function f(mf::ModelFit)
    fun = mf.obj
    data = DataFrames.DataFrame(fun.d)
    ls = link_styles(mf.obj.m)
    optims = [x.minimizer for x in mf.fits]
    logrss = log10.(minimum.(mf.fits))
    logrss_dist = Distributions.Normal(Statistics.mean(logrss, Statistics.std(logrss)))
    times = LinRange(fun.m.tspan..., 100) |> collect
    for optim in optims
        sim = simulate(model(mf), optim)(times) |> link(model(mf))
        for i in 1:size(sim, 2)
            RecipesBase.@series begin
                linecolor --> "gray"
                label --> ""
                alpha --> 1 - Distributions.cdf(logrss_dist, logrss[o])
                (times, sim[:,i])
            end
        end
    end
    RecipesBase.@series begin
        mf.obj.d
    end
    sim = simulate(mf)
    for i in 1:size(sim, 2)
        RecipesBase.@series begin
            yscale --> ls[i]
            datavalues = data[data.fields .== i, "value"]
            if ls[i] == :log10
                lims = log10.((minimum(datavalues), maximum(datavalues)))
                limdiff = lims[2] - lims[1]
                ylimits --> 10 .^ (lims[1] - 0.1*limdiff, lims[2] + 0.1*limdiff)
            else
                lims = (minimum(datavalues), maximum(datavalues))
                limdiff = lims[2] - lims[1]
                ylimits --> (lims[1] - 0.1*limdiff, lims[2] + 0.1*limdiff)
            end
            ylabel --> link_names(mf.obj.m)[i]
            label --> ""
            width --> 2
            linecolor --> "red"
            (times, sim[:,i])
        end
    end
end
