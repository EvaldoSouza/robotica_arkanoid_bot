function plot_learning_curve()
    % Monitors and plots RL training metrics asynchronously.
    % Run this script in a separate Octave/MATLAB instance!
    
    fig = figure('Name', 'RL Training Dashboard', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 600]);
    
    while ishandle(fig)
        if exist('training_metrics.mat', 'file')
            try
                data = load('training_metrics.mat');
                render_charts(data.telemetry);
            catch
                % Do not fail silently! Print the error so we can debug rendering issues.
                err = lasterror();
                fprintf('Ignored render error: %s\n', err.message);
            end
        else
            fprintf('Waiting for training_metrics.mat to be generated...\n');
        end
        pause(5); % Refresh interval
    end
end

function render_charts(metrics)
    if isempty(metrics.episode)
        return;
    end
    
    window = min(50, length(metrics.episode)); % 50-episode moving average
    
    subplot_reward(metrics, window);
    subplot_task(metrics, window);
    subplot_confidence(metrics, window);
    subplot_smoothness(metrics, window);
    
    drawnow;
end

function subplot_reward(metrics, window)
    subplot(2, 2, 1);
    plot(metrics.episode, metrics.total_reward, 'Color', [0.8 0.8 0.8]);
    hold on;
    plot(metrics.episode, smooth_series(metrics.total_reward, window), 'b', 'LineWidth', 2);
    hold off;
    title('Cumulative Episodic Reward');
    xlabel('Episode'); ylabel('Reward');
end

function subplot_task(metrics, window)
    subplot(2, 2, 2);
    
    smoothed_blocks = smooth_series(metrics.blocks_broken, window);
    
    % Using plotyy instead of yyaxis for strict Octave compatibility
    [ax, h1, h2] = plotyy(metrics.episode, smoothed_blocks, metrics.episode, metrics.epsilon);
    
    set(h1, 'Color', 'g', 'LineWidth', 2);
    set(h2, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
    
    ylabel(ax(1), 'Blocks (Moving Avg)');
    ylabel(ax(2), 'Epsilon');
    
    title('Task Performance vs Exploration');
    xlabel('Episode');
end

function subplot_confidence(metrics, window)
    subplot(2, 2, 3);
    plot(metrics.episode, smooth_series(metrics.avg_q_value, window), 'm', 'LineWidth', 2);
    title('Average Max Q-Value');
    xlabel('Episode'); ylabel('Q-Value');
end

function subplot_smoothness(metrics, window)
    subplot(2, 2, 4);
    plot(metrics.episode, smooth_series(metrics.jitter_freq, window), 'k', 'LineWidth', 2);
    title('Jitter Frequency');
    xlabel('Episode'); ylabel('Jitters / Step');
end

function smoothed = smooth_series(data, window)
    % A universally compatible moving average.
    % Written explicitly to avoid toolbox dependencies.
    
    if isempty(data)
        smoothed = [];
        return;
    end
    
    smoothed = zeros(size(data));
    for i = 1:length(data)
        start_idx = max(1, i - window + 1);
        smoothed(i) = mean(data(start_idx:i));
    end
end
