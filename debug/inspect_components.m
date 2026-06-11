function inspect_components(frame_img, labeled_matrix)
    % Displays the image and overlays bounding boxes for all components
    % Prints Area, BoundingBox, Width, Height, Aspect Ratio, and Centroid

    % Extract properties using the image package
    stats = regionprops(labeled_matrix, "Area", "BoundingBox", "Centroid");

    % Prepare the figure
    imshow(frame_img);
    hold on;

    fprintf("\n--- Component Inspection Report ---\n");

    for i = 1:numel(stats)
        % BoundingBox format: [x, y, width, height]
        bbox = stats(i).BoundingBox; 
        area = stats(i).Area;
        centroid = stats(i).Centroid;

        width = bbox(3);
        height = bbox(4);
        
        % Prevent division by zero just in case
        if height > 0
            aspect_ratio = width / height;
        else
            aspect_ratio = 0;
        end

        % Draw a red bounding box around the component
        rectangle("Position", bbox, "EdgeColor", "r", "LineWidth", 1.5);
        
        % Draw a small marker at the centroid
        plot(centroid(1), centroid(2), "r+", "MarkerSize", 5);

        % Print statistics to the Octave console
        fprintf("Component %d:\n", i);
        fprintf("  Area:         %d\n", area);
        fprintf("  BoundingBox:  [X: %.1f, Y: %.1f, W: %.1f, H: %.1f]\n", bbox(1), bbox(2), width, height);
        fprintf("  Aspect Ratio: %.2f (W/H)\n", aspect_ratio);
        fprintf("  Centroid:     [X: %.1f, Y: %.1f]\n", centroid(1), centroid(2));
        fprintf("-----------------------------------\n");
    end

    hold off;
    drawnow;
    
    % Pause briefly to allow you to read the console and view the frame
    pause(0.5); 
end
