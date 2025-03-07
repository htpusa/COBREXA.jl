@testset "Gene: construction, printing, utils" begin
    g = Gene()

    # test defaults
    @test isnothing(g.name)
    @test isempty(g.notes)
    @test isempty(g.annotations)

    # Now assign
    g.id = "gene1"
    g.name = "gene_name"
    g.notes = Dict("notes" => ["blah", "blah"])
    g.annotations = Dict("sboterm" => ["sbo"], "ncbigene" => ["ads", "asds"])

    # Test pretty printing
    @test all(
        contains.(
            sprint(show, MIME("text/plain"), g),
            ["gene1", "gene_name", "blah", "asds"],
        ),
    )

    # Test duplicate annotation finder
    g2 = Gene("gene2")
    g2.annotations = Dict("sboterm" => ["sbo2"], "ncbigene" => ["fff", "ggg"])
    g3 = Gene("g3")
    g3.annotations = Dict("sboterm" => ["sbo3"], "ncbigene" => ["ads"])
    g4 = Gene("g4")
    g4.annotations = Dict("sboterm" => ["sbo4"], "ncbigene" => ["ads22", "asd22s"])
    gdict = OrderedDict(g.id => g for g in [g, g2, g3, g4]) # this is how genes are stored in StandardModel

    idx = annotation_index(gdict)
    @test length(idx["ncbigene"]["ads"]) > 1
    @test "gene1" in idx["ncbigene"]["ads"]

    ambiguous = ambiguously_identified_items(idx)
    @test "g3" in ambiguous
    @test !("g4" in ambiguous)
end
