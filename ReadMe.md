
<img src="https://user-images.githubusercontent.com/4486578/79578964-4b3a7600-810a-11ea-8960-f758cf41f765.png" width="50%"/>

# OceanBasins.jl

A set of simple functions to determine which ocean basin a (lat,lon) coordinate is in.

<p>
  <a href="https://github.com/briochemc/OceanBasins.jl/actions">
    <img src="https://img.shields.io/github/workflow/status/briochemc/OceanBasins.jl/Mac%20OS%20X?label=OSX&logo=Apple&logoColor=white&style=flat-square">
  </a>
  <a href="https://github.com/briochemc/OceanBasins.jl/actions">
    <img src="https://img.shields.io/github/workflow/status/briochemc/OceanBasins.jl/Linux?label=Linux&logo=Linux&logoColor=white&style=flat-square">
  </a>
  <a href="https://github.com/briochemc/OceanBasins.jl/actions">
    <img src="https://img.shields.io/github/workflow/status/briochemc/OceanBasins.jl/Windows?label=Windows&logo=Windows&logoColor=white&style=flat-square">
  </a>
  <a href="https://codecov.io/gh/briochemc/OceanBasins.jl">
    <img src="https://img.shields.io/codecov/c/github/briochemc/OceanBasins.jl/master?label=Codecov&logo=codecov&logoColor=white&style=flat-square">
  </a>
</p>


OceanBasins.jl essentially provides functions to algorithmically determine if a (lat,lon) coordinate lies in a specific ocean or sea.
(It was developed to mask regions of interest for my personal research endeavours, i.e., global marine biogeochemical modelling with [AIBECS.jl](https://github.com/briochemc/AIBECS.jl).)

### Usage

To load the ocean/sea polygons, start with

```julia
OCEANS = oceanpolygons()
```

Note that the first time you call `oceanpolygons()`, it will download the [*Limits of oceans and seas in digitized, machine readable* dataset](https://figshare.com/articles/Limits_of_oceans_and_seas_in_digitized_machine_readable_form/10860656) and store it in a safe place using [DataDeps.jl](https://github.com/oxinabox/DataDeps.jl).

You can then test if a given `lat,lon` coordinate is, e.g., in the Pacific, via

```julia
ispacific(lat, lon, OCEANS)
```

---

The image at the top was produced by using `ispacific`-like functions (and [GMT.jl](https://github.com/GenericMappingTools/GMT.jl) for the plotting):

```julia
using Libdl
push!(Libdl.DL_LOAD_PATH, "/usr/local/Cellar/gmt/6.0.0_5/lib")
using GMT
coast(region=:d, proj=:Robinson, frame=:g, res=:crude, area=10000, land=:lemonchiffon1, water=:lightsteelblue1, figsize=12)
using OceanBasins
const OCEANS = oceanpolygons()
N = 2000
lons = 360rand(N) .- 180
lats = 180rand(N) .- 90
isocns = [ispacific, isatlantic, isindian, isarctic, ismediterranean, isantarctic] # <- these functions
colors = [sum(iocn * isocns[iocn](lat,lon,OCEANS) for iocn in 1:length(isocns)) for (lat,lon) in zip(lats,lons)]
scatter!(lons, lats, title="Which ocean basin?", marker=:c, size=0.1, zcolor=colors, show=1, savefig="demo.png")
```

I made this package for myself so it likely has some bugs.
PRs welcome!

---

### Warning

**This package does *not* determine if a coordinate is on land.**
This is because the polygons from the [*Limits of oceans and seas in digitized, machine readable* dataset](https://figshare.com/articles/Limits_of_oceans_and_seas_in_digitized_machine_readable_form/10860656) overlap with land.
For example, this

<img src="https://user-images.githubusercontent.com/4486578/79623984-40133480-8162-11ea-84b8-3b654a09abaf.png" width="50%"/>

is the Atlantic basin, plotted via

```julia
coast(region=:d, proj=:Robinson, frame=:g, res=:crude, area=10000, land=:lemonchiffon1, water=:lightsteelblue1, figsize=12)
x = [P.lon for P in OCEANS[85].polygon] # Atlantic is 85th
y = [P.lat for P in OCEANS[85].polygon]
plot!(x,y, lw=1, lc=:red, title="Atlantic polygon", show=true, savefig="ATL.png")
```

