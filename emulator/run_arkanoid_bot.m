function run_arkanoid_bot(arkanoid_rom)
    frame_counter = 0;
    prev_ball_pos = [];
    current_input = botao(); % Initialize with no buttons pressed

    while true 
        frame_counter = frame_counter + 1;

        % Capture BOTH the ball state and the input state for the next loop
        [prev_ball_pos, current_input] = process_game_frame( ...
            arkanoid_rom, ...
            frame_counter, ...
            prev_ball_pos, ...
            current_input ...
        );
    end
end
