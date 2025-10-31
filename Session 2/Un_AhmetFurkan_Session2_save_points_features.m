clear; close all; clc; warning off;

%% PARAMETERS
light = 1;  % Choose lighting condition
scene_ids = 1:4;  % Assumes images named scene1_light1.jpg, ..., scene4_light1.jpg

match_ratio = 0.5;
sift_params = struct( ...
    'ContrastThreshold', 0.03, ...
    'EdgeThreshold', 10, ...
    'Sigma', 1.6);

%% INIT STORAGE
num_views = numel(scene_ids);
images = cell(1, num_views);
keypoints = cell(1, num_views);
descriptors = cell(1, num_views);
pair_metrics = [];

%% READ IMAGES AND EXTRACT FEATURES
for i = 1:num_views
    fname = sprintf('images/scene%d_light%d.jpg', scene_ids(i), light);
    I_rgb = imread(fname);
    I = imrotate(rgb2gray(I_rgb), -90);

    % Store image
    images{i} = I;

    % Detect SIFT
    points = detectSIFTFeatures(I, ...
        'ContrastThreshold', sift_params.ContrastThreshold, ...
        'EdgeThreshold', sift_params.EdgeThreshold, ...
        'Sigma', sift_params.Sigma);

    % Extract features
    [features, valid_points] = extractFeatures(I, points);

    keypoints{i} = valid_points;
    descriptors{i} = features;
end

%% PROCESS CONSECUTIVE PAIRS
for i = 1:num_views-1
    I1 = images{i};
    I2 = images{i+1};

    features1 = descriptors{i};
    features2 = descriptors{i+1};
    points1 = keypoints{i};
    points2 = keypoints{i+1};

    %save('point_matches.mat', 'keypoints', 'descriptors', 'images');
end
