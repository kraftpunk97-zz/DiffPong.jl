using Zygote
using Zygote: @adjoint, @nograd, literal_getproperty, @showgrad, hook
import Base.sign

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
    getproperty(e, :arena), ∆ -> (Env(∆, zero(e.player_a), zero(e.player_b), zero(e.ball)), )

@adjoint literal_getproperty(e::Env, ::Val{:player_a}) =
    getproperty(e, :player_a), ∆ -> (Env(zero(e.arena), ∆, zero(e.player_b), zero(e.ball)), )

@adjoint literal_getproperty(e::Env, ::Val{:player_b}) =
    getproperty(e, :player_b), ∆ -> (Env(zero(e.arena), zero(e.player_a), ∆, zero(e.ball)), )

@adjoint literal_getproperty(e::Env, ::Val{:ball}) =
    getproperty(e, :ball), ∆ -> (Env(zero(e.arena), zero(e.player_a), zero(e.player_b), ∆), )

@adjoint sign(x) = Base.sign(x), ∆ -> (∆, )

@adjoint update_paddle_position(player::Player, arena::Arena, dir) =
    update_paddle_position(player, arena, dir), ∆ -> begin
        dummy = player.position.y + dir * player.velocity
        0 ≤ dummy ≤ arena.dims.y - player.length ?
            (zero(player), zero(arena), ∆*Vector_(0f0, player.velocity)) :
            (zero(player), zero(arena), ∆*zero(dir))
        end
#=
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
=#
@nograd wall_collision!, paddle_collision!
