function process_game_frame( ...
    arkanoid_rom, ...
    frame_counter)

    addpath("vision");
    advance_emulator(
        arkanoid_rom,
        frame_counter
    );

    frame_img = arkanoid_rom.get_image();

    labeled_matrix = build_bright_component_map(
        frame_img,
        0.8
    );

    ball_mask = extract_white_ball(
        labeled_matrix
    );

    render_debug_frame(ball_mask);

end
