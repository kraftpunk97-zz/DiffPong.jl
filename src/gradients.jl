# This files contains all the gradient definitions for the game.

using Zygote
using Zygote: @adjoint, @nograd, literal_getproperty, @showgrad, hook
import Zygote: accum
import Base: sign, floor

@nograd get_obs, reset_ball!#wall_collision!, #, paddle_collision!

@adjoint Vector_(x, y) = Vector_(x, y), ∆ -> (∆.x, ∆.y)

@adjoint literal_getproperty(v::Vector_, ::Val{:x}) =
    getproperty(v, :x), ∆ -> (Vector_(∆, 0f0), )

@adjoint literal_getproperty(v::Vector_, ::Val{:y}) =
    getproperty(v, :y), ∆ -> (Vector_(0f0, ∆), )


@adjoint Player(length, position, velocity, score) =
    Player(length, position, velocity, score), ∆ -> (∆.length, ∆.position, ∆.velocity, ∆.score)

@adjoint literal_getproperty(p::Player, ::Val{:length}) =
    getproperty(p, :length), ∆ -> (Player(∆, zero(p.position), 0, 0), )

@adjoint literal_getproperty(p::Player, ::Val{:position}) =
    getproperty(p, :position), ∆ -> (Player(0f0, ∆, 0, 0), )

@adjoint literal_getproperty(p::Player, ::Val{:velocity}) =
    getproperty(p, :velocity), ∆ -> (Player(0f0, zero(p.position), ∆, 0), )

@adjoint literal_getproperty(p::Player, ::Val{:score}) =
    getproperty(p, :score), ∆ -> (Player(0f0, zero(p.position), 0, ∆), )


@adjoint Ball(position, velocity, radius) =
    Ball(position, velocity, radius), ∆ -> (∆.position, ∆.velocity, ∆.radius)

@adjoint literal_getproperty(b::Ball, ::Val{:position}) =
    getproperty(b, :position), ∆ -> (Ball(∆, zero(b.velocity), 0f0), )

@adjoint literal_getproperty(b::Ball, ::Val{:velocity}) =
    getproperty(b, :velocity), ∆ -> (Ball(zero(b.position), ∆, 0f0), )

@adjoint literal_getproperty(b::Ball, ::Val{:radius}) =
    getproperty(b, :radius), ∆ -> (Ball(zero(b.position), zero(b.velocity), ∆), )



@adjoint Arena(dims, margin) = Arena(dims, margin), ∆ -> (∆.dims, ∆.margin)

@adjoint literal_getproperty(a::Arena, ::Val{:dims}) =
    getproperty(a, :dims), ∆ -> (Arena(∆, zero(a.margin)), )

@adjoint literal_getproperty(a::Arena, ::Val{:margin}) =
    getproperty(a, :margin), ∆ -> (Arena(zero(a.dims), ∆), )


@adjoint Env(arena, player_a, player_b, ball) =
    Env(arena, player_a, player_b, ball), ∆ -> (∆.arena, ∆.player_a, ∆.player_b, ∆.ball)

@adjoint literal_getproperty(e::Env, ::Val{:arena}) =
    getproperty(e, :arena), ∆ -> (Env(∆, zero(e.player_a), zero(e.player_b), zero(e.ball), zero(e.total_reward), zero(e.done)), )

@adjoint literal_getproperty(e::Env, ::Val{:player_a}) =
    getproperty(e, :player_a), ∆ -> (Env(zero(e.arena), ∆, zero(e.player_b), zero(e.ball), zero(e.total_reward), zero(e.done)), )

@adjoint literal_getproperty(e::Env, ::Val{:player_b}) =
    getproperty(e, :player_b), ∆ -> (Env(zero(e.arena), zero(e.player_a), ∆, zero(e.ball), zero(e.total_reward), zero(e.done)), )

@adjoint literal_getproperty(e::Env, ::Val{:ball}) =
    getproperty(e, :ball), ∆ -> (Env(zero(e.arena), zero(e.player_a), zero(e.player_b), ∆, zero(e.total_reward), zero(e.done)), )

@adjoint literal_getproperty(e::Env, ::Val{:total_reward}) =
    getproperty(e, :total_reward), ∆ -> (Env(zero(e.arena), zero(e.player_a), zero(e.player_b), ∆, zero(e.done)), )

@adjoint literal_getproperty(e::Env, ::Val{:done}) =
    getproperty(e, :done), ∆ -> (Env(zero(e.arena), zero(e.player_a), zero(e.player_b), zero(e.total_reward), ∆), )

x::Player + y::Player = Player(x.length, x.position + y.position, x.velocity + y.velocity, 0)
x::Ball + y::Ball = Ball(x.position + y.position, x.velocity + y.velocity, x.radius)
x::Arena + y::Arena = Arena(x.dims + y.dims, x.margin + y.margin)
x::Env + y::Env = Env(x.arena + y.arena, x.player_a + y.player_a, x.player_b + y.player_b, x.ball + y.ball, x.total_reward + y.total_reward, false)

#=
function Zygote.accum(x::Player, y::Player)
    ans = Player(x.length, x.position + y.position, x.velocity, 0)
    println("$x   +    $y    =  $ans\n\n\n\n")
    return ans
end
function Zygote.accum(x::Ball, y::Ball)
    ans = Ball(x.position + y.position, x.velocity + y.velocity, x.radius)
    println("$x   +    $y    =  $ans\n\n\n\n")
    return ans
end

function Zygote.accum(x::Env, y::Env)
    ball = Ball(x.ball.position + y.ball.position, x.ball.velocity + y.ball.velocity,
                x.ball.radius)
    player_a = Player(x.player_a.length, x.player_a.position + y.player_a.position, x.player_a.velocity, 0)
    player_b = Player(x.player_b.length, x.player_b.position + y.player_b.position, x.player_b.velocity, 0)

    arena = Arena(x.arena.dims + y.arena.dims, x.arena.margin + y.arena.margin)

    ans = Env(arena, player_a, player_b, ball)
    println("$x   +    $y    =  $ans\n\n\n\n")
    return ans
end
Zygote.accum(x::Arena, y::Arena) = println("x = $x | y = $y\n\n\n\n")
=#





#=
@adjoint update_paddle_position(player::Player, arena::Arena, dir) =
    update_paddle_position(player, arena, dir), ∆ -> begin
        dummy = player.position.y + dir * player.velocity  # dummy holds the new position of the paddle
        # If the new position is within the acceptable range of motion, then velocity should be the gradient, wrt dir
        # Otherwise the gradient must be zero.
        0 ≤ dummy ≤ arena.dims.y - player.length ?
            (zero(player), zero(arena), ∆*Vector_(0f0, player.velocity)) :
            (zero(player), zero(arena), ∆*zero(dir))
        end

@adjoint function reset_ball!(arena::Arena, ball::Ball)
    reset_ball!(arena, ball), ∆ -> begin
        return (zero(arena), zero(ball))
    end
end

@adjoint function paddle_collision!(new_position::Vector_, player_a_pos::Vector_, player_b_pos::Vector_,
                                    paddle_length::AbstractFloat, ball::Ball, arena::Arena)
   paddle_collision(new_position, player_a_pos, player_b_pos, paddle_length, ball, arena), ∆ -> begin
    if new_position.x > arena.dims.x - ball.radius
        lower_bound_b  = max(player_b_pos.y - 3ball.radius/4f0, 0)
        higher_bound_b = min(player_b_pos.y + paddle_length + 3ball.radius/4f0, arena.dims.y)

        if lower_bound_b < new_position.y < higher_bound_b

        end
    else
        return (zero(new_position), zero(player_a_pos), zero(player_b_pos), zero(paddle_length),
                zero(ball), zero(arena))
    end
end
end

@nograd wall_collision!, get_obs#, paddle_collision!

Zygote.accum(x::Arena, y::Arena) = println("x = $x | y = $y")
Zygote.accum(x::Player, y::Player) = println("x = $x | y = $y")
=#
