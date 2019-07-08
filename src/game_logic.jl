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

mutable struct Vector_
    x::Float32
    y::Float32
end

Base.:+(a::Vector_, b::Vector_) = Vector_(a.x + b.x, a.y + b.y)
Base.:*(a::Vector_, b::Vector_) = Vector_(a.x * b*x, a.y * b.y)
Base.:*(k::Real, a::Vector_) = Vector_(k*a.x, k*a.y)
Base.:*(a::Vector_, k::Real) = *(k, a)

mutable struct Player
    length::Float32
    position::Vector_
    velocity::Float32
    is_left::Bool
    Score::Int32
end

mutable struct Ball
    position::Vector_
    velocity::Vector_
    radius::Float32
end

mutable struct Arena
    dims::Vector_
    margin::Vector_
end

mutable struct Env
    arena::Arena
    player_a::Player
    player_b::Player
    ball::Ball
end

rand_x_y = (x, y) -> abs(x-y) * rand(Float32) + min(x, y)  # Generates a random number between x and y
generate_random_height = (paddle_length, arena::Arena) -> rand_x_y(paddle_length/2f0, arena.dims.y - paddle_length/2f0)
generate_random_ball_position(radius, arena::Arena) = Vector_(rand_x_y(radius, arena.dims.x-radius),
                                                                rand_x_y(radius, arena.dims.y-radius))

# Collisions between ball and the walls
detect_collision(ball::Ball, arena::Arena) = (ball.position.y >= arena.dims.y-ball.radius-ball.velocity.y && ball.velocity.y > 0) ||
                                (ball.position.y <= ball.radius+abs(ball.velocity.y)  && ball.velocity.y < 0)

# Collisions between ball and the paddle
function detect_collision(player::Player, ball::Ball, arena::Arena)
    # The ball must be near one of the edges. Using Ball's velocity as an error term.
    ball.radius-ball.velocity.x/2f0 < ball.position.x < (arena.dims.x-ball.radius-ball.velocity.x/2f0) && (return false)

    lower_bound = max(player.position.y - player.length/2f0 - ball.radius/2f0, 0)
    higher_bound = min(player.position.y + player.length/2f0 + ball.radius/2f0, arena.dims.x)

    # The ball must be at the same level as the paddle and it must be approaching the paddle.
    lower_bound < ball.position.y < higher_bound && player.is_left == (ball.velocity.x<0) && (return true)
end

rebound!(ball::Ball) = ball.velocity.y *= -1                 # Ball hits the walls
rebound!(ball::Ball, player::Player) = ball.velocity.x *= -1 # Ball hits the paddle


reset_ball!(ball::Ball, arena::Arena) = reset_ball!(ball, Vector_(arena.dims.x/2f0, arena.dims.y/2f0), Vector_(1,  -1))
function reset_ball!(ball::Ball, position::Vector_, velocity::Vector_)
    ball.position = position
    ball.velocity = velocity
end
