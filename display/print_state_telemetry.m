function print_state_telemetry(state_indices, action, reward)
    % Prints the RL state transition to the console.
    % Provides an audit trail for Q-table updates without relying on the GUI.
    %
    % Usage:
    %   print_state_telemetry([3, 2, 2, 1], 2, 10);
    
    if ~isnumeric(state_indices) || isempty(state_indices)
        error("TypeError: state_indices must be a non-empty numeric array.");
    end
    if ~isnumeric(action) || ~isnumeric(reward)
        error("TypeError: action and reward must be numeric scalars.");
    end
    
    fprintf('State: [%s] | Action: %d | Reward: %.2f\n', ...
            num2str(state_indices), action, reward);
end
