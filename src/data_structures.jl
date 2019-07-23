# This file contains all the relevant data structures that are used to set up the game.

import Base: +, -, *, /, %, ÷

mutable struct Vector_
    x::Float32
    y::Float32
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

Base.zero(p::Player) = Player(0f0, zero(p.position), 0, 0)


mutable struct Ball
    position::Vector_
    velocity::Vector_
    radius::Float32
end

Base.zero(b::Ball) = Ball(zero(b.position), zero(b.position), 0f0)


struct Arena
    dims::Vector_
    margin::Vector_
end

Base.zero(a::Arena) = Arena(zero(a.dims), zero(a.margin))

mutable struct Env
    arena::Arena
    player_a::Player
    player_b::Player
    ball::Ball
    total_reward::Float32
    done::Bool
end

Base.zero(e::Env) = Env(zero(e.arena), zero(e.player_a), zero(e.player_b), zero(e.ball), zero(e.total_reward), true)
