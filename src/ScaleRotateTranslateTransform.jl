using LinearAlgebra
using Rotations

struct Scale{T}
    p::T
end
(s::Scale)(x::T) where {T} = T(s.p[1] * x[1], s.p[2] * x[2], s.p[3] * x[3])
LinearAlgebra.inv(s::Scale{T}) where {T} = Scale(T(1 / s.p[1], 1 / s.p[2], 1 / s.p[3]))

struct SRT{S, R, T}
    scale::S
    rotation::R
    translation::T
end
function SRT(; scale = nothing, rotation = one(RotMatrix{3, Float32}),
             translation = Vec3f(0))
    SRT(isnothing(scale) ? nothing : Scale(scale), LinearMap(rotation),
        Translation(translation))
end
(srt::SRT{Nothing})(x) = (srt.translation ∘ srt.rotation)(x)
(srt::SRT)(x) = (srt.translation ∘ srt.rotation ∘ srt.scale)(x)

struct TRS{S, R, T}
    scale::S
    rotation::R
    translation::T
end
function TRS(; scale = nothing, rotation = one(RotMatrix{3, Float32}),
             translation = Vec3f(0))
    TRS(isnothing(scale) ? nothing : Scale(scale), LinearMap(rotation),
        Translation(translation))
end

(trs::TRS{Nothing})(x) = (trs.rotation ∘ trs.translation)(x)
(trs::TRS)(x) = (trs.scale ∘ trs.rotation ∘ trs.translation)(x)

_inv(x) = inv(x)
_inv(::Nothing) = nothin
LinearAlgebra.inv(x::SRT) = TRS(_inv(x.scale), inv(x.rotation), inv(x.translation))
LinearAlgebra.inv(x::TRS) = SRT(_inv(x.scale), inv(x.rotation), inv(x.translation))

@testitem "first test" begin @test foo(1) == 1 end

#module Parent
#module Child
#
#using TestItems
#foo(x) = x
#@testitem "my test" begin
#    # is there a way to tell TestItems to use foo from where the 
#    # test is defined, to avoid having to ```using Parent.Child: foo```
#    using Parent.Child: foo
#    @test foo(1) == 1
#end
#
#end # module Child
#end # module Parent