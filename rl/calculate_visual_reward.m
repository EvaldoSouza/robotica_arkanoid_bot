function reward = calculate_visual_reward(ball_pos, current_velocity, prev_velocity, config)
    % Calculates Q-learning rewards based purely on visual physics
    reward = 0; % Default neutral reward

    if isempty(ball_pos) || isempty(current_velocity) || isempty(prev_velocity)
        return;
    end

    % --- PUNISHMENT: Death ---
    % If the ball falls 10 pixels below the paddle's baseline, it missed.
    if ball_pos(2) > (config.physics.paddle_y + 10)
        reward = -50;
        return;
    end

    % --- REWARD: Successful Hit ---
    % A hit occurs if the ball was falling (prev Y-vel > 0), 
    % is now rising (curr Y-vel < 0), AND is near the paddle.
    was_falling = prev_velocity(2) > 0;
    is_rising = current_velocity(2) < 0;
    is_near_bottom = ball_pos(2) > (config.physics.paddle_y - 25);

    if was_falling && is_rising && is_near_bottom
        reward = 10;
        return;
    end
    
    % (Optional Future Addition: Small reward for breaking blocks here)
end
