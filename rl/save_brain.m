function save_brain(q_table, frame_counter)
% Persists the learned Q-Table policy to disk.
%
% Usage:
%   save_brain(config.rl.q_table, 1000);
    if ~isnumeric(q_table)
    error("TypeError: q_table must be a numeric multi-dimensional array.");
    end

    save("arkanoid_brain.mat", "q_table");
    fprintf("--- Brain Saved at Frame %d ---\n", frame_counter);
end
