% main_script.m
% Entry point and main orchestrator for the Arkanoid RL agent.

clear all; close all;
addpath("vision"); addpath("emulator"); addpath("debug"); addpath("rl"); addpath("display");

if exist('OCTAVE_VERSION', 'builtin') > 0
    pkg load retro_games; 
    pkg load image;
end

% STREAMING_CHUNK: Initializing Environment & Dependencies...
arkanoid_rom = load_rom("roms/arkanoid.nes");
config = init_agent_config();
ui_handles = init_dashboard();

frame_counter = 0; prev_block_count = 0; prev_action_idx = 0;
prev_ball_pos = []; prev_velocity = []; prev_state = [];
current_input = button();

fprintf("Starting Arkanoid Main Loop...\n");

% STREAMING_CHUNK: Running main agent loop...
while true
    frame_counter = frame_counter + 1;

    % 1. Step Emulator
    arkanoid_rom.set_input(current_input);
    arkanoid_rom.step(config.game.frame_skip); 
    frame_img = arkanoid_rom.get_image();

    % 2. Perception Pipeline
    [ball_mask, paddle_mask, block_count, block_mask] = process_game_frame(frame_img, config);
    current_ball_pos = extract_centroid(ball_mask);
    current_paddle_pos = extract_centroid(paddle_mask);
    [velocity, intercept_x] = predict_trajectory(current_ball_pos, prev_ball_pos, config);

    % 3. Discretize State & Compute Reward
    current_state = discretize_state(current_paddle_pos, current_ball_pos, velocity, intercept_x);
    reward = calculate_visual_reward(current_ball_pos, velocity, prev_velocity, block_count, prev_block_count, config);

    % 4. Action Selection & Policy Update
    if isempty(current_paddle_pos)
        action_idx = 0; % Force menu bypass mode if paddle is lost
    else
        [action_idx, config.rl.q_table] = q_learning_agent(current_state, reward, prev_state, prev_action_idx, config);
    end

    % 5. Actuate Environment
    current_input = translate_action_to_input(action_idx, frame_counter);

    % 6. Telemetry & Display Update
    if mod(frame_counter, 5) == 0 || reward ~= 0
        % Get Q-values for current state for plotting
        q_vals = squeeze(config.rl.q_table(current_state(1), current_state(2), current_state(3), current_state(4), :));
        
        % Update dashboard with all available data.
        % We now pass ball_pos and velocity instead of intercept_x.
        update_dashboard(ui_handles, frame_img, q_vals, current_state, current_input, reward, ...
                         ball_mask, paddle_mask, block_mask, current_ball_pos, intercept_x);
    end
    % 7. Step History Forward
    prev_ball_pos = current_ball_pos; prev_velocity = velocity;
    prev_block_count = block_count; prev_state = current_state; prev_action_idx = action_idx;

    % 8. Persistence
    if mod(frame_counter, 1000) == 0
        save_brain(config.rl.q_table, frame_counter);
    end


end
