# This file contains all the functions for simulating the physics of the game.

"""Collisions between ball and the walls"""
function wall_collision!(new_position::Vector_, ball::Ball, arena::Arena)
    # If the height of the ball, in this new position is out of range,
    # then we perform a correction and flip the sign of the vertical velocity.
    if new_position.y >= (arena.dims.y - ball.radius)
        ball.velocity = rebound(ball, :wall)
        return Vector_(new_position.x, arena.dims.y - ball.radius)
    elseif new_position.y <= ball.radius
        ball.velocity = rebound(ball, :wall)
        return Vector_(new_position.x, ball.radius)
    end
    return new_position
end

"""Collisions between ball and the paddle"""
function paddle_collision!(new_position::Vector_, player_a_pos::Vector_, player_b_pos::Vector_, paddle_length::AbstractFloat,
                            ball::Ball, arena::Arena)
    # For ball - paddle collision, we find the whether the ball is in the
    # horizontal and vertical "sweet spot" of the paddle. If it is, we apply a rebound.
    # horizontal sweet spot lies in arena_width - ball.radius to arena_width
    # vertical sweet spot is defined by the lower and higher bounds of the paddles.
    if new_position.x >= arena.dims.x - ball.radius
        lower_bound_b  = max(player_b_pos.y - 3ball.radius/4f0, 0)
        higher_bound_b = min(player_b_pos.y + paddle_length + 3ball.radius/4f0, arena.dims.y)

        if lower_bound_b < new_position.y < higher_bound_b
            ball.velocity = rebound(ball, :paddle)
            return Vector_(arena.dims.x - ball.radius, new_position.y)
        end
    end
    if new_position.x <= ball.radius
        lower_bound_a  = max(player_a_pos.y - 3ball.radius/4f0, 0)
        higher_bound_a = min(player_a_pos.y + paddle_length + 3ball.radius/4f0, arena.dims.y)

        if lower_bound_a < new_position.y < higher_bound_a
            ball.velocity = rebound(ball, :paddle)
            return Vector_(ball.radius, new_position.y)
        end
    end
    return new_position
end

function rebound(ball::Ball, sym::Symbol)
    ball_vx = ball.velocity.x
    ball_vy = ball.velocity.y
    sym == :wall   && (ball_vy *= -1)  # Ball hits the walls
    sym == :paddle && (ball_vx *= -1)  # Ball hits the paddle
    Vector_(ball_vx, ball_vy)
end
