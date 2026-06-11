function input_buttons = calculate_paddle_input(paddle_pos, intercept_x, frame_counter)
    % Default state: press nothing
    input_buttons = botao(); 

    % --- STATE 1: Menu / Loading Screen ---
    if isempty(paddle_pos)
        % Pulse the START button for 5 frames every 60 frames
        if mod(frame_counter, 60) < 5
            input_buttons = botao("START");
        end
        return; 
    end

    % --- STATE 2: Waiting for Ball ---
    if intercept_x == -1
        return; 
    end

    % --- STATE 3: Intercepting ---
    paddle_x = paddle_pos(1);
    deadzone = 4.0; 

    if paddle_x < (intercept_x - deadzone)
        input_buttons = botao("RIGHT");
    elseif paddle_x > (intercept_x + deadzone)
        input_buttons = botao("LEFT");
    end
end
