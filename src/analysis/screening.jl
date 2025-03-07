
"""
    function screen(
        model::MetabolicModel;
        variants::Maybe{Array{V,N}} = nothing,
        analysis,
        args::Maybe{Array{T,N}} = nothing,
        workers = [myid()],
    )::Array where {V<:AbstractVector, T<:Tuple,N}

Take an array of model-modifying function vectors in `variants`, and execute
the function `analysis` on all variants of the `model` specified by `variants`.
The computation is distributed over worker IDs in `workers`. If `args` are
supplied (as an array of the same size as the `variants`), they are forwarded
as arguments to the corresponding analysis function calls.

The array of variants must contain vectors of single-parameter functions, these
are applied to model in order. The functions must *not* modify the model, but
rather return a modified copy. The copy should be made as shallow as possible,
to increase memory efficiency of the process. Variant generators that modify
the argument model in-place will cause unpredictable results. Refer to the
definition of [`screen_variant`](@ref) for details.

The function `analysis` will receive a single argument (the modified model),
together with an expanded tuple of arguments from `args`.

The modification and analysis functions are transferred to `workers` as-is; all
packages required to run them (e.g. the optimization solvers) must be loaded
there. Typically, you want to use the macro `@everywhere using
MyFavoriteSolver` from `Distributed` package for loading the solvers.

# Return value

The results of running `analysis` are collected in to the resulting array, in a
way that preserves the shape of the `variants`, similarly as with `pmap`.

The results of `analysis` function must be serializable, preferably made only
from pure Julia structures, because they may be transferred over the network
between the computation nodes. For that reason, functions that return whole
JuMP models that contain pointers to allocated C structures (such as
[`flux_balance_analysis`](@ref) used with `GLPK` or `Gurobi` otimizers) will
generally not in this context.

# Example
```
function reverse_reaction(i::Int)
    (model::CoreModel) -> begin
        mod = copy(model)
        mod.S[:,i] .*= -1   # this is unrealistic but sufficient for demonstration
        mod
    end
end

m = load_model(CoreModel, "e_coli_core.xml")

screen_variants(m,
           [
               [reverse_reaction(5)],
               [reverse_reaction(3), reverse_reaction(6)]
           ],
           mod -> mod.S[:,3])  # observe the changes in S

screen_variants(m,
    [
        [reverse_reaction(5)],
        [reverse_reaction(3), reverse_reaction(6)]
    ],
    mod -> flux_balance_analysis_vec(mod, GLPK.Optimizer))  # run analysis
"""
function screen(
    model::MetabolicModel;
    variants::Maybe{Array{V,N}} = nothing,
    analysis,
    args::Maybe{Array{T,N}} = nothing,
    workers = [myid()],
)::Array where {V<:AbstractVector,T<:Tuple,N}

    map(fetch, save_at.(workers, :cobrexa_screen_variants_model, Ref(model)))
    map(fetch, save_at.(workers, :cobrexa_screen_variants_analysis_fn, Ref(analysis)))
    map(fetch, get_from.(workers, Ref(:(precache!(cobrexa_screen_variants_model)))))

    if isnothing(variants)
        if isnothing(args)
            throw(
                DomainError(
                    args,
                    "at least one of `variants` and `args` must be non-empty",
                ),
            )
        end
        variants = [[] for _ in args]
    elseif isnothing(args)
        args = [() for _ in variants]
    else
        if size(variants) != size(args)
            throw(
                DomainError(
                    "$(size(variants)) != $(size(args))",
                    "sizes of `variants` and `args` differ",
                ),
            )
        end
    end

    res = dpmap(
        (vars, args)::Tuple -> :($COBREXA.screen_variant(
            cobrexa_screen_variants_model,
            $vars,
            cobrexa_screen_variants_analysis_fn,
            $args,
        )),
        CachingPool(workers),
        zip(variants, args),
    )

    map(fetch, remove_from.(workers, :cobrexa_screen_variants_model))
    map(fetch, remove_from.(workers, :cobrexa_screen_variants_analysis_fn))

    return res
end

"""
    screen_variant(model::MetabolicModel, variant::Vector, analysis, args = ())

Helper function for [`screen`](@ref) that applies all single-argument
functions in `variant` to the `model` (in order from "first" to
"last"), and executes `analysis` on the result.

Can be used to test model variants locally.
"""
function screen_variant(model::MetabolicModel, variant::Vector, analysis, args = ())
    for fn in variant
        model = fn(model)
    end
    analysis(model, args...)
end

"""
    screen_variants(model, variants, analysis; workers=[myid()])

A shortcut for [`screen`](@ref) that only works with model variants.
"""
screen_variants(model, variants, analysis; workers = [myid()]) =
    screen(model; variants = variants, analysis = analysis, workers = workers)
