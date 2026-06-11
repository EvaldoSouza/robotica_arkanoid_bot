function [next_input, next_ball_pos] = run_arkanoid_bot(frame_img, frame_counter, prev_ball_pos)
    % 1. Vision Processing (The Eyes)
    [ball_mask, paddle_mask] = process_game_frame(frame_img);
    
    current_ball_pos = extract_centroid(ball_mask);
    current_paddle_pos = extract_centroid(paddle_mask);

    % 2. State & Trajectory Prediction (The Brain)
    [velocity, intercept_x] = predict_trajectory(current_ball_pos, prev_ball_pos);
    
    % 3. Motor Control (The Hands)
    next_input = calculate_paddle_input( ...
        current_paddle_pos, ...
        intercept_x, ...
        frame_counter ...
    );

    % 4. Telemetry (Optional but highly recommended)
    render_debug_frame( ...
        frame_img, ...
        ball_mask, ...
        paddle_mask, ...
        current_ball_pos, ...
        velocity, ...
        intercept_x ...
    );

    % Return the updated state to the main loop
    next_ball_pos = current_ball_pos; 
end

function [ball_mask, paddle_mask] = process_game_frame(frame_img)
    % Decoupled Thresholds for specific game elements
    
    % Ball: Pure white, needs strict threshold (0.8)
    ball_labeled = build_bright_component_map(frame_img, 0.8);
    ball_mask = extract_white_ball(ball_labeled);
    
    % Paddle: Darker, needs relaxed threshold (0.6)
    paddle_labeled = build_bright_component_map(frame_img, 0.6);
    paddle_mask = extract_paddle(paddle_labeled);
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
