# This file contains all the relevant data structures that are used to set up the game.

mutable struct Vector_
    x::Float32
    y::Float32
end

Base.:+(a::Vector_, b::Vector_) = Vector_(a.x + b.x, a.y + b.y)
Base.:*(k::Real, a::Vector_) = Vector_(k*a.x, k*a.y)
Base.:*(a::Vector_, k::Real) = *(k, a)
Base.:/(a::Vector_, k::Real) = Vector_(a.x/k, a.y/k)

mutable struct Player
    length::Float32
    position::Vector_
    velocity::Int
    score::Int
end

mutable struct Ball
    position::Vector_
    velocity::Vector_
    radius::Float32
end

struct Arena
    dims::Vector_
    margin::Vector_
end

struct Env
    arena::Arena
    player_a::Player
    player_b::Player
    ball::Ball
end
