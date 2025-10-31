clc; clear; close all; warning off;

descriptors = load("point_matches.mat").descriptors; %MAKE SURE TO ADD PROJECT FOLDER TO PATH
images = load("point_matches.mat").images; %MAKE SURE TO ADD PROJECT FOLDER TO PATH
keypoints = load("point_matches.mat").keypoints; %MAKE SURE TO ADD PROJECT FOLDER TO PATH
K = load('intrinsics.mat').intrinsics;

match_ratio = 0.5;

[q_data, sift_matches] = n_view_matching(keypoints, descriptors, images, match_ratio, 'SSD');
q_data = homogenize_coords(q_data);

q_2cams(:,:,1)=q_data(:,:,1); 
q_2cams(:,:,2)=q_data(:,:,4);

[F, P_2cam_est,Q_2cam_est,q_2cam_est] = MatFunProjectiveCalib(q_2cams);


figure; showMatchedFeatures(images{1}, images{4}, sift_matches{1}, sift_matches{4});
title('All SIFT matches');

disp(['Residual reprojection error. 8 point algorithm   = ' num2str( ErrorRetroproy(q_2cams,P_2cam_est,Q_2cam_est)/2 )]);
draw_reproj_error(q_2cams,P_2cam_est,Q_2cam_est);



%Resection
P_cams(:,:,:)=zeros(3,4,4);
P_cams(:,:,1)=P_2cam_est(:,:,1);
P_cams(:,:,4)=P_2cam_est(:,:,2);

for i= 2:3
    P_cams(:,:,i)=PDLT_NA(q_data(:,:,i),Q_2cam_est);
end

disp(['Residual reprojection error, After resectioning  = ' num2str( ErrorRetroproy(q_data,P_cams,Q_2cam_est)/2 )]);
draw_reproj_error(q_data,P_cams,Q_2cam_est); %q_data

%Projective Bundle Adjustment
npoints=size(q_data,2);
vp = ones(npoints,4);
[P_bundle,Q_bundle,q_bundle]=BAProjectiveCalib(q_data,P_cams,Q_2cam_est,vp);

disp(['Reprojection error, After Bundle Adjustment  = ' num2str( ErrorRetroproy(q_data,P_bundle,Q_bundle)/2 )]); %q_data
draw_reproj_error(q_data,P_bundle,Q_bundle);

% Obtain E from F and K
F_bundle=vgg_F_from_P({P_bundle(:,:,1),P_bundle(:,:,end)});

E = K' * F_bundle * K;

[R_est, T_est] = factorize_E(E);

% Initialize solution storage
Rcam = zeros(3,3,2,4);
Tcam = zeros(3,2,4);

% Fill the 4 possible (R,T) combinations
Rcam(:,:,1,:) = repmat(eye(3),1,1,4);
Rcam(:,:,2,1) = R_est(:,:,1); Tcam(:,2,1) = T_est;
Rcam(:,:,2,2) = R_est(:,:,1); Tcam(:,2,2) = -T_est;
Rcam(:,:,2,3) = R_est(:,:,2); Tcam(:,2,3) = T_est;
Rcam(:,:,2,4) = R_est(:,:,2); Tcam(:,2,4) = -T_est;

% Triangulate and choose the best solution
best_valid = 0;
for sol = 1:4
    R = Rcam(:,:,2,sol);
    T = Tcam(:,2,sol);
    Q = TriangEuc(R, T, cat(3, K, K), q_data(:,:,[1 4]));
    Q_cart = Q(1:3,:) ./ Q(4,:);

    % Cheirality check (depths > 0 in both cameras)
    temp = eye(3);
    Z1 = temp(3,:) * (Q_cart - zeros(3,1));
    Z2 = R(3,:) * (Q_cart - T);

    valid = (Z1 > 0) & (Z2 > 0);
    num_valid = sum(valid);
    
    if sol > best_valid
        best_valid = num_valid;
        Q_best = Q;
        R_best = R;
        T_best = T;
    end
end

% Build Euclidean projection matrices
P_euc = zeros(3,4,4);
P_euc(:,:,1) = K * [eye(3), zeros(3,1)];
P_euc(:,:,4) = K * [R_best, -R_best*T_best];

% Resection intermediate cameras
for i = 2:3
    P_euc(:,:,i) = PDLT_NA(q_data(:,:,i), Q_best);
end

% Compute final reprojection error
disp(['Reprojection error, After Euclidean Reconstruction  = ' num2str( ErrorRetroproy(q_data, P_euc, Q_best)/2 )]);
draw_reproj_error(q_data, P_euc, Q_best);

% Visualize cameras and structure
[K_euc, R_euc, C_euc] = CameraMatrix2KRC(P_euc);
figure;
draw_scene(Q_best, K_euc, R_euc, C_euc(1:3,:));



