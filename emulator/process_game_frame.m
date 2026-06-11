function [next_ball_pos, next_input] = process_game_frame( ...
    arkanoid_rom, frame_counter, prev_ball_pos, current_input)

    % 1. Apply last frame's decision
    advance_emulator(arkanoid_rom, current_input);
    
    frame_img = arkanoid_rom.get_image();

    % 2. Vision Pipeline
    labeled_matrix = build_bright_component_map(frame_img, 0.8);
    ball_mask = extract_white_ball(labeled_matrix);
    paddle_mask = extract_paddle(labeled_matrix);
    
    % 3. Extract Centroids
    current_ball_pos = extract_centroid(ball_mask);
    current_paddle_pos = extract_centroid(paddle_mask); % NEW

    % 4. Predict Trajectory
    [velocity, intercept_x] = predict_trajectory(current_ball_pos, prev_ball_pos);
    
    % 5. Controller Decision (What to do NEXT frame)
    next_input = calculate_paddle_input(current_paddle_pos, intercept_x, frame_counter);
    % 6. Render Telemetry (Optional, but great for watching it work)
    render_debug_frame(frame_img, ball_mask, paddle_mask, current_ball_pos, velocity, intercept_x);

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
