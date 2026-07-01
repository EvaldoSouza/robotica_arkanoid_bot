function [telemetry, reset_stats] = record_episode_telemetry(telemetry, ep_stats, config)
    % Appends current episode statistics to the global telemetry struct
    % and persists it to disk periodically. Evaluates best-brain checkpoints.
    
    ep_count = length(telemetry.episode) + 1;
    
    % --- BEST BRAIN CHECKPOINT ---
    % If the agent breaks more blocks than ever before, save this policy!
    best_blocks_so_far = max([0, telemetry.blocks_broken]); 
    if ep_stats.blocks > best_blocks_so_far && ep_stats.blocks > 0
        fprintf("\n NEW HIGH SCORE: %d blocks! Saving Best Brain... \n", ep_stats.blocks);
        q_table = config.rl.q_table;
        epsilon = config.rl.epsilon;
        save("arkanoid_best_brain.mat", "q_table", "epsilon");
    end
    
    telemetry.episode(end+1) = ep_count;
    telemetry.total_reward(end+1) = ep_stats.reward;
    telemetry.blocks_broken(end+1) = ep_stats.blocks;
    
    % Protect against division by zero on frame 1 deaths
    steps = max(1, ep_stats.steps);
    
    telemetry.avg_q_value(end+1) = ep_stats.q_sum / steps;
    telemetry.jitter_freq(end+1) = ep_stats.jitters / steps;
    telemetry.epsilon(end+1) = config.rl.epsilon;
    
    if mod(ep_count, 100) == 0
        save("training_metrics.mat", "telemetry");
        fprintf("--- Telemetry Saved at Episode %d ---\n", ep_count);
    end
    
    % Return a fresh struct to reset the counters for the next episode
    reset_stats = struct('reward', 0, 'q_sum', 0, 'steps', 0, 'jitters', 0, 'blocks', 0);
end
