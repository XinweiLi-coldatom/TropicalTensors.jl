using TropicalYao
using NiLogLikeNumbers
using NiLang, NiLang.AD
using Yao
using Compose

export opt_config, isolve, isolve_largemem

include("square.jl")
include("chimera.jl")
include("second_neighbor.jl")

function opt_config(sg::Spinglass{LT,T}) where {LT,T}
    nbit = regsize(sg.lattice)
    reg = _init_reg(T, sg.lattice, Val(false))
    A = stack4reg(reg, cachesize_A(sg.lattice))
    B = stack4reg(reg, cachesize_B(sg.lattice))
    eng, sg, reg, A, B = isolve(T(0.0), sg, reg, A, B)
    sgg = Spinglass(sg.lattice, GVar.(sg.Js, zero(sg.Js)), GVar.(sg.hs, zero(sg.hs)))
    gres = (~isolve)(GVar(eng, T(1)), sgg, GVar(reg), GVar(A), GVar(B))
    empty!(NiLang.GLOBAL_STACK)
    return SpinglassOptConfig(sg, eng, grad.(gres[2].Js), grad.(gres[2].hs))
end
