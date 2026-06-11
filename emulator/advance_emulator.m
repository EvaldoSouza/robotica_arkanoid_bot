function advance_emulator(arkanoid_rom, active_input)
    % Keep the original stepping rhythm
    arkanoid_rom.step(5);
    arkanoid_rom.set_input(active_input);
    arkanoid_rom.step(5);
end
