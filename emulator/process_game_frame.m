function next_ball_pos = process_game_frame( ...
    arkanoid_rom, ...
    frame_counter, ...
    prev_ball_pos) % NEW INPUT

    advance_emulator(arkanoid_rom, frame_counter);
    frame_img = arkanoid_rom.get_image();

    % Vision Pipeline
    labeled_matrix = build_bright_component_map(frame_img, 0.8);
    ball_mask = extract_white_ball(labeled_matrix);
    paddle_mask = extract_paddle(labeled_matrix);
    
    % --- NEW: Extract Centroid and Predict ---
    current_ball_pos = extract_centroid(ball_mask);
    
    [velocity, intercept_x] = predict_trajectory(current_ball_pos, prev_ball_pos);
    
    render_debug_frame( ...
        frame_img, ...
        ball_mask, ...
        paddle_mask, ...
        current_ball_pos, ...
        velocity, ...
        intercept_x ...
    );

    % Return current position to become the next frame's prev_pos
    next_ball_pos = current_ball_pos; 
end

function centroid = extract_centroid(binary_mask)
    % Helper function to get the [X, Y] of the ball mask
    centroid = [];
    
    % Force the mask to be logical (0 or 1) so regionprops doesn't
    % confuse the 255 pixel values for region labels.
    logical_mask = binary_mask > 0;
    
    stats = regionprops(logical_mask, "Centroid");
    
    if ~isempty(stats)
        centroid = stats(1).Centroid;
    end
end
