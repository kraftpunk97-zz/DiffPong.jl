module DiffPong

include("data_structures.jl")
export Arena, Ball, Env, Player, Vector_

include("utils.jl")
export render, draw_rectangle!, get_obs,
       get_score, update_paddle_position

include("physics.jl")
export wall_collision!, paddle_collision!, rebound

include("game_logic.jl")
export reset_ball!, human_action, ai_action, step!, reset!

include("gradients.jl")
end # module
