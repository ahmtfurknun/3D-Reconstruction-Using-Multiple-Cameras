clear; close all; clc; warning off;

T = readtable('results_light3.csv');


% Compute mean inlier ratio and other stats per parameter set
for p = 1:4
    rows = T.ParamSet == p;
    avgNumMatches = mean(T.x_Matches(rows));
    avgNumInliersF = mean(T.x_Inliers_F(rows));
    meanReprojError = mean(T.ReprojError_H(rows), 'omitnan');
    meanSampson = mean(T.meanSampson(rows), 'omitnan');

    fprintf('Param %d | Average Matches: %.3f | Average Inliers: %.3f | ReprojErrorH: %.3f | SampsonError: %.3f\n', ...
        p, avgNumMatches, avgNumInliersF, meanReprojError, meanSampson);
end
