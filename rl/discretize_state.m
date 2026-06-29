function state_indices = discretize_state(paddle_pos, ball_pos, velocity, intercept_x)
    % Converts continuous vision coordinates into a discrete 4D state vector
    % [relative_x, ball_y, dir_x, dir_y]
    
    % Default state if objects are missing (e.g., loading screen)
    if nargin < 4
        intercept_x = -1;
    end
    
    if isempty(paddle_pos) || isempty(ball_pos) || isempty(velocity)
        state_indices = [3, 1, 1, 1]; % Assume center, high, moving up-left
        return;
    end

    % --- 1. Predictive Relative X ---
    % If we have a valid intercept prediction, use it! 
    % Otherwise, fallback to the ball's current X position.
    if intercept_x ~= -1
        target_x = intercept_x;
    else
        target_x = ball_pos(1);
    end
    
    diff_x = target_x - paddle_pos(1);
    
    % 5 Bins: Far Left (1), Left (2), Center (3), Right (4), Far Right (5)
    if diff_x < -20
        rel_x = 1;
    elseif diff_x < -5
        rel_x = 2;
    elseif diff_x <= 5
        rel_x = 3;
    elseif diff_x <= 20
        rel_x = 4;
    else
        rel_x = 5;
    end

    % 2. Ball Height (How imminent is the impact?)
    % 3 Bins: High/Safe (1), Medium (2), Low/Imminent (3)
    y = ball_pos(2);
    if y < 100
        ball_y = 1;
    elseif y < 180
        ball_y = 2;
    else
        ball_y = 3;
    end

    % 3. X Velocity Direction
    % 2 Bins: Left (1), Right (2)
    if velocity(1) < 0
        dir_x = 1; 
    else
        dir_x = 2; 
    end

    % 4. Y Velocity Direction
    % 2 Bins: Up (1), Down (2)
    if velocity(2) < 0
        dir_y = 1; 
    else
        dir_y = 2; 
    end

    % Return the discrete state array
    state_indices = [rel_x, ball_y, dir_x, dir_y];
end
