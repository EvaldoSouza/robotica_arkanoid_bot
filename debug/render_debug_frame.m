function render_debug_frame(frame_img, ball_mask, paddle_mask, ball_pos, velocity, intercept_x)
    % Uses a persistent handle to update the figure efficiently 
    % without causing Octave graphics pipeline segfaults.
    persistent h_img;
    
    % --- 1. Console Output ---
    % Clears the console for a clean, static-looking HUD effect
    clc; 
    fprintf("=== Arkanoid Bot Telemetry ===\n");
    
    if ~isempty(ball_pos)
        fprintf("Ball Pos:   [X: %6.1f, Y: %6.1f]\n", ball_pos(1), ball_pos(2));
    else
        fprintf("Ball Pos:   [ Not Detected ]\n");
    end

    if ~isempty(velocity)
        fprintf("Velocity:   [X: %6.1f, Y: %6.1f]\n", velocity(1), velocity(2));
    else
        fprintf("Velocity:   [ Calculating... ]\n");
    end

    if intercept_x ~= -1
        fprintf("Intercept:  [Predicted X: %6.1f]\n", intercept_x);
    else
        fprintf("Intercept:  [ N/A - Moving Up or Lost ]\n");
    end
    fprintf("==============================\n");

    % --- 2. Visual Overlay (Composite Image) ---
    % Convert the grayscale/binary frame to RGB so we can colorize masks
    if size(frame_img, 3) == 1
        debug_img = cat(3, frame_img, frame_img, frame_img);
    else
        debug_img = frame_img;
    end

    % Make the ball RED
    red_channel = debug_img(:,:,1);
    red_channel(ball_mask > 0) = 255;
    debug_img(:,:,1) = red_channel;

    % Make the paddle CYAN (Green + Blue)
    green_channel = debug_img(:,:,2);
    green_channel(paddle_mask > 0) = 255;
    debug_img(:,:,2) = green_channel;

    blue_channel = debug_img(:,:,3);
    blue_channel(paddle_mask > 0) = 255;
    debug_img(:,:,3) = blue_channel;

    % --- 3. Efficient Graphics Rendering ---
    % If the figure doesn't exist yet, create it. Otherwise, just update the data.
    if isempty(h_img) || ~ishandle(h_img)
        figure("Name", "Arkanoid Vision Debug", "NumberTitle", "off");
        h_img = imshow(debug_img);
    else
        set(h_img, 'CData', debug_img);
    end

    %figure(2);
    %imshow(ball_mask);
    %title("Ball Vision");

    %figure(3);
    %imshow(paddle_mask);
    %title("Paddle Vision");

    % Force Octave to flush the graphics pipeline
    drawnow;
end
