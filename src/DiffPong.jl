module DiffPong

include("data_structures.jl")
export Arena, Ball, Env, Player, Vector_

include("utils.jl")
export set_paddle_position!, set_ball_position!, set_ball_velocity,
        draw_rectangle!, get_obs, get_score, update_paddle_position!

include("physics.jl")
export wall_collision!, paddle_collision!, rebound!

include("game_logic.jl")
export reset_ball!, human_action!, ai_action!, step!

#include("demo.jl")
#export demo
end # module
