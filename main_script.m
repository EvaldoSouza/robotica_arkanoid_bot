addpath("vision");
addpath("emulator");
addpath("debug");

if exist('OCTAVE_VERSION', 'builtin') > 0
    pkg load retro_games;
    pkg load image;
end

arkanoid_rom = load_rom("roms/arkanoid.nes");

% Initialize State
frame_counter = 0;
prev_ball_pos = [];
current_input = botao(); % Start with no buttons pressed
frame_skip = 10; 

fprintf("Starting Arkanoid Main Loop...\n");

while true 
    frame_counter = frame_counter + 1;

    arkanoid_rom.set_input(current_input);
    arkanoid_rom.step(frame_skip); 
    
    frame_img = arkanoid_rom.get_image();

    [current_input, prev_ball_pos] = run_arkanoid_bot( ...
        frame_img, ...
        frame_counter, ...
        prev_ball_pos ...
    );
end
