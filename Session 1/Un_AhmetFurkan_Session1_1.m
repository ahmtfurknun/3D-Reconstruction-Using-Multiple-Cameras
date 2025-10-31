clc;
close all;
clear;
warning off;

%% Parameters
numPoints = 9;              % Number of checkerboard points
numImages = 7;              % Number of images
checkerboardWidth = 150;    % Physical width of pattern image
useSavedPoints = true;      % Set to false to manually reselect points

%% Generate real-world coordinates
[worldCoords, checkerPattern] = get_real_points_checkerboard_vmmc(numPoints, checkerboardWidth, 1);
pause(1)

%% Read and rotate images
imageList = cell(1, numImages);
for i = 1:numImages
    imagePath = sprintf('images/checkerboard%d_3472x3472.jpg', i);
    imageList{i} = imrotate(imread(imagePath), -90);
end

%% Get or Load User Points
if useSavedPoints
    load('all_points1.mat', 'pointList');
else
    pointList = cell(1, numImages);
    for i = 1:numImages
        pointList{i} = get_user_points_vmmc(imageList{i});
        pause(1)
    end
    save('all_points1.mat', 'pointList');
end

%% Compute Homographies
figure;
sgtitle("Homography with Zhang's Method");
set(gcf, 'WindowState', 'maximized');

homographyList = cell(1, numImages);

for i = 1:numImages
    currentPoints = pointList{i}(:, 1:numPoints);
    H_init = homography_solve_vmmc(worldCoords', currentPoints);
    [H_refined, ~] = homography_refine_vmmc(worldCoords', currentPoints, H_init);
    homographyList{i} = H_refined;

    % Transform image
    tform = maketform('projective', H_refined');
    transformedPattern = imtransform(checkerPattern, tform,'XData', [1 size(imageList{i}, 2)], 'YData', [1 size(imageList{i}, 1)]);

    % Display original and warped images
    subplot(2, numPoints, i);
    imshow(imageList{i});
    title(sprintf("Image %d", i));

    subplot(2, numPoints, i + numPoints);
    imshow(transformedPattern);
    title("Warped Pattern");
end

%% Compute Internal Parameters
intrinsics = internal_parameters_solve_vmmc(homographyList);
[m, n] = size(intrinsics);
%save("intrinsics.mat", "intrinsics")

disp("Internal Parameters Matrix: ");
for i = 1:m
    for j = 1:n
        fprintf('%f     ',intrinsics(i, j));
    end
    fprintf('\n');
end
