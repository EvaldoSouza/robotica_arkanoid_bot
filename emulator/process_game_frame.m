function process_game_frame( ...
    arkanoid_rom, ...
    frame_counter)

    advance_emulator(
        arkanoid_rom,
        frame_counter
    );

    frame_img = arkanoid_rom.get_image();

    labeled_matrix = build_bright_component_map(
        frame_img,
        0.8
    );

    %inspect_components(frame_img, labeled_matrix); %chamando função de debug para ver o formato do paddle

    ball_mask = extract_white_ball(
        labeled_matrix
    );

    paddle_mask = extract_paddle(labeled_matrix);

    combined_masks = max(ball_mask, paddle_mask);

    render_debug_frame(combined_masks);
end
