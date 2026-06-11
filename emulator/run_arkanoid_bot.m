function run_arkanoid_bot(arkanoid_rom)
    frame_counter = 0;
    prev_ball_pos = []; % Initialize state

    % Use a dynamic break instead of a magic number
    while true 
        frame_counter = frame_counter + 1;

        % Capture the returned state to use in the next loop iteration
        prev_ball_pos = process_game_frame( ...
            arkanoid_rom, ...
            frame_counter, ...
            prev_ball_pos ...
        );

    end
end
