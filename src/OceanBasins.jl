module OceanBasins

using DataDeps, DelimitedFiles

function readdata(datadepname)
    registerfile(datadepname)
    datadeppath = @datadep_str datadepname
    filepath = joinpath(datadeppath, "Limits_of_oceans_and_seas.tab")
    return readdlm(filepath, '\t'; header=true, skipstart=15)
end

struct OceanOrSea
    name::String
    lat::Vector{Float64}
    lon::Vector{Float64}
    index::Vector{Int64}
end

struct OceansAndSeas
    data::Vector{OceanOrSea}
end

function OceansAndSeas(datadepname="Oceans_and_seas")
    cells, headers = readdata(datadepname)
    data = OceanOrSea[]
    lat = Float64[]
    lon = Float64[]
    index = Int64[]
    name = ""
    for i in 1:size(cells,1)
        if cells[i,5] == 1 
            i ≠ 1 && push!(data, OceanOrSea(name,copy(lat),copy(lon),copy(index)))
            name = cells[i,1]
            empty!(lat)
            empty!(lon)
            empty!(index)
        end
        push!(lat, cells[i,2])
        push!(lon, cells[i,3])
        push!(index, cells[i,5])
    end
    return OceansAndSeas(data)
end

Base.iterate(ocns::OceansAndSeas) = ocns.data[1], 1
Base.iterate(ocns::OceansAndSeas, i) = i == length(ocns) ? nothing : (ocns.data[i+1], i+1)

Base.length(ocns::OceansAndSeas) = length(ocns.data)

Base.names(ocns::OceansAndSeas) = [name(ocn) for ocn in ocns]
name(ocn::OceanOrSea) = ocn.name

isocean(ocn::OceanOrSea) = occursin("Ocean", name(ocn))
issea(ocn::OceanOrSea) = occursin("Sea", name(ocn))
oceannames(ocns::OceansAndSeas) = [name(ocn) for ocn in ocns if isocean(ocn)]
seanames(ocns::OceansAndSeas) = [name(ocn) for ocn in ocns if issea(ocn)]

oceans(ocns::OceansAndSeas) = [ocn for ocn in ocns if isocean(ocn)]

function whichocean(lat,lon)

    return nothing
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



end # module
