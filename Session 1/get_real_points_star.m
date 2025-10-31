function [coords, ima_pattern] = get_real_points_star(width, display)
% GET_REAL_POINTS_STAR returns 10 manually chosen real-world 2D coordinates
% based on a star-shaped calibration pattern of size `width` (e.g., in mm).
% 
% INPUTS:
%   - width: real-world width of the star pattern (in mm or any unit)
%   - display: set to 1 to show pattern with point labels
%
% OUTPUTS:
%   - coords: [Nx2] real-world X, Y coordinates of selected points
%   - ima_pattern: the loaded and resized image of the pattern

% Normalized 2D coordinates (x, y in [0,1] range)
coords_normalized = [...
    0.5,         0.023333333;
    0,        0.387333333;
    0.381333333, 0.387333333;
    0.618666667, 0.387333333;
    1,           0.387333333;
    0.308,       0.611333333;
    0.692,       0.611333333;
    0.5,         0.75;
    0.19,        0.976666667;
    0.81,        0.976666667];

% Scale to physical dimensions (assuming square pattern of width x width)
coords = coords_normalized * width;


% Load and resize pattern image
ima_pattern = imread('star_pattern.png');
gray_image = rgb2gray(ima_pattern);
ima_big = imbinarize(gray_image);
ima_pattern = imresize(ima_big, [width, width]);


% Optional: display pattern with overlaid points
if display == 1
    figure; imshow(ima_big); hold on;
    
    % Convert real-world coordinates to image pixel space
    % assuming top-left (0,0), y increases downward
    pix_coords = coords_normalized * size(ima_big, 1);
    
    plot(pix_coords(:,1), pix_coords(:,2), 'r*', 'MarkerSize', 10);
    for i = 1:size(pix_coords, 1)
        text(pix_coords(i,1) + 0.02 * size(ima_big, 1), pix_coords(i,2), sprintf('%d', i), 'Color', [1 0 0]);
    end
    title('Selected Star Points and Their Index');
end

end
