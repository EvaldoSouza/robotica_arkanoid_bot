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
        centroid = stats(1).Centroid;
    end

end
