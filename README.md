# DiffPong.jl [WIP]
A differentiable Pong game environment for RL experimentation in Julia.

![](https://media.giphy.com/media/XZsRbWRRhobnk6eOlQ/giphy.gif)

## Installation

`] add https://github.com/kraftpunk97/DiffPong.jl#master`

## Exportables

### Data Structures
* `Vector_(x::Float32, y::Float32)`
* `Player(length::Float32, position::Vector_, velocity::Int, score::Int)`
* `Ball(position::Vector_, velocity::Vector_, radius::Float32)`
* `Arena(dims::Vector_, margin::Vector_)`
* `Env(arena::Arena, player_a::Player, player_b::Player, ball:Ball)`

### Collision physics functions
* `wall_collision!`
* `paddle_collision!`
* `rebound` - Updates the direction of the velocity of ball when collision occurs.

### Utility functions
* `draw_rectangle!` - Accepts an `Array{UInt8, 2}` and draws a rectangle at position `x, y` of width `w` and height `h`.
* `get_obs` - Converts the current game state into a 2D `Array{UInt8, 2}` dot matrix image.
*  `get_score`
* `update_paddle_position!` - Based on given input, changes the position of the paddle.
* `render`

### Game logic functions
* `reset_ball!` - Resets the ball's position at the end of the round.
* `human_action` - Processes human input.
* `ai_action`
* `step!`
* `reset!`

## Demonstration

As of writing this demo, the package only supports the rendering The demostration with the visuals can only beif the script is run within the [Juno IDE at the moment](https://junolab.org). Other visualisation options will be added in the future.

```julia
julia> using DiffPong

julia> env = Env()

julia> reset!(env)

julia> for _i=1:100
		   state, reward, done, _ = step!(env, rand(1:3));
		   render(env)ia see(1) endv) |> display;
		   sleep(0.01)
       end
```
