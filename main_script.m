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

frame_counter = 0; 
prev_action_idx = 0; 
prev_prev_action_idx = 0;
prev_ball_pos = []; prev_velocity = []; prev_state = [];
current_input = button();

% NEW: Telemetry Initialization
telemetry = struct('episode', [], 'total_reward', [], 'blocks_broken', [], 'avg_q_value', [], 'jitter_freq', [], 'epsilon', []);
if exist("training_metrics.mat", "file")
    data = load("training_metrics.mat");
    telemetry = data.telemetry;
    fprintf('Resuming telemetry from episode %d...\n', length(telemetry.episode));
end

% Grouping all loose trackers into a single explicit struct
episode_stats = struct('reward', 0, 'q_sum', 0, 'steps', 0, 'jitters', 0, 'blocks', 0);
prev_block_count = 0;
ball_missing_frames = 0; % NEW: Tracks consecutive frames without a ball

% Flags and variables for in-memory save states
level_saved = false; 
level_mem = []; 

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

    % --- AUTO-SAVE STATE LOGIC ---
    % Capture state when both paddle and ball are definitively on screen.
    % This guarantees we are past the title and "Ready" screens.
    objects_present = ~isempty(current_paddle_pos) && ~isempty(current_ball_pos);
    
    if ~level_saved && objects_present
        fprintf('Game started! Capturing emulator memory state at frame %d...\n', frame_counter);
        % Explicitly cast to uint8 to prevent Octave from coercing it to a char array
        level_mem = uint8(arkanoid_rom.get_state);
        level_saved = true;
    end

    % 3. Discretize State & Compute Reward
    current_state = discretize_state(current_paddle_pos, current_ball_pos, velocity, intercept_x, config);
    reward = calculate_visual_reward(current_ball_pos, velocity, prev_velocity, prev_action_idx, prev_prev_action_idx, config);

    % --- DEATH DETECTION (Multi-Ball Safe) ---
    if level_saved
        if isempty(current_ball_pos)
            ball_missing_frames = ball_missing_frames + 1;
        else
            ball_missing_frames = 0;
        end
        
        % If the screen has no ball for 15 frames, the last ball was lost
        if ball_missing_frames >= 15
            reward = -100;
        end
    end

    % --- METRICS UPDATE ---
    episode_stats.reward = episode_stats.reward + reward;
    episode_stats.steps = episode_stats.steps + 1;
    
    if block_count < prev_block_count && prev_block_count > 0
        episode_stats.blocks = episode_stats.blocks + (prev_block_count - block_count);
    end
    prev_block_count = block_count;

    c_idx = num2cell(current_state);
    episode_stats.q_sum = episode_stats.q_sum + max(config.rl.q_table(c_idx{:}, :));
    
    if (prev_action_idx == 1 && prev_prev_action_idx == 2) || (prev_action_idx == 2 && prev_prev_action_idx == 1)
        episode_stats.jitters = episode_stats.jitters + 1;
    end

    % 4. Action Selection & Policy Update
    if isempty(current_paddle_pos)
        action_idx = 0; % Force menu bypass mode if paddle is lost
    else
        [action_idx, config.rl.q_table, config.rl.e_table] = q_learning_agent(current_state, reward, prev_state, prev_action_idx, config);
        
        % --- DYNAMIC EPSILON: Decay exploration rate ---
        config.rl.epsilon = max(config.rl.epsilon_min, config.rl.epsilon * config.rl.epsilon_decay);
    end

    % --- FAST RESET & MENU BYPASS ---
    % Trap the death penalty before we execute the next action
    if reward == -100
        fprintf('Agent died at frame %d. Restoring from memory...\n', frame_counter);
        
        % CRITICAL TD(LAMBDA) MATH: Because the paddle was exploding, standard
        % Q-updates were skipped. We forcefully punish the entire "footprint" 
        % of previous actions that caused the ball to drop.
        config.rl.q_table = config.rl.q_table + (config.rl.alpha * reward * config.rl.e_table);
        
        % --- FINALIZE EPISODE TELEMETRY ---
        [telemetry, episode_stats] = record_episode_telemetry(telemetry, episode_stats, config.rl.epsilon);

        % Teleport back to the exact frame the level started
        if level_saved && ~isempty(level_mem)
            arkanoid_rom.set_state(uint8(level_mem));
        else
            arkanoid_rom.reset(); % Fallback if it died before memory was saved
        end
        
        % CRITICAL: Wipe short-term memory to avoid corrupting the Q-Table
        prev_ball_pos = []; prev_velocity = []; prev_state = [];
        prev_action_idx = 0; prev_prev_action_idx = 0;
        prev_block_count = 0; 
        ball_missing_frames = 0; % Reset the absence tracker
        config.rl.e_table = zeros(size(config.rl.q_table)); % Wipe Eligibility Trace
        
        continue; % Skip the rest of this loop and pull a fresh frame
    end

    % 5. Actuate Environment
    current_input = translate_action_to_input(action_idx, frame_counter);

    % 6. Telemetry & Display Update
    if mod(frame_counter, 5) == 0 || reward ~= 0
        % NEW: Using num2cell so squeeze handles any number of state dimensions automatically
        c_idx = num2cell(current_state);
        q_vals = squeeze(config.rl.q_table(c_idx{:}, :));
        
        update_dashboard(ui_handles, frame_img, q_vals, current_state, current_input, reward, ...
                         ball_mask, paddle_mask, block_mask, current_ball_pos, intercept_x);
    end
    
    % 7. Step History Forward
    prev_ball_pos = current_ball_pos; 
    prev_velocity = velocity;
    prev_state = current_state; 
    prev_prev_action_idx = prev_action_idx;
    prev_action_idx = action_idx;

    % 8. Persistence
    if mod(frame_counter, 1000) == 0
        save_brain(config.rl.q_table, config.rl.epsilon, frame_counter);
    end
end
