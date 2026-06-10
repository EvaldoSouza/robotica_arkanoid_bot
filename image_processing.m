function labeled_matrix = build_bright_component_map(img, threshold)
    % Produces connected bright regions that can be consumed by
    % multiple detectors. Keeping segmentation centralized ensures
    % ball and paddle detectors reason about the same scene.

    gray_img = ensure_grayscale(img);
    bright_mask = segment_bright_pixels(gray_img, threshold);

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
end
