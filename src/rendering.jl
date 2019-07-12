using Cairo

function render(ctx, arena::Arena, ball::Ball, player_a::Player, player_b::Player)
# Setting the stage...

factor = 6
screen = arena.dims + 2arena.margin

set_source_rgb(ctx, 1, 1, 1)
rectangle(ctx, 0, 0, screen.x*factor, screen.y*factor)
fill(ctx)

# The walls...
set_source_rgb(ctx, 0, 1, 0)
rectangle(ctx, 0, 0, screen.x*factor, arena.margin.y*factor)
rectangle(ctx, 0, (screen.y - arena.margin.y)*factor, screen.x*factor, arena.margin.y*factor)
fill(ctx)

# Players ready...
set_source_rgb(ctx, 0, 0, 0)
translate(ctx, arena.margin.x*factor, arena.margin.y*factor)
rectangle(ctx, player_a.position.x*factor, player_a.position.y*factor,
            -arena.margin.x*factor, player_a.length*factor)
rectangle(ctx, player_b.position.x*factor, player_b.position.y*factor,
            arena.margin.x*factor, player_b.length*factor)
fill(ctx)


#  The ball...
set_source_rgb(ctx, 1, 0, 0)
circle(ctx, ball.position.x*factor, ball.position.y*factor, ball.radius*factor)
fill(ctx)


translate(ctx, -arena.margin.x*factor, -arena.margin.y*factor)
end
