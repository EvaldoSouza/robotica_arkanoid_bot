function [telemetry, reset_stats] = record_episode_telemetry(telemetry, ep_stats, epsilon)
    % Appends current episode statistics to the global telemetry struct
    % and persists it to disk periodically.
    
    ep_count = length(telemetry.episode) + 1;
    
    telemetry.episode(end+1) = ep_count;
    telemetry.total_reward(end+1) = ep_stats.reward;
    telemetry.blocks_broken(end+1) = ep_stats.blocks;
    
    % Protect against division by zero on frame 1 deaths
    steps = max(1, ep_stats.steps);
    
    telemetry.avg_q_value(end+1) = ep_stats.q_sum / steps;
    telemetry.jitter_freq(end+1) = ep_stats.jitters / steps;
    telemetry.epsilon(end+1) = epsilon;
    
    if mod(ep_count, 20) == 0
        save("training_metrics.mat", "telemetry");
        fprintf("--- Telemetry Saved at Episode %d ---\n", ep_count);
    end
    
    % Return a fresh struct to reset the counters for the next episode
    reset_stats = struct('reward', 0, 'q_sum', 0, 'steps', 0, 'jitters', 0, 'blocks', 0);
end
