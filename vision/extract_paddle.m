function paddle_mask = extract_paddle(labeled_matrix)
    % Extracts the Arkanoid paddle based on geometric constraints.
    % Relies on the same connected components used by the ball detector.

    stats = regionprops(labeled_matrix, "Area", "BoundingBox", "Centroid"); %não precisa de centroid, ou melhor, está errado, mas vamos testar primeiro
    
    % Collect indices of all regions that pass the paddle test
    valid_indices = [];

    for i = 1:numel(stats)
        if is_paddle_candidate(stats(i))
            % Octave handles dynamic array growth reasonably well here
            % since there are very few connected components per frame
            valid_indices(end + 1) = i; 
        end
    end

    % Vectorized mask generation: instantly creates a binary mask 
    % matching any pixel that belongs to a valid region index.
    paddle_mask = uint8(ismember(labeled_matrix, valid_indices)) * 255;
end

function is_candidate = is_paddle_candidate(region_stats)
    area = region_stats.Area;
    centroid_y = region_stats.Centroid(2);
    bbox = region_stats.BoundingBox;
    
    width = bbox(3);
    height = bbox(4);
    
    if height > 0
        aspect_ratio = width / height;
    else
        aspect_ratio = 0;
    end

    % --- The Geometric Heuristics ---
    
    % 1. Location constraint: The paddle is strictly at the bottom.
    is_at_bottom = centroid_y > 190 && centroid_y < 235; 
    
    % 2. Size constraint: Based on Area 28, with a wide buffer to 
    % accommodate the "Expand" (Enlarge) power-up later.
    is_right_size = area > 15 && area < 120;
    
    % 3. Shape constraint: Based on Aspect Ratio 3.0.
    % Capped at 8.0 to prevent a solid bottom UI line from triggering it.
    is_horizontal = aspect_ratio > 2.0 && aspect_ratio < 8.0;

    is_candidate = is_at_bottom && is_right_size && is_horizontal;
end
