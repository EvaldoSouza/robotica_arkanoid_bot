function mask = extract_white_ball(img)
    % EXTRACT_WHITE_BALL Isolates a small white circular object from an image.
    % Example: mask = extract_white_ball(imread('frame.jpg'));

    gray_img = ensure_grayscale(img);
    bw = segment_bright_pixels(gray_img, 0.8);
    [labeled_matrix, num_objects] = bwlabel(bw);
    
    mask = filter_objects_by_geometry(labeled_matrix, num_objects, size(gray_img));
end

function gray_img = ensure_grayscale(img)
    % Converts input to grayscale if RGB.
    if (size(img, 3) == 3)
        gray_img = rgb2gray(img);
        return;
    end
    gray_img = img;
end

function bw = segment_bright_pixels(gray_img, threshold)
    % Thresholds image to isolate high-intensity pixels.
    % Using imbinarize as im2bw is deprecated in newer versions.
    bw = imbinarize(gray_img, threshold);
end

function mask = filter_objects_by_geometry(labeled_matrix, num_objects, img_size)
    % Filters components based on size and circularity.
    binary_mask = false(img_size);
    stats = regionprops(labeled_matrix, 'Area', 'Eccentricity');

    for i = 1:num_objects
        if is_target_object(stats(i))
            binary_mask = binary_mask | (labeled_matrix == i);
        end
    end
    
    mask = uint8(binary_mask) * 255;
end

function is_target = is_target_object(stats)
    % Defines target geometry. 
    % Area (5-15 pixels) and Eccentricity (< 0.55) for circularity.
    is_right_size = (stats.Area >= 5 && stats.Area <= 15);
    is_circular = (stats.Eccentricity < 0.55);
    
    is_target = is_right_size && is_circular;
end
