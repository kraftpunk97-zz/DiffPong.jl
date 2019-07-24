#=

             Positive X
      -------------------------------------->
      |
p     |
o     |
s     |
i     |
t     |
i     |
v     |
e     |
      |
y     |
      V

=#
function reset_ball!(arena::Arena, ball::Ball)
    k = -1 * sign(ball.velocity.x)
    ball_vx = 2k
    ball_vy = 0
    while true
        ball_vy = -1 * k * rand(-2:2)
        ball_vy != 0 && break
    end
    ball.velocity = Vector_(ball_vx, ball_vy)
    return arena.dims/2f0
end

human_action(player_b::Player, arena::Arena, dir) = update_paddle_position(player_b, arena, dir)

function ai_action(player_a::Player, arena::Arena, ball::Ball)
    dir = sign(ball.position.y - player_a.length/2f0 - player_a.position.y)

    if sign(ball.position.x - player_a.position.x) == sign(ball.velocity.x) ||
        (player_a.position.y ≤ ball.position.y ≤ player_a.position.y + player_a.length)
        dir = 0
    end

    update_paddle_position(player_a, arena, dir)
end

"""The default game configuration"""
function Env()
    arena_width = 80f0
    arena_height = 80f0
    paddle_length = arena_height/5

    margin_height = floor(arena_height/30f0)
    margin_width = floor(arena_width/30f0)

    ball_radius = floor((margin_width + margin_height)/3f0)

    arena = Arena(Vector_(arena_width, arena_height), Vector_(margin_width, margin_height))

    # The position of the paddle is calculated from its top edge.
    # Therefore, acceptable values of the y coordinate of the paddles are
    # from 0 -------> arena_height - paddle_length
    player_a_pos = Vector_(0, (arena.dims.y-paddle_length)/2)
    player_a = Player(paddle_length, deepcopy(player_a_pos), 4, 0)

    player_b_pos = Vector_(arena.dims.x, (arena.dims.y-paddle_length)/2)
    player_b = Player(paddle_length, deepcopy(player_b_pos), 2, 0)

    # Position of the ball is calculated from its center.
    # Acceptable values of the x and y coordinates for the ball are from
    # ball.radius -----------> arena_width - ball.radius
    # ball.radius -----------> arena_height - ball.radius
    ball_pos = Vector_(arena.dims.x/2f0, ball_radius)
    ball_vel = Vector_(3,  -3)
    ball = Ball(deepcopy(ball_pos), deepcopy(ball_vel), ball_radius)

    return Env(arena, player_a, player_b, ball, 0f0, true)
end

function step!(env::Env, player_action)
    #=if player_action ∉ (1, 2, 3)
        error("Incorrect action")
    end=#

    # 1 = Noop -1
    # 2 = Up    0
    # 3 = Down  1

    player_action -= 2

    arena = env.arena
    player_a = env.player_a
    player_b = env.player_b
    ball = env.ball


    new_player_b_position = human_action(player_b, arena, player_action)  # Find gradients here (Done)
    new_player_a_position = ai_action(player_a, arena, ball)
    new_ball_position = ball.position + ball.velocity
    new_ball_position = wall_collision!(new_ball_position, ball, arena)


    new_ball_position = paddle_collision!(new_ball_position, new_player_a_position, new_player_b_position,
                                            player_b.length, ball, arena)  # Find gradients here.

    reward = 0

    if new_ball_position.x ≤ 0
        player_b.score += 1
        reward += 80
        new_ball_position = reset_ball!(arena, ball)  # Drop gradients here...
    end

    if new_ball_position.x ≥ arena.dims.x
        player_a.score += 1
        reward -= 80
        new_ball_position = reset_ball!(arena, ball)  # Drop gradients here...
    end

    done = (player_a.score + player_b.score) ≥ 21
    reward += -1 * abs(new_ball_position.y - new_player_b_position.y - player_b.length/2f0)

    # Update positions...
    ball.position = new_ball_position
    player_b.position = new_player_b_position
    player_a.position = new_player_a_position

    env.total_reward += reward
    env.done = done

    return get_obs(env), reward, env.done, Dict()
end

function reset!(env::Env)
    env.ball.position = reset_ball!(env.arena, env.ball)
    env.player_a.score = 0
    env.player_b.score = 0
    env.total_reward = 0f0
    env.done = false
    get_obs(env)
end
