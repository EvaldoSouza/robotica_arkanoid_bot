function rl_dashboard(frame_img, ball_mask, paddle_mask, ball_pos, intercept_x, q_table, current_state, reward, epsilon, frame_counter, action_idx)
    % A high-performance, Data-Mutation dashboard for Reinforcement Learning.
    % Uses persistent handles to update graphics without re-drawing the UI.
    persistent handles;

    % 1. INITIALIZATION (Runs only once, or if the window is closed)
    if isempty(handles) || ~ishandle(handles.fig)
        handles = init_dashboard_internals();
    end

    % --- 2. GAME FRAME UPDATE ---
    if size(frame_img, 3) == 1
        game_rgb = cat(3, frame_img, frame_img, frame_img);
    else
        game_rgb = frame_img;
    end
    set(handles.img_game, 'CData', game_rgb);

    % --- 3. VISION & TRAJECTORY UPDATE ---
    vision_rgb = zeros(size(game_rgb), 'uint8');
    vision_rgb(:,:,1) = ball_mask;   % Red Ball
    vision_rgb(:,:,2) = paddle_mask; % Cyan Paddle
    vision_rgb(:,:,3) = paddle_mask; 
    set(handles.img_vision, 'CData', vision_rgb);

    % Update Trajectory Line
    if ~isempty(ball_pos) && intercept_x ~= -1
        set(handles.line_trajectory, 'XData', [ball_pos(1), intercept_x], 'YData', [ball_pos(2), 212]);
        set(handles.point_intercept, 'XData', intercept_x, 'YData', 212);
    else
        % Hide the line if moving up or missing
        set(handles.line_trajectory, 'XData', [0 0], 'YData', [0 0]);
        set(handles.point_intercept, 'XData', 0, 'YData', 0);
    end

    % --- 4. BRAIN UPDATE (Q-Values & Strategy) ---
    if ~isempty(current_state)
        c_rx = current_state(1); c_y = current_state(2); c_dx = current_state(3); c_dy = current_state(4);
        
        % Update Bar Chart
        current_q_vals = squeeze(q_table(c_rx, c_y, c_dx, c_dy, :));
        set(handles.bar_q, 'YData', current_q_vals);
        
        % Dynamically adjust Bar Chart limits so it doesn't clip
        min_q = min(-10, min(current_q_vals) * 1.2);
        max_q = max(10, max(current_q_vals) * 1.2);
        
        bar_parent_axes = get(handles.bar_q, 'Parent');
        set(bar_parent_axes, 'YLim', [min_q, max_q]);

        % Update Heatmap (Slice: All X-Positions vs All Actions)
        heatmap_slice = squeeze(q_table(:, c_y, c_dx, c_dy, :))';
        set(handles.img_heatmap, 'CData', heatmap_slice);
        
        % Dynamically adjust Heatmap colors
        if max(heatmap_slice(:)) > min(heatmap_slice(:))
            heatmap_parent_axes = get(handles.img_heatmap, 'Parent');
            set(heatmap_parent_axes, 'CLim', [min(heatmap_slice(:)), max(heatmap_slice(:))]);
        end
    end

    % Flush the graphics pipeline
    drawnow;

    % --- 5. TEXT TELEMETRY (Console) ---
    clc;
    fprintf("=== Arkanoid RL Training Dashboard ===\n");
    fprintf("Frame: %d | Epsilon (Exploration): %.2f\n", frame_counter, epsilon);
    fprintf("Last Frame Reward: %6.1f\n", reward);
    
    actions = {"1: LEFT", "2: RIGHT", "3: IDLE"};
    action_str = "MENU / OVERRIDE";
    if action_idx > 0 && action_idx <= 3
        action_str = actions{action_idx};
    end
    fprintf("Current Action Taken: %s\n", action_str);

    if ~isempty(current_state)
        fprintf("\n--- Current Visual State ---\n");
        fprintf("Relative X Index : %d (1=FarLeft, 3=Center, 5=FarRight)\n", c_rx);
        fprintf("Height Index     : %d (1=High, 3=Imminent Impact)\n", c_y);
        fprintf("Dir X Index      : %d (1=Left, 2=Right)\n", c_dx);
        fprintf("Dir Y Index      : %d (1=Up, 2=Down)\n", c_dy);
    end
    fprintf("======================================\n");
end

function handles = init_dashboard_internals()
    % Helper function to create the UI layout once
    handles.fig = figure("Name", "Arkanoid RL Dashboard", "NumberTitle", "off", "Position", [100, 100, 1000, 800]);

    % Top-Left: Game
    subplot(2, 2, 1);
    handles.img_game = imshow(zeros(240, 256, 3, 'uint8'));
    title("Live Game Feed");

    % Top-Right: Vision & Prediction
    subplot(2, 2, 2);
    handles.img_vision = imshow(zeros(240, 256, 3, 'uint8'));
    hold on;
    handles.line_trajectory = plot([0 0], [0 0], 'r--', 'LineWidth', 2);
    handles.point_intercept = plot(0, 0, 'y*', 'MarkerSize', 10);
    hold off;
    title("Vision Masks & Predictive Overlay");

    % Bottom-Left: Current Q-Values
    subplot(2, 2, 3);
    handles.bar_q = bar([0, 0, 0]);
    set(gca, 'XTickLabel', {'LEFT', 'RIGHT', 'IDLE'});
    title("Action Confidence (Current State)");

    % Bottom-Right: Strategy Heatmap
    subplot(2, 2, 4);
    handles.img_heatmap = imagesc(zeros(3, 5));
    colorbar;
    title("Strategy Heatmap (Actions vs Ball X-Pos)");
    set(gca, 'XTick', 1:5, 'XTickLabel', {'Far L', 'Left', 'Center', 'Right', 'Far R'});
    set(gca, 'YTick', 1:3, 'YTickLabel', {'LEFT', 'RIGHT', 'IDLE'});
    
    drawnow;
end
