function plotoceans(ocns)
    plt = plot()
    for ocn in ocns
        OceanBasins.isocean(ocn) && plot!(plt, ocn.lon, ocn.lat, label=OceanBasins.name(ocn))
    end
    return plt
end


function filloceans(ocns)
    plt = plot()
    for ocn in ocns
        if OceanBasins.isocean(ocn)
            s = Shape(ocn.lon, ocn.lat)
            label = shorten_name(OceanBasins.name(ocn))
            plot!(plt, s, label=label, alpha=0.5)
        end
    end
    return plt
end


function shorten_name(name)
    name = replace(name, " Ocean" => "")
    name = replace(name, "South" => "S")
    name = replace(name, "North" => "N")
    name = replace(name, "eastern part" => "EP")
    name = replace(name, "western part" => "WP")
    name = replace(name, "Atlantic" => "ATL")
    name = replace(name, "Pacific" => "PAC")
    name = replace(name, "Indian" => "IND")
    name = replace(name, "Arctic" => "ARC")
    return name
end



#=
GMT plot for ReadMe
=#
using Libdl
push!(Libdl.DL_LOAD_PATH, "/usr/local/Cellar/gmt/6.0.0_5/lib")
using GMT
coast(region=:d, proj=:Robinson, frame=:g, res=:crude, area=10000, land=:lemonchiffon1, water=:lightsteelblue1, figsize=12)
using OceanBasins
const OCEANS = oceanpolygons()
N = 2000
lons = 360rand(N) .- 180
lats = 180rand(N) .- 90
isocns = [ispacific, isatlantic, isindian, isarctic, ismediterranean, isantarctic]
colors = [sum(iocn * isocns[iocn](lat,lon,OCEANS) for iocn in 1:length(isocns)) for (lat,lon) in zip(lats,lons)]
scatter!(lons, lats, title="Which ocean basin?", marker=:c, size=0.1, zcolor=colors, show=1, savefig="demo.png")
