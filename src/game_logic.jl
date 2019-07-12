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
include("data_structures.jl")
include("utils.jl")
include("physics.jl")

function reset_ball!(arena::Arena, ball::Ball)
    k = -1 * sign(ball.velocity.x)
    ball.velocity.x = 2k
    while true
        ball.velocity.y = -1 * k * rand(-2:2)
        ball.velocity.y != 0 && break
    end
    return arena.dims/2f0
end

human_action!(player_b::Player, arena::Arena, dir) = update_paddle_position!(player_b, arena, dir)

function ai_action!(player_a::Player, arena::Arena, ball::Ball)
    dir = sign(ball.position.y - player_a.length/2f0 - player_a.position.y)

    if sign(ball.position.x - player_a.position.x) == sign(ball.velocity.x) ||
        (player_a.position.y ≤ ball.position.y ≤ player_a.position.y + player_a.length)
        dir = 0
    end

    update_paddle_position!(player_a, arena, dir)
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

    # The position of the paddle is calculated from its center.
    # Therefore, acceptable values of the y coordinate of the paddles are
    # from 0 -------> arena_height - paddle_length
    player_a_pos = Vector_(0, (arena.dims.y-paddle_length)/2)
    player_a = Player(paddle_length, deepcopy(player_a_pos), 2, 0)

    player_b_pos = Vector_(arena.dims.x, (arena.dims.y-paddle_length)/2)
    player_b = Player(paddle_length, deepcopy(player_b_pos), 2, 0)

    # Position of the ball is calculated from its center.
    # Acceptable values of the x and y coordinates for the ball are from
    # ball.radius -----------> arena_width - ball.radius
    # ball.radius -----------> arena_height - ball.radius
    ball_pos = Vector_(arena.dims.x/2f0, ball_radius)
    ball_vel = Vector_(3,  -3)
    ball = Ball(deepcopy(ball_pos), deepcopy(ball_vel), ball_radius)


    return Env(arena, player_a, player_b, ball)
end

function step!(env::Env, player_action)
    #@assert player_action ∈ action_space

    # 1 = Noop
    # 2 = Up
    # 3 = Down
    dir = player_action == 1 ? 0 : (player_action == 2 ? -1 : 1)

    arena = env.arena
    player_a = env.player_a
    player_b = env.player_b
    ball = env.ball

    reward = 0

    total_score = player_a.score + player_b.score

    human_action!(player_b, arena, dir)
    ai_action!(player_a, arena, ball)
    new_position = env.ball.position + ball.velocity

    wall_collision!(new_position, ball, arena)
    paddle_collision!(new_position, player_a, player_b, ball, arena)

    if new_position.x ≤ 0
        player_b.score += 1
        reward = 1
        println("Score!!!")
        new_position = reset_ball!(arena, ball)
    end

    if new_position.x ≥ arena.dims.x
        player_a.score += 1
        reward = -1
        println("Booo!!!!!")
        new_position = reset_ball!(arena, ball)
    end

    ball.position.x = new_position.x
    ball.position.y = new_position.y

    done = (player_a.score + player_b.score) ≥ 21

    return get_obs(env), reward, done, Dict()
end
