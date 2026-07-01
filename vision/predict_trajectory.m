function [velocity, intercept_x] = predict_trajectory(current_pos, prev_pos, config)
    velocity = [0, 0];
    intercept_x = -1;

    if isempty(prev_pos) || isempty(current_pos)
        return;
    end

    velocity = current_pos - prev_pos;
    vx = velocity(1);
    vy = velocity(2);

    if vy <= 0
        return;
    end

    % --- Extracting physics boundaries from config ---
    left_wall = config.physics.left_wall;
    right_wall = config.physics.right_wall;
    paddle_y = config.physics.paddle_y;

    frames_to_impact = (paddle_y - current_pos(2)) / vy;
    raw_x = current_pos(1) + (vx * frames_to_impact);
    
    % --- NEW: O(1) Bouncing Math ---
    % Replaces the slow While Loop with instantaneous Modulo math.
    % Completely prevents freezes when switching between multiple balls.
    
    play_width = right_wall - left_wall;
    x_shifted = raw_x - left_wall;
    
    crossings = floor(x_shifted / play_width);
    rem_x = mod(x_shifted, play_width);
    
    if mod(crossings, 2) == 0
        % Even crossings: Moving Left -> Right
        intercept_x = left_wall + rem_x;
    else
        % Odd crossings: Bouncing Right -> Left
        intercept_x = right_wall - rem_x;
    end
end
