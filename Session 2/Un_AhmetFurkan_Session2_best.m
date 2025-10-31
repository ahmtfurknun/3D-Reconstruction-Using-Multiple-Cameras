clear; close all; clc; warning off;

%% PARAMETERS
%scene: (1, 2, 3, 4)
%light: (1, 2, 3)
image1_path = 'images/scene2_light1.jpg';
image2_path = 'images/scene3_light1.jpg';

match_ratio = 0.5;
sift_params = struct( ...
'ContrastThreshold', 0.03, ...
'EdgeThreshold', 10, ...
'Sigma', 1.6);

%% READ & PREPROCESS IMAGES
I1_rgb = imrotate(imread(image1_path), -90);
I2_rgb = imrotate(imread(image2_path), -90);

I1 = rgb2gray(I1_rgb);
I2 = rgb2gray(I2_rgb);

%% DETECT SIFT KEYPOINTS
points1 = detectSIFTFeatures(I1, ...
'ContrastThreshold', sift_params.ContrastThreshold, ...
'EdgeThreshold', sift_params.EdgeThreshold, ...
'Sigma', sift_params.Sigma);

points2 = detectSIFTFeatures(I2, ...
'ContrastThreshold', sift_params.ContrastThreshold, ...
'EdgeThreshold', sift_params.EdgeThreshold, ...
'Sigma', sift_params.Sigma);

% Visualize keypoints
figure;
subplot(1,2,1); imshow(I1_rgb); hold on;
plot(points1.selectStrongest(100)); title('SIFT keypoints in Scene 2');

subplot(1,2,2); imshow(I2_rgb); hold on;
plot(points2.selectStrongest(100)); title('SIFT keypoints in Scene 3');

%% EXTRACT FEATURES
[features1, valid_points1] = extractFeatures(I1, points1);
[features2, valid_points2] = extractFeatures(I2, points2);

%% MATCH FEATURES
indexPairs = matchFeatures(features1, features2, ...
'MaxRatio', match_ratio, 'Unique', true);

matchedPoints1 = valid_points1(indexPairs(:,1));
matchedPoints2 = valid_points2(indexPairs(:,2));

%% HOMOGRAPHY ESTIMATION
[tform, inlierIdxH] = estimateGeometricTransform2D(...
matchedPoints1, matchedPoints2, 'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

inlierPoints1_H = matchedPoints1(inlierIdxH);
inlierPoints2_H = matchedPoints2(inlierIdxH);

warpedImage = imwarp(I1_rgb, tform, 'OutputView', imref2d(size(I2_rgb)));

disp(tform.T);

% Prepare montage
figure;
multi = cat(4, I1_rgb, I2_rgb, warpedImage, I2_rgb);
aa = montage(multi, 'Size', [2, 2]);
resultMontage = aa.CData;
disp = 20;
imshow(resultMontage); hold on;
text(disp, disp, 'Scene 2', 'Color', 'red', 'FontSize', 14);
text(disp + size(resultMontage,2)/2, disp, 'Scene 3', 'Color', 'red', 'FontSize', 14);
text(disp, disp + size(resultMontage,1)/2, 'Scene 2 warped to 3', 'Color', 'red', 'FontSize', 14);
text(disp + size(resultMontage,2)/2, disp + size(resultMontage,1)/2, ...
'Scene 3', 'Color', 'red', 'FontSize', 14);

%% FUNDAMENTAL MATRIX ESTIMATION
[fMatrix, inliersF] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2);

inlierPoints1_F = matchedPoints1(inliersF);
inlierPoints2_F = matchedPoints2(inliersF);

%% VISUALIZE MATCHES
figure; showMatchedFeatures(I1_rgb, I2_rgb, matchedPoints1, matchedPoints2);
title('All SIFT matches');

%% VGG GUI (OPTIONAL)
vgg_gui_F(I1_rgb, I2_rgb, fMatrix');

%% METRICS & STATS
num_matches = size(indexPairs, 1);
num_inliersF = sum(inliersF);
inlier_ratio = num_inliersF / num_matches;

% Compute reprojection error for homography inliers
projPoints1 = transformPointsForward(tform, inlierPoints1_H.Location);
errors = sqrt(sum((projPoints1 - inlierPoints2_H.Location).^2, 2));
mean_proj_error = mean(errors);

