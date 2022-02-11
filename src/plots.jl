Plots.@recipe function f(md::ModelData)
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
        @series begin
            subplot := panel
            label --> ""
            seriestype := :scatter
            (x, y)
        end
    end
end

Plots.@recipe function f(mf::ModelFit)
    fun = mf.obj
    data = DataFrames.DataFrame(fun.d)
    ls = link_styles(mf.obj.m)
    optim = mf.best
    sim = simulate(mf)
    times = LinRange(fun.m.tspan..., 100) |> collect
    @series begin
        mf.obj.d
    end
    for i in 1:size(sim, 2)
        @series begin
            datavalues = data[data.fields .== i, "value"]
            lims = (minimum(datavalues), maximum(datavalues))
            yscale --> ls[i]
            limdiff = lims[2] - lims[1]
            #ylimits --> (lims[1] - 0.1*limdiff, lims[2] + 0.1*limdiff)
            ylabel --> link_names(mf.obj.m)[i]
            label --> ""
            width --> 2
            linecolor --> "red"
            (times, sim[:,i])
        end
    end
end
