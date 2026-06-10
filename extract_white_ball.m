function mask = extract_white_ball(img)
    % EXTRACT_WHITE_BALL Isolates a small white circular object from an image.
    % Input: 'img' - An RGB or grayscale image.
    % Output: 'mask' - A uint8 image of the same size (black background, white ball).

    % 2. Convert to grayscale if the input is an RGB image
    if (size(img, 3) == 3)
        gray_img = rgb2gray(img);
    else
        gray_img = img;
    endif

    % 3. Threshold the image to isolate bright objects (adjust 0.8 if needed)
    bw = im2bw(gray_img, 0.8);

    % 4. Label distinct connected components
    [L, num] = bwlabel(bw);

    % 5. Extract geometric properties of each object
    stats = regionprops(L, 'Area', 'Eccentricity');

    % 6. Initialize an empty binary mask (all black)
    binary_mask = false(size(gray_img));

    % 7. Loop through objects and filter for the small round ball
    for i = 1:num
        % --- TWEAK THESE PARAMETERS IF NEEDED ---
        % Area: Approximate number of pixels the ball occupies
        is_right_size = (stats(i).Area >= 5 && stats(i).Area <= 15); 
        
        % Eccentricity: 0 is a perfect circle, 1 is a line. 
        is_circular = (stats(i).Eccentricity < 0.55); 
        % ----------------------------------------

        % If the object matches both criteria, keep it
        if is_right_size && is_circular
            binary_mask = binary_mask | (L == i);
        end
    endfor

    % 8. Convert the logical mask (0 or 1) to a standard uint8 image (0 or 255)
    mask = uint8(binary_mask) * 255;
endfunction
