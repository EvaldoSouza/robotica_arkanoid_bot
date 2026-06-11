function [velocity, intercept_x] = predict_trajectory(current_pos, prev_pos)
    % Default returns
    velocity = [0, 0];
    intercept_x = -1; % -1 indicates no valid prediction (e.g., moving up)

    % If we don't have a previous position yet, we can't calculate velocity
    if isempty(prev_pos) || isempty(current_pos)
        return;
    end

    % 1. Calculate Velocity Vector
    velocity = current_pos - prev_pos;
    vx = velocity(1);
    vy = velocity(2);

    % If the ball is not moving down, we don't need to intercept it yet
    if vy <= 0
        return;
    end

    % 2. Define Playfield Boundaries (Adjust these based on exact NES pixels)
    left_wall = 16;
    right_wall = 240;
    paddle_y = 212;

    % 3. Calculate Time to Intercept
    % How many frames until the ball reaches the paddle's Y plane?
    frames_to_impact = (paddle_y - current_pos(2)) / vy;

    % 4. Raw X Prediction
    raw_x = current_pos(1) + (vx * frames_to_impact);

    % 5. The "Fold" (Wall Bouncing)
    % We use a while loop to handle multiple bounces (e.g., zig-zagging down)
    intercept_x = raw_x;
    
    while intercept_x < left_wall || intercept_x > right_wall
        if intercept_x < left_wall
            % Overshot left. Fold it back to the right.
            overshoot = left_wall - intercept_x;
            intercept_x = left_wall + overshoot;
        elseif intercept_x > right_wall
            % Overshot right. Fold it back to the left.
            overshoot = intercept_x - right_wall;
            intercept_x = right_wall - overshoot;
        end
    end
end
