function advance_emulator( ...
    arkanoid_rom, ...
    frame_counter)

    arkanoid_rom.step(5);

    if frame_counter == 5
        arkanoid_rom.set_input(
            botao("START")
        );
    else
        arkanoid_rom.set_input(
            botao()
        );
    endif

    arkanoid_rom.step(5);

end
