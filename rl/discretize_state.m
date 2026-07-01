function state_indices = discretize_state(paddle_pos, ball_pos, velocity, intercept_x, config)
    % Converts continuous vision coordinates into a discrete 5D state vector
    % [abs_x, relative_x, ball_y, dir_x, dir_y]
    
    if nargin < 5 || isempty(paddle_pos) || isempty(ball_pos) || isempty(velocity)
        state_indices = [2, 3, 1, 1, 1]; % Default fallback state
        return;
    end

    abs_x = bin_absolute_x(paddle_pos(1), config);
    rel_x = bin_relative_x(paddle_pos(1), ball_pos(1), intercept_x);
    ball_y = bin_ball_y(ball_pos(2));
    [dir_x, dir_y] = bin_velocity(velocity);

    state_indices = [abs_x, rel_x, ball_y, dir_x, dir_y];
end

function ax = bin_absolute_x(paddle_x, config)
    % 3 Bins: Left Wall (1), Middle (2), Right Wall (3)
    if paddle_x < config.physics.left_wall + 15
        ax = 1;
    elseif paddle_x > config.physics.right_wall - 15
        ax = 3;
    else
        ax = 2;
    end
end

function rx = bin_relative_x(paddle_x, ball_x, intercept_x)
    % 5 Bins: Far Left (1), Left (2), Center (3), Right (4), Far Right (5)
    target_x = ball_x;
    if intercept_x ~= -1
        target_x = intercept_x;
    end
    
    diff_x = target_x - paddle_x;
    
    if diff_x < -20;     rx = 1;
    elseif diff_x < -5;  rx = 2;
    elseif diff_x <= 5;  rx = 3;
    elseif diff_x <= 20; rx = 4;
    else;                rx = 5;
    end
end

function by = bin_ball_y(y)
    % 3 Bins: High/Safe (1), Medium (2), Low/Imminent (3)
    if y < 100;     by = 1;
    elseif y < 180; by = 2;
    else;           by = 3;
    end
end

function [dx, dy] = bin_velocity(vel)
    % 2 Bins each: Left/Right (1/2), Up/Down (1/2)
    dx = 2; if vel(1) < 0; dx = 1; end
    dy = 2; if vel(2) < 0; dy = 1; end
end
