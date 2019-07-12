using Gtk

function demo()
    arena_width = 80f0
    arena_height = 80f0
    paddle_length = arena_height/5

    margin_height = floor(arena_height/30f0)
    margin_width = floor(arena_width/30f0)

    arena = Arena(Vector_(arena_width, arena_height), Vector_(margin_width, margin_height))

    # The position of the paddle is calculated from its center.
    # Therefore, acceptable values of the y coordinate of the paddles are
    # from paddle_length/2 -------> arena_height - paddle_length/2
    player_a_pos = Vector_(0, arena.dims.y - paddle_length/2f0)
    player_b_pos = Vector_(arena.dims.x, arena.dims.y/2f0)

    # Position of the ball is calculated from its center.
    # Acceptable values of the x and y coordinates for the ball are from
    # ball.radius -----------> arena_width - ball.radius
    # ball.radius -----------> arena_height - ball.radius
    ball_pos = Vector_(arena.dims.y/2f0, arena.margin.y)
    ball_vel = Vector_(2,  2)

    #ball_reset_pos = copy(ball_pos)
    #ball_reset_vel = copy(ball_vel)

    player_a = Player(arena.dims.y / 5f0, deepcopy(player_a_pos), 0, true, 0)
    player_b = Player(arena.dims.y / 5f0, deepcopy(player_b_pos), 0,  false, 0)
    ball = Ball(deepcopy(ball_pos), deepcopy(ball_vel), arena.margin.x)

    # Rendering utilities...
    screen = arena.dims + 2arena.margin
    viewer = CairoRGBSurface(screen.x*6, screen.y*6)
    canvas = @GtkCanvas()
    ctx = CairoContext(viewer)
    canvas.backcc = ctx
    win = GtkWindow(canvas, "Pong", screen.x*6, screen.y*6)
    show(canvas)
    visible(win, true)
    signal_connect(win, "delete-event") do widget, event
        ccall((:gtk_widget_hide_on_delete, Gtk.libgtk), Bool, (Ptr{GObject},), win)
    end

    frameskip = 1

    #=
    println()
    println()
    println(detect_collision(player_a, ball, arena))
    println(detect_collision(player_b, ball, arena))
    println(detect_collision(ball, arena))
    =#

    # Main game loop

    #render(ctx, arena, ball, player_a, player_b)
    #display(viewer)
    println("Starting position ", ball.position)
    for timestep=1:200

        # Calculate the new expected position of the ball.
        new_position = ball.position + ball.velocity

        wall_collision!(new_position, ball, arena)
        paddle_collision!(new_position, player_a, player_b, ball, arena)

        # If the ball is not the sweet spot, that means it is out of bounds.
        # Apply a reset.
        if !(0 < new_position.x < arena.dims.x)
            new_position.x = ball_pos.x
            new_position.y = ball_pos.y
            reset_ball_velocity!(ball, ball_vel)
        end

        # Update the current position
        ball.position.x = new_position.x
        ball.position.y = new_position.y

        if timestep % frameskip == 0
            !visible(win) && visible(win, true)
            @guarded draw(canvas) do widget
                render(getgc(canvas), arena, ball, player_a, player_b)
            end
            reveal(canvas, true)
        end
        sleep(0.02)
    end
end
