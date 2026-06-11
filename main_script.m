addpath("vision");
addpath("emulator");
addpath("debug");

%warning off;
pkg load retro_games;
pkg load image;

arkanoid_rom = load_rom("roms/arkanoid.nes");

run_arkanoid_bot(arkanoid_rom);
