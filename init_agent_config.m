function config = init_agent_config()
    % Initializes centralized parameters for vision, motor, physics, and RL.
    
    config = struct();
    config.vision.ball_threshold = 0.8;
    config.vision.paddle_threshold = 0.5;
    config.motor.deadzone = 4.0;
    config.physics.left_wall = 16;
    config.physics.right_wall = 240;
    config.physics.paddle_y = 212;
    config.game.frame_skip = 2;

    % STREAMING_CHUNK: Defining RL hyperparameters...
    config.rl.alpha = 0.1;
    config.rl.gamma = 0.99;           
    config.rl.epsilon = 1.0;          
    config.rl.epsilon_decay = 0.9995; 
    config.rl.epsilon_min = 0.05;     
    
    % PHASE 3: TD(Lambda) Hyperparameters
    config.rl.lambda = 0.9; % Trace decay rate (how far back in time rewards propagate)

    % NEW DIMENSIONS: [abs_x(3), rel_x(5), ball_y(3), dir_x(2), dir_y(2), actions(3)]
    % The state space has increased from 60 to 180 states to account for boundaries.
    config.rl.q_table = zeros(3, 5, 3, 2, 2, 3); 
    config.rl.e_table = zeros(3, 5, 3, 2, 2, 3); % Eligibility Trace Memory
    
    if exist("arkanoid_brain.mat", "file")
        fprintf("Loading existing Q-Table brain...\n");
        data = load("arkanoid_brain.mat");
        
        % Safety check: Only load if the saved brain matches the new dimensions
        if isequal(size(data.q_table), size(config.rl.q_table))
            config.rl.q_table = data.q_table;
            
            % Restore exploration rate if it was saved
            if isfield(data, 'epsilon')
                config.rl.epsilon = data.epsilon;
                fprintf("Resuming exploration rate at epsilon = %.4f\n", config.rl.epsilon);
            end
        else
            fprintf("Warning: Brain dimensions changed. Starting fresh.\n");
        end
    end
end
