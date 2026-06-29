clear all;
close all;

addpath("vision");
addpath("emulator");
addpath("debug");
addpath("rl");

if exist('OCTAVE_VERSION', 'builtin') > 0
    pkg load retro_games;
    pkg load image;
end

arkanoid_rom = load_rom("roms/arkanoid.nes");

% --- Centralized Configuration ---
config = struct();
config.vision.ball_threshold = 0.8;
config.vision.paddle_threshold = 0.5;
config.motor.deadzone = 4.0;
config.physics.left_wall = 16;
config.physics.right_wall = 240;
config.physics.paddle_y = 212;
config.game.frame_skip = 2;
% --------------------------------------
% --- RL Configuration ---
config.rl.alpha = 0.1;
config.rl.gamma = 0.95;
config.rl.epsilon = 0.2;
% Dimensions: [rel_x(5), ball_y(3), dir_x(2), dir_y(2), actions(3)]
config.rl.q_table = zeros(5, 3, 2, 2, 3); 

% Load brain if it exists
if exist("arkanoid_brain.mat", "file")
    fprintf("Loading existing Q-Table brain...\n");
    load("arkanoid_brain.mat", "q_table");
    config.rl.q_table = q_table;
end
% --------------------------------------

frame_counter = 0;
current_input = button();
prev_ball_pos = [];
prev_velocity = [];
prev_state = [];         
prev_action_idx = 0;

fprintf("Starting Arkanoid Main Loop...\n");

while true 
    frame_counter = frame_counter + 1;

    arkanoid_rom.set_input(current_input);
    arkanoid_rom.step(config.game.frame_skip); 
    
    frame_img = arkanoid_rom.get_image();

    [current_input, prev_ball_pos, prev_velocity, prev_state, prev_action_idx, config] = run_arkanoid_bot( ...
        frame_img, ...
        frame_counter, ...
        prev_ball_pos, ...
        prev_velocity, ...
        prev_state, ...
        prev_action_idx, ...
        config ...
    );

    % Save brain periodically (every 1000 frames)
    if mod(frame_counter, 1000) == 0
        q_table = config.rl.q_table;
        save("arkanoid_brain.mat", "q_table");
        fprintf("--- Brain Saved at Frame %d ---\n", frame_counter);
    end
end
