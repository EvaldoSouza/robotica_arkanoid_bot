function ball_mask = extract_white_ball(labeled_matrix)
    % Ball identification is based on geometry rather than brightness.
    % The segmentation stage is performed elsewhere so that other
    % detectors can reuse the same connected components.

    ball_mask = filter_ball_geometry(
        labeled_matrix
    );
end

function ball_mask = filter_ball_geometry( ...
    labeled_matrix
    )

    binary_mask = false(size(labeled_matrix));

    stats = regionprops(
        labeled_matrix,
        "Area",
        "Eccentricity"
    );

    for region_idx = 1:numel(stats)
        if is_ball_candidate(stats(region_idx))
            binary_mask |= (labeled_matrix == region_idx);
        end
    end

    ball_mask = uint8(binary_mask) * 255;
end

function is_candidate = is_ball_candidate(region_stats)
    % The ball is one of the smallest connected components and
    % remains approximately circular throughout the game.

    is_right_size = ...
        region_stats.Area >= 5 && ...
        region_stats.Area <= 15;

    is_circular = ...
        region_stats.Eccentricity < 0.55;

    is_candidate = ...
        is_right_size && ...
        is_circular;
end
