function input_buttons = calculate_paddle_input(paddle_pos, intercept_x, frame_counter, config)
    input_buttons = button(); % Using renamed function

    if isempty(paddle_pos)
        if mod(frame_counter, 60) < 5
            input_buttons = button("START");
        end
        return; 
    end

    if intercept_x == -1
        return; 
    end

    paddle_x = paddle_pos(1);
    
    % --- NEW: Extracting deadzone from config ---
    deadzone = config.motor.deadzone; 

    if paddle_x < (intercept_x - deadzone)
        input_buttons = button("RIGHT");
    elseif paddle_x > (intercept_x + deadzone)
        input_buttons = button("LEFT");
    end
end
