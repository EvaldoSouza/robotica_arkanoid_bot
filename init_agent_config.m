function config = init_agent_config()
    % Initializes centralized parameters for vision, motor, physics, and RL.
    % Separated to keep the main script clean and under the length limit.
    %
    % Usage:
    %   config = init_agent_config(); 

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
    config.rl.gamma = 0.99;           % Extended horizon for long-term survival
    config.rl.epsilon = 1.0;          % Start fully random (exploration)
    config.rl.epsilon_decay = 0.9995; % Multiply epsilon by this each frame
    config.rl.epsilon_min = 0.05;     % Never drop below 5% exploration

    % Dimensions: [rel_x(5), ball_y(3), dir_x(2), dir_y(2), actions(3)]
    config.rl.q_table = zeros(5, 3, 2, 2, 3); 

    % STREAMING_CHUNK: Loading existing brain state...
    if exist("arkanoid_brain.mat", "file")
        fprintf("Loading existing Q-Table brain...\n");
        data = load("arkanoid_brain.mat", "q_table");
        config.rl.q_table = data.q_table;
    end
end
