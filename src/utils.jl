using Images

render(env::Env) = env |> get_obs |> normedview .|> Gray

function draw_rectangle!(screen_array::Array{UInt8, 2}, x, y, w, h, factor)
    X, Y, W, H = (x, y, w, h) .|> floor .|> Int .|>(num) -> *(num, factor)

    max_h, max_w = size(screen_array)
    
    for i=max(X, 1):min(X+W, max_w)
        for j=max(Y, 1):min(Y+H, max_h)
            screen_array[j, i] = UInt8(255)
        end
    end
end

get_score(env::Env) = println("AI = $(env.player_a.score) | HUMAN = $(env.player_b.score)")

# Converts the present state information into a 2D UInt8 dot matrix.
function get_obs(env::Env)
    factor = 6

    player_a = env.player_a
    player_b = env.player_b
    ball = env.ball
    arena = env.arena

    screen = arena.dims + 2arena.margin

    screen_array = zeros(UInt8, Int(screen.y * factor), Int(screen.x*factor))

    # the walls
    draw_rectangle!(screen_array, 0, 0, screen.x, arena.margin.y, factor)
    draw_rectangle!(screen_array, 0, (screen.y - arena.margin.y), screen.x, arena.margin.y, factor)

    # the paddles
    draw_rectangle!(screen_array, player_a.position.x,
                                  player_a.position.y + arena.margin.y,
                                  arena.margin.x, player_a.length, factor)

    draw_rectangle!(screen_array, player_b.position.x + arena.margin.x,
                                  player_b.position.y + arena.margin.y,
                                  arena.margin.x, player_b.length, factor)

    # the ball
    draw_rectangle!(screen_array, ball.position.x + arena.margin.x - ball.radius,
                                  ball.position.y + arena.margin.y - ball.radius,
                                  2ball.radius, 2ball.radius, factor)
    return screen_array
end

function update_paddle_position(player::Player, arena::Arena, dir)
    dummy = player.position.y + dir * player.velocity
    dummy = clamp(dummy, 0, arena.dims.y - player.length)
    Vector_(player.position.x, dummy)
end
