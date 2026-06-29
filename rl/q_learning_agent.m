function [action_idx, updated_q_table] = q_learning_agent(current_state, reward, prev_state, prev_action_idx, config)
    % Q-Learning agent that updates the Q-table and selects the next action
    % action_idx maps to: 1 = LEFT, 2 = RIGHT, 3 = IDLE
    
    updated_q_table = config.rl.q_table;
    
    % --- 1. UPDATE PHASE (Learning) ---
    % We only learn if we actually made a move in a previous state
    if ~isempty(prev_state) && prev_action_idx > 0
        % Extract indices for readability
        p_rx = prev_state(1); p_y = prev_state(2); p_dx = prev_state(3); p_dy = prev_state(4);
        c_rx = current_state(1); c_y = current_state(2); c_dx = current_state(3); c_dy = current_state(4);
        
        % Current Q-value for the action we took
        old_q = updated_q_table(p_rx, p_y, p_dx, p_dy, prev_action_idx);
        
        % Estimate of optimal future value
        max_future_q = max(updated_q_table(c_rx, c_y, c_dx, c_dy, :));
        
        % The Bellman Equation
        new_q = old_q + config.rl.alpha * (reward + config.rl.gamma * max_future_q - old_q);
        
        % Save the new knowledge
        updated_q_table(p_rx, p_y, p_dx, p_dy, prev_action_idx) = new_q;
    end
    
    % --- 2. ACTION SELECTION PHASE (Epsilon-Greedy) ---
    if rand() < config.rl.epsilon
        % Exploration: Roll the dice, pick a random action (1, 2, or 3)
        action_idx = randi([1, 3]);
    else
        % Exploitation: Trust the Q-table and pick the best action
        c_rx = current_state(1); c_y = current_state(2); c_dx = current_state(3); c_dy = current_state(4);
        
        % Extract the 3 Q-values for the current state
        state_actions = updated_q_table(c_rx, c_y, c_dx, c_dy, :);
        
        % Find the index of the highest Q-value
        [~, action_idx] = max(state_actions(:)); 
    end
end
