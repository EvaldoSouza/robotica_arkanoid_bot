function reward = calculate_visual_reward(ball_pos, current_velocity, prev_velocity, prev_action, prev_prev_action, config)
    % Calculates Q-learning rewards based purely on visual physics.
    % Prioritizes hitting the ball and penalizes jittering.
    
    reward = 0; 
    
    if isempty(ball_pos) || isempty(current_velocity) || isempty(prev_velocity)
        return;
    end
    
    if ball_pos(2) > (config.physics.paddle_y + 10)
        reward = -100; % PUNISHMENT: Death
        return;
    end
    
    reward = apply_hit_reward(reward, ball_pos, current_velocity, prev_velocity, config);
    reward = apply_jitter_penalty(reward, prev_action, prev_prev_action);
end

function updated_reward = apply_hit_reward(current_reward, ball_pos, current_velocity, prev_velocity, config)
    % Rewards the agent when the ball bounces off the paddle.
    
    updated_reward = current_reward;
    
    was_falling = prev_velocity(2) > 0;
    is_rising = current_velocity(2) < 0;
    is_near_bottom = ball_pos(2) > (config.physics.paddle_y - 25);
    
    if was_falling && is_rising && is_near_bottom
        updated_reward = 50;
    end
end

function updated_reward = apply_jitter_penalty(current_reward, action1, action2)
    % Penalizes alternating between Left (1) and Right (2) rapidly.
    
    updated_reward = current_reward;
    
    is_jitter = (action1 == 1 && action2 == 2) || (action1 == 2 && action2 == 1);
    
    if is_jitter
        updated_reward = updated_reward - 0.1;
    end
end
