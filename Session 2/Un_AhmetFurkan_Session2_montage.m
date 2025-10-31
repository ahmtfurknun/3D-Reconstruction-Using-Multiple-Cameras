% Parameters
num_views = 4;
num_lights = 3;
img_height = 240; % Adjust as needed
img_width = 240;  % Adjust as needed

% Create figure
figure('Color', 'w');
tiledlayout(num_lights, num_views, 'TileSpacing', 'none', 'Padding', 'compact');

% Loop to load, process, and plot images with labels
for light = 1:num_lights
    for view = 1:num_views
        % Read and process image
        fname = sprintf('images/scene%d_light%d.jpg', view, light);
        I_rgb = imread(fname);
        I_gray = imrotate(I_rgb, -90);
        I_gray = imresize(I_gray, [img_height img_width]);

        % Add subplot
        nexttile;
        imshow(I_gray);
        title(sprintf('Scene %d | Light %d', view, light), 'FontSize', 10);
        axis off;
    end
end

sgtitle('Montage of All Captured Images with Labels', 'FontSize', 14);
