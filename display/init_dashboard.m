function handles = init_dashboard()
    % Initializes the visualization figure for the RL agent.
    % We isolate initialization to prevent continuous figure reallocation
    % which severely degrades emulation frame rates.
    %
    % Usage:
    %   ui_handles = init_dashboard();
    
    fig = figure('Name', 'Arkanoid RL Dashboard', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 400]);
    
    % Panel 1: Game Feed
    subplot(1, 3, 1);
    handles.game_img = imshow(zeros(240, 256, 3, 'uint8'));
    title('Live Game Feed');
    
    % Panel 2: Agent Vision
    ax2 = subplot(1, 3, 2);
    handles.vision_img = imshow(zeros(240, 256, 3, 'uint8'));
    hold(ax2, 'on'); % Hold axes to add plots on top of image
    
    % Initialize invisible elements for the trajectory line and intercept point
    handles.line_trajectory = plot(ax2, [NaN, NaN], [NaN, NaN], 'y-', 'LineWidth', 2, 'Visible', 'off');
    handles.point_intercept = plot(ax2, NaN, NaN, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r', 'Visible', 'off');
    
    hold(ax2, 'off');
    title('Agent Vision (R:Blocks G:Paddle B:Ball)');
    
    % Panel 3: Q-Values
    subplot(1, 3, 3);
    handles.q_bars = bar([0, 0, 0]);
    set(gca, 'XTickLabel', {'Left', 'Stay', 'Right'});
    title('Q-Values by Action');
    
    handles.fig = fig;
end
