
![demo](https://user-images.githubusercontent.com/4486578/79578964-4b3a7600-810a-11ea-8960-f758cf41f765.png)

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


It mainly contains some functions like, e.g., `ispacific`, to algorithmically determine if a (lat,lon) coordinate lies in an ocean basin or a sea of interest.
I plan to use it to mask regions of interest for global marine biogeochemical modelling (with [AIBECS.jl](https://github.com/briochemc/AIBECS.jl)).

The image at the top was produced by using `ispacific`-like functions (and using GMT.jl):

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
