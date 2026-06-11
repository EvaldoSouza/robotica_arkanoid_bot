addpath("vision");
addpath("emulator");
addpath("debug");

if exist('OCTAVE_VERSION', 'builtin') > 0
    pkg load retro_games;
    pkg load image;
end

arkanoid_rom = load_rom("roms/arkanoid.nes");

% --- Centralized Configuration ---
config = struct();
config.vision.ball_threshold = 0.8;
config.vision.paddle_threshold = 0.6;
config.motor.deadzone = 4.0;
config.physics.left_wall = 16;
config.physics.right_wall = 240;
config.physics.paddle_y = 212;
config.game.frame_skip = 10;
% --------------------------------------

frame_counter = 0;
prev_ball_pos = [];
current_input = button();

fprintf("Starting Arkanoid Main Loop...\n");

while true 
    frame_counter = frame_counter + 1;

    arkanoid_rom.set_input(current_input);
    arkanoid_rom.step(config.game.frame_skip); 
    
    frame_img = arkanoid_rom.get_image();

    [current_input, prev_ball_pos] = run_arkanoid_bot( ...
        frame_img, ...
        frame_counter, ...
        prev_ball_pos, ...
        config ...
    );
end
