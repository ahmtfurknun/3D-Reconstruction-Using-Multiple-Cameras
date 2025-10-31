clear; close all; clc; warning off;

%% PARAMETERS
for light = 1:3
    scenes = 1:4;
    
    imageDir = 'images/';
    paramSets = {
        struct('ContrastThreshold', 0.01, 'EdgeThreshold', 10, 'Sigma', 1.6),
        struct('ContrastThreshold', 0.03, 'EdgeThreshold', 10, 'Sigma', 1.6),
        struct('ContrastThreshold', 0.01, 'EdgeThreshold', 5,  'Sigma', 1.2),
        struct('ContrastThreshold', 0.02, 'EdgeThreshold', 15, 'Sigma', 2.0)
    };
    match_ratio = 0.5;
    output_file = sprintf('results_light%d.csv', light);
    
    %% Prepare CSV header
    header = {'Scene1','Scene2','ParamSet','#Matches','#Inliers_H','#Inliers_F',...
              'InlierRatio_H','InlierRatio_F','ReprojError_H', "meanSampson"};
    fid = fopen(output_file, 'w');
    fprintf(fid, '%s,', header{1:end-1});
    fprintf(fid, '%s\n', header{end});
    
    %% Loop over all combinations of image pairs
    for i = 1:length(scenes)-1
        j = i+1;
    
        % Build file names
        img1 = sprintf('%sscene%d_light%d.jpg', imageDir, scenes(i), light);
        img2 = sprintf('%sscene%d_light%d.jpg', imageDir, scenes(j), light);

        I1_rgb = imread(img1);
        I2_rgb = imread(img2);
        I1 = imrotate(rgb2gray(I1_rgb), -90);
        I2 = imrotate(rgb2gray(I2_rgb), -90);

        for p = 1:length(paramSets)
            param = paramSets{p};

            % DETECT SIFT KEYPOINTS
            points1 = detectSIFTFeatures(I1, 'ContrastThreshold', param.ContrastThreshold, ...
                'EdgeThreshold', param.EdgeThreshold, 'Sigma', param.Sigma);
            points2 = detectSIFTFeatures(I2, 'ContrastThreshold', param.ContrastThreshold, ...
                'EdgeThreshold', param.EdgeThreshold, 'Sigma', param.Sigma);

            [f1, v1] = extractFeatures(I1, points1);
            [f2, v2] = extractFeatures(I2, points2);

            indexPairs = matchFeatures(f1, f2, 'MaxRatio', match_ratio, 'Unique', true);
            m1 = v1(indexPairs(:,1));
            m2 = v2(indexPairs(:,2));
            num_matches = size(indexPairs, 1);

            % HOMOGRAPHY
            [tform, inlierIdxH] = estimateGeometricTransform2D(m1, m2, 'projective', ...
                'Confidence', 99.9, 'MaxNumTrials', 2000);
            inliersH = sum(inlierIdxH);
            ratioH = inliersH / max(num_matches,1);  % avoid division by zero

            % Reprojection error
            if inliersH > 0
                mp1 = m1(inlierIdxH).Location;
                mp2 = m2(inlierIdxH).Location;
                projPoints = transformPointsForward(tform, mp1);
                reprojErr = mean(vecnorm(projPoints - mp2, 2, 2));
            else
                reprojErr = NaN;
            end

            

            % FUNDAMENTAL
            [fMatrix, inliersF] = estimateFundamentalMatrix(m1, m2);
            inliersF_n = sum(inliersF);
            ratioF = inliersF_n / length(inliersF);

            errs = sampsonError(fMatrix, m1.Location, m2.Location);
            meanSampson = mean(errs);

            % Write results
            fprintf(fid, '%d,%d,%d,%d,%d,%d,%.4f,%.4f,%.4f,%.4f\n', ...
                scenes(i), scenes(j), p, num_matches, inliersH, inliersF_n, ...
                ratioH, ratioF, reprojErr, meanSampson);
        end
    end
    
    fclose(fid);
    fprintf('All results saved for light %d\n', light);
end
