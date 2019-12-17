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




