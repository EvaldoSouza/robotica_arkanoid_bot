function [action_idx, updated_q_table, updated_e_table] = q_learning_agent(current_state, reward, prev_state, prev_action_idx, config)
    % Orchestrates the learning update and subsequent action selection using TD(Lambda).
    
    [updated_q_table, updated_e_table] = update_q_value_td_lambda(config.rl.q_table, config.rl.e_table, current_state, reward, prev_state, prev_action_idx, config.rl);
    action_idx = select_epsilon_greedy_action(updated_q_table, current_state, config.rl);
end

function [q_table, e_table] = update_q_value_td_lambda(q_table, e_table, curr_state, reward, prev_state, prev_action, rl_cfg)
    % Applies the TD(Lambda) Bellman equation. Uses cell arrays for dimension-agnostic indexing.
    % Uses vectorized operations to apply rewards backwards in time.
    
    if isempty(prev_state) || prev_action <= 0
        return;
    end
    
    % num2cell allows us to unpack the state array as dynamic matrix coordinates
    c_idx = num2cell(curr_state);
    p_idx = num2cell(prev_state);
    
    old_q = q_table(p_idx{:}, prev_action);
    max_future = max(q_table(c_idx{:}, :));
    
    % 1. Calculate Temporal Difference Error
    delta = reward + rl_cfg.gamma * max_future - old_q;
    
    % 2. Update Eligibility Trace for the visited state (Replacing Trace)
    e_table(p_idx{:}, prev_action) = 1;
    
    % 3. Apply credit backwards through time to all eligible states
    % Because Q and E are identically sized matrices, this is a single vectorized op!
    q_table = q_table + (rl_cfg.alpha * delta * e_table);
    
    % 4. Decay the eligibility trace for the next frame
    e_table = e_table * (rl_cfg.gamma * rl_cfg.lambda);
end

function action_idx = select_epsilon_greedy_action(q_table, curr_state, rl_cfg)
    % Balances exploration vs exploitation based on epsilon decay.
    
    if rand() < rl_cfg.epsilon
        action_idx = randi([1, 3]);
    else
        c_idx = num2cell(curr_state);
        state_actions = q_table(c_idx{:}, :);
        [~, action_idx] = max(state_actions(:)); 
    end
end
