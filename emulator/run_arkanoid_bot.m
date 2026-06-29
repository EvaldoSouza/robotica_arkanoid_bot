function [next_input, next_ball_pos, next_velocity, current_state, action_idx, config] = run_arkanoid_bot( ...
    frame_img, frame_counter, prev_ball_pos, prev_velocity, prev_state, prev_action_idx, config)

    % 1. Vision Processing
    [ball_mask, paddle_mask, block_count, block_mask] = process_game_frame(frame_img, config);
    
    current_ball_pos = extract_centroid(ball_mask);
    current_paddle_pos = extract_centroid(paddle_mask);

    % 2. State & Trajectory Prediction (Still useful for getting the exact velocity!)
    [velocity, intercept_x] = predict_trajectory(current_ball_pos, prev_ball_pos, config);
    
    % 3. RL State & Reward
    current_state = discretize_state(current_paddle_pos, current_ball_pos, velocity);
    reward = calculate_visual_reward(current_ball_pos, velocity, prev_velocity, config);

    % 4. Q-Learning Agent (The new Brain)
    [action_idx, updated_q_table] = q_learning_agent(current_state, reward, prev_state, prev_action_idx, config);
    config.rl.q_table = updated_q_table;
    
    % 5. Motor Control (Translate agent action to buttons)
    if isempty(current_paddle_pos)
        % Ensure we can still get out of the menu sequence!
        if mod(frame_counter, 60) < 5
            next_input = button("START");
        else
            next_input = button();
        end
        action_idx = 0; % Prevent the bot from learning noise during the menu
    else
        % Map the Q-learning choice to actual emulator inputs
        if action_idx == 1
            next_input = button("LEFT", "A");
        elseif action_idx == 2
            next_input = button("RIGHT", "A");
        else
            next_input = button("A"); % IDLE
        end
    end

    % 6. Telemetry Dashboard
    % Only render UI every 5 frames to save CPU, UNLESS a reward just occurred!
    if mod(frame_counter, 5) == 0 || reward ~= 0
        rl_dashboard( ...
            frame_img, ...
            ball_mask, ...
            paddle_mask, ...
            current_ball_pos, ...
            intercept_x, ...
            config.rl.q_table, ...
            current_state, ...
            reward, ...
            config.rl.epsilon, ...
            frame_counter, ...
            action_idx,
            block_mask...
        );
    end
    % Pass everything forward for the next frame
    next_ball_pos = current_ball_pos; 
    next_velocity = velocity;
end

function [ball_mask, paddle_mask, block_count, block_mask] = process_game_frame(frame_img, config)
    % Ball: Uses strict threshold from config
    ball_labeled = build_bright_component_map(frame_img, config.vision.ball_threshold);
    ball_mask = extract_white_ball(ball_labeled);
    [block_count, block_mask] = detect_blocks(frame_img);
    
    % Paddle: Uses relaxed threshold from config
    paddle_labeled = build_bright_component_map(frame_img, config.vision.paddle_threshold, true);
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
