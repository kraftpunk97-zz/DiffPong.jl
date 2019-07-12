# This file contains all the functions for simulating the physics of the game.

"""Collisions between ball and the walls"""
function wall_collision!(new_position::Vector_, ball::Ball, arena::Arena)
    # If the height of the ball, in this new position is out of range,
    # then we perform a correction and flip the sign of the vertical velocity.
    if new_position.y > (arena.dims.y - ball.radius)
        new_position.y = arena.dims.y - ball.radius
        rebound!(ball)
        println("Wall collision")
    elseif new_position.y < ball.radius
        new_position.y = ball.radius
        rebound!(ball)
        println("Wall collision")
    end
end

"""Collisions between ball and the paddle"""
function paddle_collision!(new_position::Vector_, player_a::Player, player_b::Player,
                            ball::Ball, arena::Arena)
    # For ball - paddle collision, we find the whether the ball is in the
    # horizontal and vertical "sweet spot" of the paddle. If it is, we apply a rebound.
    # horizontal sweet spot lies in arena_width - ball.radius to arena_width
    # vertical sweet spot is defined by the lower and higher bounds of the paddles.
    if new_position.x > arena.dims.x - ball.radius
        lower_bound_b  = max(player_b.position.y - 3ball.radius/4f0, 0)
        higher_bound_b = min(player_b.position.y + player_b.length + 3ball.radius/4f0, arena.dims.y)

        if lower_bound_b < new_position.y < higher_bound_b
            new_position.x = arena.dims.x - ball.radius
            rebound!(ball, player_b)
            println("Paddle collision")
        end

    elseif new_position.x < ball.radius

        lower_bound_a  = max(player_a.position.y - 3ball.radius/4f0, 0)
        higher_bound_a = min(player_a.position.y + player_a.length + 3ball.radius/4f0, arena.dims.y)

        if lower_bound_a < new_position.y < higher_bound_a
            new_position.x = ball.radius
            rebound!(ball, player_a)
            println("Paddle collision")
        end
    end
end

rebound!(ball::Ball) = ball.velocity.y *= -1                 # Ball hits the walls
rebound!(ball::Ball, player::Player) = ball.velocity.x *= -1 # Ball hits the paddle
