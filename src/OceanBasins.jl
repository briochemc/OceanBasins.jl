module OceanBasins

using DataDeps
using DelimitedFiles
using StaticArrays
using PolygonOps



function readdata(datadepname)
    registerfile(datadepname)
    datadeppath = @datadep_str datadepname
    filepath = joinpath(datadeppath, "Limits_of_oceans_and_seas.tab")
    return readdlm(filepath, '\t'; header=true, skipstart=15)
end

struct OceanOrSea{T}
    name::String
    polygon::T
end
name(o::OceanOrSea) = o.name
polygon(o::OceanOrSea) = o.polygon

# lat, lon because that's how the polygons are made
struct Point2D{T} <: FieldVector{2,T}
    lat::T
    lon::T
end

function oceanpolygons(datadepname="Oceans_and_seas")
    cells, headers = readdata(datadepname)
    names = unique(string.(cells[:,1]))
    out = OceanOrSea[]
    for name in names
        iocn = findall(isequal(name), cells[:,1])
        poly = [Point2D(cells[j,2], fixmeridian(cells[j,3])) for j in iocn]
        push!(out, OceanOrSea(name, poly))
    end
    return out
end

# Shortlist of oceans/seas of interest for me
# Don't hesitate to add your own in PRs
const SHORTLIST = [60,61,85,120,146,147,100]
west_pacific() = 60
east_pacific() = 61
atlantic() = 85
indian() = 120
west_arctic() = 146
east_arctic() = 147
mediterranean() = 100
# that have their functions built-in
ispacific(P, oceans) = P ∈ oceans[west_pacific()] || P ∈ oceans[east_pacific()]
isatlantic(P, oceans) = P ∈ oceans[atlantic()]
isindian(P, oceans) = P ∈ oceans[indian()]
isarctic(P, oceans) = P ∈ oceans[west_arctic()] || P ∈ oceans[east_arctic()] || P.lat > 70
ismediterranean(P, oceans) = P ∈ oceans[mediterranean()]
isantarctic(P, oceans) = P.lat ≤ -40
isatlantic2(P, oceans) = isatlantic(P, oceans) && !isantarctic(P, oceans)
ispacific2(P, oceans) = ispacific(P, oceans) && !isantarctic(P, oceans)
isindian2(P, oceans) = isindian(P, oceans) && !isantarctic(P, oceans)
convert_65S_to_90S(P::Point2D{T}) where T = Point2D(P.lat < -65 ? T(-65) : P.lat, P.lon)
isSOatlantic(P, oceans) = isatlantic(convert_65S_to_90S(P), oceans) && isantarctic(P, oceans)
isSOpacific(P, oceans) = ispacific(convert_65S_to_90S(P), oceans) && isantarctic(P, oceans)
isSOindian(P, oceans) = isindian(convert_65S_to_90S(P), oceans) && isantarctic(P, oceans)
isindonesian(P, oceans) = foldl(|, P ∈ oceans[i] for i in 11:37) # Indo throughflow (TODO fix name?)
ismediterranean2(P, oceans) = ismediterranean(P, oceans) || ((30 ≤ P.lat ≤ 50) && !isatlantic(P, oceans) && !ispacific(P, oceans))
isNPAC(P, oceans) = ispacific(P, oceans) && P.lat > 0
isNATL(P, oceans) = isatlantic(P, oceans) && P.lat > 0
isSPAC(P, oceans) = ispacific(P, oceans) && !isantarctic(P, oceans) && P.lat ≤ 0
isSATL(P, oceans) = isatlantic(P, oceans) && !isantarctic(P, oceans) && P.lat ≤ 0

for ocn in (:pacific, :atlantic, :indian, :arctic, :mediterranean, :antarctic,
            :pacific2, :atlantic2, :indian2, :indonesian, :SOatlantic, :SOpacific,
            :SOindian, :mediterranean2, :NPAC, :SPAC, :NATL, :SATL)
    f = Symbol(:is, ocn)
    @eval begin
        """
            $($f)(NT::NamedTuple, oceans)

        Returns `$($f)(NT.lat, NT.lon, oceans)`.
        """
        $f(NT::NamedTuple, oceans) = $f(NT.lat, NT.lon, oceans)
        """
            $($f)(Ps::Vector, oceans)

        Returns the bit vector `[$($f)(P, oceans) for P in Ps]`.
        """
        $f(Ps::Vector, oceans) = [$f(P, oceans) for P in Ps]
        """
            $($f)(lat, lon, oceans)

        Returns `true` if the `(lat,lon)` coordinate is the polygon.
        """
        $f(lat, lon, oceans) = $f(Point2D(lat,lon), oceans)
        """
            $($f)(lat::Vector, lon::Vector, oceans)

        Returns `$($f)(Point2D.(lat,lon), oceans)`.
        """
        $f(lat::Vector, lon::Vector, oceans) = $f(Point2D.(lat,lon), oceans)
        export $f
    end
end


# Convert ±179.99899 to ±180
function fixmeridian(lon)
    if abs(lon) == 179.99899
        return 181.0sign(lon)
    elseif abs(lon) == 0.001
        return 0.0
    else
        return lon
    end
end

whichoceans(P, oceans) = [name(ocn) for ocn in oceans if P ∈ ocn]
whichoceans(lat, lon, oceans) = whichoceans(Point2D(lat,lon), oceans)

whichshortlistoceans(P, oceans) = [name(ocn) for ocn in oceans[SHORTLIST] if P ∈ ocn]
whichshortlistoceans(lat, lon, oceans) = whichshortlistoceans(Point2D(lat,lon), oceans)


function whichshortlistocean(lat, lon, oceans)
    list = whichshortlistoceans(lat, lon, oceans)
    if isempty(list)
        return "None"
    elseif (length(list) == 1)
        return shorten_name(list[1])
    else
        return shorten_name.(list)
    end
end

export OceanOrSea, oceanpolygons, whichshortlistoceans, whichshortlistocean, whichoceans

Base.in(P, ocn::OceanOrSea) = inpolygon(center(P), polygon(ocn), in=true, on=true, out=false)
center(P) = [P[1], mod(P[2] + 180, 360) - 180]

function shorten_name(name)
    name = replace(name, " Ocean" => "")
    name = replace(name, "South " => "S")
    name = replace(name, "North " => "N")
    name = replace(name, ", eastern part" => "e")
    name = replace(name, ", western part" => "w")
    name = replace(name, "Atlantic" => "ATL")
    name = replace(name, "Pacific" => "PAC")
    name = replace(name, "Indian" => "IND")
    name = replace(name, "Arctic" => "ARC")
    return name
end



function registerfile(datadepname)
    register(DataDep(
        datadepname,
        """
        Dataset: Limits of oceans and seas in digitized, machine readable form
        Website: https://doi.pangaea.de/10.1594/PANGAEA.777975
        Author: IHO International Hydrographic Organization, Rainer Sieger
        Date of Publication: March 20, 2012
        License: https://creativecommons.org/licenses/by/3.0/legalcode

        This dataset is the digitized version of the printed "Limits of Oceans and Seas" (IHO, 1953).
        The report describes the boundaries of 148 oceans and seas. The given positions were typed into a spreadsheet and were completed to a right ordered polygon by hand using Google Earth. The dataset consists of five columns.
        The first column contains the name of the ocean or sea, column 2 and 3 contain the position of each polygon point (latitude, longitude). Column 4 contains an area index, column 5 a polygon index. These two indices structurize the dataset.
        The other version link provides a Google Earth layer in KML format (zipped).
        This layer consists of all polygons and names of oceans or seas at area centroid position given in dataset doi:10.1594/PANGAEA.777976.

        Please cite this dataset: International Hydrographic Organization, I. H. O., &amp; Sieger, R. (2012). <i>Limits of oceans and seas in digitized, machine readable form</i> [Data set]. PANGAEA - Data Publisher for Earth and Environmental Science. https://doi.org/10.1594/PANGAEA.777975
        """,
        ["https://doi.pangaea.de/10.1594/PANGAEA.777975?format=textfile"],
        "29c1ec5a1df3e575ef53f0a29de8e3351189666e63e8c2827265aed2025a204b"
    ))
end

end # module
