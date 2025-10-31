function errs = sampsonError(F, pts1, pts2)
    % pts1, pts2: Nx2
    pts1_h = [pts1, ones(size(pts1,1),1)];
    pts2_h = [pts2, ones(size(pts2,1),1)];

    Fx1 = (F * pts1_h')';     % Nx3
    Ftx2 = (F' * pts2_h')';   % Nx3
    x2Fx1 = sum(pts2_h .* (F * pts1_h')', 2);

    errs = (x2Fx1.^2) ./ (Fx1(:,1).^2 + Fx1(:,2).^2 + Ftx2(:,1).^2 + Ftx2(:,2).^2);
end
