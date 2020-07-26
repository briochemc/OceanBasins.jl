using Test, OceanBasins

ENV["DATADEPS_ALWAYS_ACCEPT"] = true
const OCEANS = oceanpolygons()

@testset "Testing Oceanbasins" begin
    @test ispacific(0, -160, OCEANS)
    @test isarctic(89, 0, OCEANS)
    @test isatlantic(0, -30, OCEANS)
    @test isindian(0, 90, OCEANS)
    @test ispacific2(0, -160, OCEANS)
    @test isatlantic2(0, -30, OCEANS)
    @test isindian2(0, 90, OCEANS)
    @test isSOpacific(-80, -160, OCEANS)
    @test isSOatlantic(-80, -30, OCEANS)
    @test isSOindian(-80, 90, OCEANS)
    @test isantarctic(-40, 0, OCEANS)
    @test ismediterranean(31, 15, OCEANS)
    @test isindonesian(0, 120, OCEANS)
end
