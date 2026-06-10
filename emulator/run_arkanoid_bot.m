function run_arkanoid_bot(arkanoid_rom)

    frame_counter = 0;

    while frame_counter < 18234500

        frame_counter++;

        process_game_frame(
            arkanoid_rom,
            frame_counter
        );

    endwhile

end
