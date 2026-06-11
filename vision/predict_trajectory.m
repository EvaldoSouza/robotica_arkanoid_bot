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

    % --- NEW: Extracting physics boundaries from config ---
    left_wall = config.physics.left_wall;
    right_wall = config.physics.right_wall;
    paddle_y = config.physics.paddle_y;

    frames_to_impact = (paddle_y - current_pos(2)) / vy;
    raw_x = current_pos(1) + (vx * frames_to_impact);
    intercept_x = raw_x;
    
    while intercept_x < left_wall || intercept_x > right_wall
        if intercept_x < left_wall
            overshoot = left_wall - intercept_x;
            intercept_x = left_wall + overshoot;
        elseif intercept_x > right_wall
            overshoot = intercept_x - right_wall;
            intercept_x = right_wall - overshoot;
        end
    end
end
