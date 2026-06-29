function [block_count, block_mask] = detect_blocks(frame_img)
    % Detects Arkanoid blocks using highly performant Grid Sampling.
    % Returns the total count of surviving blocks and a visualization mask.
    
    % Arkanoid block grid properties
    % (These might need slight tuning depending on your exact ROM/level)
    block_w = 16;
    block_h = 8;
    num_cols = 11; % Adjust based on the level width before pixel 191
    num_rows = 18;  % Adjust based on the starting level
    
    start_x = 24;  % Center of the first block (Left wall 16 + half block 8)
    start_y = 20;  % Approximate Y center of the top row (Tune this!)
    
    % Ensure grayscale to easily check against the black background
    if size(frame_img, 3) == 3
        gray_img = rgb2gray(frame_img);
    else
        gray_img = frame_img;
    end
    
    block_count = 0;
    block_mask = zeros(size(gray_img), 'uint8');
    
    for row = 0:(num_rows-1)
        for col = 0:(num_cols-1)
            % Calculate the center pixel of the current grid cell
            sample_x = start_x + (col * block_w);
            sample_y = start_y + (row * block_h);
            
            % Bounds checking just in case
            if sample_x > size(gray_img, 2) || sample_y > size(gray_img, 1)
                continue;
            end
            
            % Check if the pixel is NOT the black background
            % Using 50 as a threshold since blocks can be dark blue or red
            if gray_img(sample_y, sample_x) > 50
                block_count = block_count + 1;
                
                % Draw a small 3x3 square on the mask so we can see it on the dashboard
                block_mask(sample_y-1:sample_y+1, sample_x-1:sample_x+1) = 255;
            end
        end
    end
end
