function paddle_mask = extract_paddle(labeled_matrix)
    % Extracts the Arkanoid paddle based on geometric constraints.
    % Relies on the same connected components used by the ball detector.

    stats = regionprops(labeled_matrix, "Area", "BoundingBox", "Centroid");

    persistent prev_centroid;

    if isempty(prev_centroid)
        prev_centroid = [];
    end

    best_idx = -1;
    best_dist = Inf;

    for i = 1:numel(stats)
        if is_paddle_candidate(stats(i))

            if isempty(prev_centroid)
                dist = 0;
            else
                dist = norm(stats(i).Centroid - prev_centroid);
            end

            if dist < best_dist
                best_dist = dist;
                best_idx = i;
            end

        end
    end

    if best_idx ~= -1
        paddle_mask = uint8(ismember(labeled_matrix, best_idx)) * 255;
        prev_centroid = stats(best_idx).Centroid;
    else
        paddle_mask = uint8(zeros(size(labeled_matrix)));
    end
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

%vec norm pra verificar o centro em relação a posição anterior para evitar perder o paddle ou pegar o cinza do paddle ao invés do branco
%identificar os oponentes 
%q learning é pra aprender a jogar como pro
%pontuar por acertar as bolinhas,  
