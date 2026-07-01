function centroid = extract_centroid(binary_mask)
    % Extracts the [X, Y] centroid coordinates from a binary mask.
    %
    % Usage:
    %   pos = extract_centroid(paddle_mask);

    centroid = [];
    if ~islogical(binary_mask) && ~isnumeric(binary_mask)
        error("TypeError: binary_mask must be logical or numeric.");
    end

    % STREAMING_CHUNK: Processing logical boundaries...
    logical_mask = binary_mask > 0;
    stats = regionprops(logical_mask, "Centroid");

    if ~isempty(stats)
        % Default to the first detected object
        centroid = stats(1).Centroid;
        
        % --- NEW: Multi-Ball Targeting ---
        % If there are multiple objects (e.g., 3 balls), always lock 
        % onto the "most dangerous" one (lowest on the screen/Max Y).
        max_y = centroid(2);
        for i = 2:numel(stats)
            if stats(i).Centroid(2) > max_y
                max_y = stats(i).Centroid(2);
                centroid = stats(i).Centroid;
            end
        end
    end
end
