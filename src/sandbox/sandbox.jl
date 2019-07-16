#=
import Base: +, *, -, /, %, intersect, minimum, maximum, size, getindex

struct Vec3{T<:AbstractArray}
    x::T
    y::T
    z::T
    function Vec3(x::T, y::T, z::T) where {T<:AbstractArray}
        @assert size(x) == size(y) == size(z)
        new{T}(x, y, z)
    end
    function Vec3(x::T1, y::T2, z::T3) where {T1<:AbstractArray, T2<:AbstractArray, T3<:AbstractArray}
        # Yes, I know it is a terrible hack but Zygote.FillArray was pissing me off.
        T = eltype(x) <: Real ? eltype(x) : eltype(y) <: Real ? eltype(y) : eltype(z)
        @warn "Converting the type to $(T) by default" maxlog=1
        @assert size(x) == size(y) == size(z)
        new{AbstractArray{T, ndims(x)}}(T.(x), T.(y), T.(z))
    end
end

Vec3(a::T) where {T<:Real} = Vec3([a], [a], [a])

Vec3(a::T) where {T<:AbstractArray} = Vec3(copy(a), copy(a), copy(a))

Vec3(a::T, b::T, c::T) where {T<:Real} = Vec3([a], [b], [c])

for op in (:+, :*, :-)
    @eval begin
        @inline function $(op)(a::Vec3, b::Vec3)
            return Vec3(broadcast($(op), a.x, b.x),
                        broadcast($(op), a.y, b.y),
                        broadcast($(op), a.z, b.z))
        end
    end
end

for op in (:+, :*, :-, :/, :%)
    @eval begin
        @inline function $(op)(a::Vec3, b)
            return Vec3(broadcast($(op), a.x, b),
                        broadcast($(op), a.y, b),
                        broadcast($(op), a.z, b))
        end

        @inline function $(op)(b, a::Vec3)
            return Vec3(broadcast($(op), a.x, b),
                        broadcast($(op), a.y, b),
                        broadcast($(op), a.z, b))
        end
    end
end

@inline -(a::Vec3) = Vec3(-a.x, -a.y, -a.z)
=#

include("../data_structures.jl")
include("../utils.jl")
include("../physics.jl")
include("../game_logic.jl")
include("../gradients.jl")

env = Env()
arena = env.arena
ball = env.ball
pa = env.player_a
pb = env.player_b

p_act = 2

#println(gradient((action) -> step!(env, action), player_action))

    #@assert player_action ∈ action_space

    # 1 = Noop
    # 2 = Up
    # 3 = Down
#=
dir = player_action - 2
arena = env.arena
player_a = env.player_a
player_b = env.player_b
ball = env.ball
dummy = player_b.position.y + dir * player_b.velocity
dummy = clamp(dummy, 0, arena.dims.y - player_b.length)
new_player_b_pos = Vector_(player_b.position.x, dummy)



dir = sign(ball.position.y - player_a.length/2f0 - player_a.position.y)

if sign(ball.position.x - player_a.position.x) == sign(ball.velocity.x) ||
    (player_a.position.y ≤ ball.position.y ≤ player_a.position.y + player_a.length)
    dir = 0
end
dummy = player_a.position.y + dir * player_a.velocity
dummy = clamp(dummy, 0, arena.dims.y - player_a.length)
new_player_a.position = Vector_(player_a.position.x, dummy)


new_position = env.ball.position + ball.velocity

if new_position.y > (arena.dims.y - ball.radius)
    new_position.y = arena.dims.y - ball.radius
    ball.velocity.y *= -1
    #println("Wall collision")
elseif new_position.y < ball.radius
    new_position.y = ball.radius
    ball.velocity.y *= -1
    #println("Wall collision")
end


if new_position.x > arena.dims.x - ball.radius
    lower_bound_b  = max(new_player_b.position.y - 3ball.radius/4f0, 0)
    higher_bound_b = min(new_player_b.position.y + player_b.length + 3ball.radius/4f0, arena.dims.y)
    if lower_bound_b < new_position.y < higher_bound_b
        new_position.x = arena.dims.x - ball.radius
        ball.velocity.x *= -1
        #println("Paddle collision")
    end

elseif new_position.x < ball.radius

    lower_bound_a  = max(player_a.position.y - 3ball.radius/4f0, 0)
    higher_bound_a = min(player_a.position.y + player_a.length + 3ball.radius/4f0, arena.dims.y)

    if lower_bound_a < new_position.y < higher_bound_a
        new_position.x = ball.radius
        ball.velocity.x *= -1
        #println("Paddle collision")
    end
end

if new_position.x ≤ 0
    player_b.score += 1
    #println("Score!!!")
    k = -1 * sign(ball.velocity.x)
    ball.velocity.x = 2k
    while true
        ball.velocity.y = -1 * k * rand(-2:2)
        ball.velocity.y != 0 && break
    end
    new_position = arena.dims/2f0
end

if new_position.x ≥ arena.dims.x
    player_a.score += 1
    #println("Booo!!!!!")
    k = -1 * sign(ball.velocity.x)
    ball.velocity.x = 2k
    while true
        ball.velocity.y = -1 * k * rand(-2:2)
        ball.velocity.y != 0 && break
    end
    new_position = arena.dims/2f0
end

ball.position.x = new_position.x
ball.position.y = new_position.y
done = (player_a.score + player_b.score) ≥ 21
reward = -1 * abs(ball.position.y - player_b.position.y - player_b.length/2f0)
=#
