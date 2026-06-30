function update_dashboard(handles, frame_img, q_values, state_indices, action, reward, ball_mask, paddle_mask, block_mask, ball_pos, intercept_x)
    % Orchestrates UI and console updates for the RL environment.
    % Acts as a thin facade to keep the main bot loop clean.
    %
    % Usage:
    %   update_dashboard(ui_handles, frame, q_vals, state, action, reward, ...
    %                    b_mask, p_mask, blk_mask, [bx,by], intercept_x);
    
    if ~isstruct(handles)
        error("TypeError: handles must be a struct of UI elements.");
    end
    
    update_game_view(handles.game_img, frame_img);
    
    % Safely update vision if masks are provided
    if nargin >= 11
        update_vision_view(handles.vision_img, handles.line_trajectory, handles.point_intercept, ...
                           ball_mask, paddle_mask, block_mask, ball_pos, intercept_x);
    elseif nargin >= 9
        % Fallback for calls without physics data, passing empty lists
        update_vision_view(handles.vision_img, handles.line_trajectory, handles.point_intercept, ...
                           ball_mask, paddle_mask, block_mask, [], []);
    end
    
    update_q_telemetry(handles.q_bars, q_values);
    
    % Optional: print telemetry to console (can be commented out for speed)
    print_state_telemetry(state_indices, action, reward);
end

function update_vision_view(img_handle, line_handle, pt_handle, ball_mask, paddle_mask, block_mask, ball_pos, intercept_x)
    % Renders the agent's internal vision state as a false-color composite.
    % Blocks = Red, Paddle = Green, Ball = Blue.
    % Draws a trajectory line from the ball to the predicted intercept_x.
    %
    % Usage:
    %   update_vision_view(h.img, h.line, h.pt, b_mask, p_mask, blk_mask, [x,y], 105);
    
    if ~ishghandle(img_handle) || ~ishghandle(line_handle) || ~ishghandle(pt_handle)
        error("TypeError: Handles must be valid graphics handles.");
    end
    
    if ~isempty(block_mask); [h, w] = size(block_mask);
    elseif ~isempty(paddle_mask); [h, w] = size(paddle_mask);
    elseif ~isempty(ball_mask); [h, w] = size(ball_mask);
    else; h = 240; w = 256; end % Default fallback
    
    vision_rgb = zeros(h, w, 3, 'uint8');
    
    if ~isempty(block_mask),  vision_rgb(:,:,1) = uint8(block_mask) * 255;  end
    if ~isempty(paddle_mask), vision_rgb(:,:,2) = uint8(paddle_mask) * 255; end
    if ~isempty(ball_mask),   vision_rgb(:,:,3) = uint8(ball_mask) * 255;   end
    
    set(img_handle, 'CData', vision_rgb);
    
    % --- Update the Trajectory Line ---
    if nargin >= 8 && ~isempty(ball_pos) && ~isempty(intercept_x) && intercept_x ~= -1 && ~any(isnan(ball_pos))
        set(line_handle, 'XData', [ball_pos(1), intercept_x], ...
                         'YData', [ball_pos(2), 212], ...
                         'Visible', 'on');
        set(pt_handle, 'XData', intercept_x, ...
                       'YData', 212, ...
                       'Visible', 'on');
    else
        % Hide the line if moving up or missing by setting data to NaN
        set(line_handle, 'XData', [NaN, NaN], 'YData', [NaN, NaN], 'Visible', 'off');
        set(pt_handle,   'XData', NaN, 'YData', NaN, 'Visible', 'off');
    end
end

function update_game_view(img_handle, frame_img)
    % Updates the primary visual game feed.
    % Requires isolating graphics updates from logic so the emulator 
    % can run headlessly if UI handles are omitted.
    %
    % Usage:
    %   update_game_view(handles.game_img, current_frame);
    
    if ~ishghandle(img_handle)
        error("TypeError: img_handle must be a valid graphics handle.");
    end
    if ~isnumeric(frame_img)
        error("TypeError: frame_img expected numeric array. Got %s", class(frame_img));
    end
    
    % Coerce to 3D array for RGB rendering if passed as grayscale
    if ismatrix(frame_img)
        frame_img = repmat(frame_img, [1, 1, 3]);
    end
    
    set(img_handle, 'CData', frame_img);
end

function update_q_telemetry(bar_handle, q_values)
    % Updates the reinforcement learning Q-value bar chart.
    % Separated to allow independent UI scaling without stalling the main loop.
    %
    % Usage:
    %   update_q_telemetry(handles.q_bars, [1.2, 0.5, -0.3]);
    
    if ~ishghandle(bar_handle)
        error("TypeError: bar_handle must be a valid graphics handle.");
    end
    if ~isnumeric(q_values) || numel(q_values) ~= 3
        error("TypeError: q_values expected shape [1, 3] numeric. Got size %s", mat2str(size(q_values)));
    end
    
    set(bar_handle, 'YData', q_values);
    drawnow; % Prevents MATLAB/Octave render queue from blocking execution
end
