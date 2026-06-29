function labeled_matrix = build_bright_component_map(img, threshold, apply_closing)
    % Produces connected bright regions that can be consumed by
    % multiple detectors. Keeping segmentation centralized ensures
    % ball and paddle detectors reason about the same scene.

    % Default to false if the argument is not provided (e.g., for the ball)
    if nargin < 3
        apply_closing = false;
    end

    gray_img = ensure_grayscale(img);
    bright_mask = segment_bright_pixels(gray_img, threshold);

    % --- NEW: Morphological Closing ---
    % If requested, sweep a horizontal brush over the binary image to 
    % connect adjacent blobs (like the broken extremities of the paddle).
    if apply_closing
        % Create a horizontal structural element (1 pixel high, 12 pixels wide)
        % This bridges horizontal gaps without merging vertical noise.
        se = strel('rectangle', [1, 10]);
        bright_mask = imclose(bright_mask, se);
    end

    [labeled_matrix, ~] = bwlabel(bright_mask);
end

function gray_img = ensure_grayscale(img)
    % Downstream detectors should not care whether the frame source
    % is RGB or grayscale.

    if size(img, 3) == 3
        gray_img = rgb2gray(img);
        return;
    end

    gray_img = img;
end

function bright_mask = segment_bright_pixels(gray_img, threshold)
    % Bright object segmentation is shared by ball and paddle detection.
    % Keeping the thresholding logic in one place prevents detectors
    % from drifting apart over time.

    bright_mask = imbinarize(gray_img, threshold);
    % The NES Arkanoid left and right walls are ~16 pixels wide.
    % Because they are grey, they can survive the paddle's 0.5 threshold.
    % By forcing the literal edges of the screen to black, we prevent the 
    % paddle from merging with the walls when it moves to the extremes.
    bright_mask(:, 1:18) = 0;
    bright_mask(:, 191:end) = 0;
end
