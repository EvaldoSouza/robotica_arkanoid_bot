function save_brain(q_table, epsilon, frame_counter)
% Persists the learned Q-Table policy and exploration rate to disk.
%
% Usage:
%   save_brain(config.rl.q_table, config.rl.epsilon, 1000);
    if ~isnumeric(q_table)
    error("TypeError: q_table must be a numeric multi-dimensional array.");
    end

    save("arkanoid_brain.mat", "q_table", "epsilon");
    fprintf("--- Brain Saved at Frame %d (Epsilon: %.4f) ---\n", frame_counter, epsilon);
end
