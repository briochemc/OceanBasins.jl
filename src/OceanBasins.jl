module OceanBasins

using DataDeps, DelimitedFiles
using StaticArrays, RoamesGeometry

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

struct Point2D{T} <: FieldVector{2,T}
    lat::T
    lon::T
end

function oceanpolygons(datadepname="Oceans_and_seas")
    cells, headers = readdata(datadepname)
    names = unique(string.(cells[:,1]))
    out = OceanOrSea[]
    for name in names
        occursin("Ocean", name) || continue
        iocn = findall(isequal(name), cells[:,1])
        poly = Polygon([Point2D(cells[j,2], antimeridian(cells[j,3])) for j in iocn]...)
        push!(out, OceanOrSea(name, poly))
    end
    return out
end

# Convert ±179.99899 to ±180
antimeridian(lon) = (abs(lon) == 179.99899) ? 181.0sign(lon) : lon


whichoceans(P::Point2D) = [ocn.name for ocn in OCEANS if P ∈ ocn.polygon]
whichoceans(lat,lon) = whichoceans(Point2D(lat,lon))


whichsuperoceans(P::Point2D) = [ocn.name for ocn in SUPEROCEANS if P ∈ ocn.polygon]
whichsuperoceans(lat,lon) = whichsuperoceans(Point2D(lat,lon))

function whichsuperocean(lat,lon)
    list = whichsuperoceans(lat,lon)
    isempty(list) && return ""
    (length(list) == 1) && return shorten_name(list[1])
    return shorten_name.(list)
end

export OceanOrSea, oceanpolygons, whichsuperocean

ispacific(P::Point2D) = P ∈ PACe.polygon || P ∈ PACw.polygon
ispacific(lat,lon) = ispacific(Point2D(lat,lon))

isatlantic(P::Point2D) = P ∈ ATL.polygon
isatlantic(lat,lon) = isatlantic(Point2D(lat,lon))

isindian(P::Point2D) = P ∈ IND.polygon
isindian(lat,lon) = isindian(Point2D(lat,lon))

isarctic(P::Point2D) = P ∈ ARCe.polygon || P ∈ ARCw.polygon
isarctic(lat,lon) = isarctic(Point2D(lat,lon))

isantarctic(lat,lon) = lat ≤ -40

export ispacific, isatlantic, isindian, isarctic, isantarctic




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
    	Website: https://figshare.com/articles/Limits_of_oceans_and_seas_in_digitized_machine_readable_form/10860656
    	Author: IHO International Hydrographic Organization, Rainer Sieger
    	Date of Publication: 2019-11-22T22:18:18Z
    	License: CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/)

    	This dataset is the digitized version of the printed "Limits of Oceans and Seas" (IHO, 1953). The report describes the boundaries of 148 oceans and seas. The given positions were typed into a spreadsheet and were completed to a right ordered polygon by hand using Google Earth. The dataset consists of five columns. The first column contains the name of the ocean or sea, column 2 and 3 contain the position of each polygon point (latitude, longitude). Column 4 contains an area index, column 5 a polygon index. These two indices structurize the dataset.
    	The other version link provides a Google Earth layer in KML format (zipped). This layer consists of all polygons and names of oceans or seas at area centroid position given in dataset doi:10.1594/PANGAEA.777976.

    	Please cite this dataset: International Hydrographic Organization, I. H. O., &amp; Sieger, R. (2012). <i>Limits of oceans and seas in digitized, machine readable form</i> [Data set]. PANGAEA - Data Publisher for Earth &amp; Environmental Science. https://doi.org/10.1594/PANGAEA.777975
    	""",
    	"https://ndownloader.figshare.com/files/19364984",
        "73055ed2b356c352d5c99ef0a1fb03aef9819bc7c55b02cc26eaecd14cc5377d"
    ))
end

# once everything is set up, build it and export it
const OCEANS = oceanpolygons()
const SUPEROCEANS = OCEANS[[5,6,9,10,11,12]]
const PACe = SUPEROCEANS[1]
const PACw = SUPEROCEANS[2]
const ATL = SUPEROCEANS[3]
const IND = SUPEROCEANS[4]
const ARCe = SUPEROCEANS[5]
const ARCw = SUPEROCEANS[6]

export OCEANS, SUPEROCEANS


end # module
