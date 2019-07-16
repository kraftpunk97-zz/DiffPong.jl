# This file contains all the relevant data structures that are used to set up the game.

import Base: +, -, *, /, %, ÷

mutable struct Vector_
    x::Union{Float32}
    y::Union{Float32}
end

for op ∈ (:+, :-, :*)
    @eval @inline $(op)(a::Vector_, b::Vector_) = Vector_($(op)(a.x, b.x),
                                                          $(op)(a.y, b.y))
end

for op ∈ (:+, :-, :*, :/, :%, :÷)
    @eval @inline $(op)(a::Vector_, k::Real) = Vector_($(op)(a.x, k),
                                                       $(op)(a.y, k))
    @eval @inline $(op)(k::Real, a::Vector_) = $(op)(a, k)
end

@inline -(a::Vector_) = Vector_(-a.x, -a.y)

Base.zero(v::Vector_) = Vector_(0f0, 0f0)


mutable struct Player
    length::Float32
    position::Vector_
    velocity::Int
    score::Int
end


#p1::Player + p2::Player = Player(p1.length, p1.position + p2.position, p1.velocity + p2.velocity, p1.score + p2.score)
foo::Base.RefValue{Any} + p::Player = 0
p1::Player + p2::Player = Player(0, p1.position + p2.position, 0, 0)
Base.zero(p::Player) = Player(0f0, zero(p.position), 0, 0)


mutable struct Ball
    position::Vector_
    velocity::Vector_
    radius::Float32
end

Base.zero(b::Ball) = Ball(zero(b.position), zero(b.position), 0f0)
#b1::Ball + b2::Ball = Ball(b1.position + b2.position, b1.velocity + b2.velocity, b1.radius + b2.radius)


struct Arena
    dims::Vector_
    margin::Vector_
end

Base.zero(a::Arena) = Arena(zero(a.dims), zero(a.margin))
#a1::Arena + a2::Arena = Arena(a1.dims + a2.dims, a1.margin + a2.margin)

struct Env
    arena::Arena
    player_a::Player
    player_b::Player
    ball::Ball
end

Base.zero(e::Env) = Env(zero(e.arena), zero(e.player_a), zero(e.player_b), zero(e.ball))
e1::Env + e2::Env = Env(zero(e1.arena), zero(e1.player_a),
                        Player(0f0, e1.player_b.position + e2.player_b.position, 0, 0),
                        zero(e1.ball))
#e1::Env + e2::Env = Env(e1.arena + e2.arena, e1.player_a + e2.player_a, e1.player_b + e1.player_b, e1.ball + e2.ball)
