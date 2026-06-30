function [ball_mask, paddle_mask, block_count, block_mask] = process_game_frame(frame_img, config)
% Coordinates the vision processing pipeline for a single frame.
%
% Usage:
%   [b_mask, p_mask, b_count, blk_mask] = process_game_frame(img, config);

% STREAMING_CHUNK: Validating image inputs...
if ~isnumeric(frame_img)
    error("TypeError: frame_img must be numeric. Got %s", class(frame_img));
end

% STREAMING_CHUNK: Extracting components...
ball_labeled = build_bright_component_map(frame_img, config.vision.ball_threshold);
ball_mask = extract_white_ball(ball_labeled);

[block_count, block_mask] = detect_blocks(frame_img);

paddle_labeled = build_bright_component_map(frame_img, config.vision.paddle_threshold, true);
paddle_mask = extract_paddle(paddle_labeled);


end
