# 3D Reconstruction using Multiple Cameras

This project implements a complete pipeline for 3D reconstruction from multiple 2D images, based on the principles of 3D computer vision. The process includes camera calibration, robust feature matching under various lighting conditions, and a full Structure from Motion (SfM) pipeline to generate a 3D point cloud.

This was a lab project for 3D Vision for Multiple or Moving Cameras course.

## Project Pipeline

The reconstruction pipeline is divided into three main stages:

### 1. Camera Calibration (Intrinsic Parameters)

Before reconstructing a scene, the intrinsic parameters of the camera must be obtained.

* **Method:** Zhang's calibration method was used.
* **Patterns:** Two different calibration patterns were evaluated:
    1.  A standard **checkerboard** displayed on a monitor.
    2.  A custom-designed **star pattern**.
* **Analysis:** The resulting intrinsic matrix `A` from both patterns was analyzed for focal length, principal point offset, and axis skew. The checkerboard results were found to be more consistent and were used for the final reconstruction.

### 2. Feature Detection and Matching Evaluation

A custom dataset was created to evaluate the robustness of feature matching under different conditions.

* **Scene:** A scene with four textured objects (toothpaste, calculator, matchbox, powerbank) was captured.
* **Dataset:** Images were captured from 4 different viewpoints under 3 distinct lighting conditions:
    1.  **Light 1:** Fully bright, minimal shadows.
    2.  **Light 2:** Strong directional side shadows.
    3.  **Light 3:** Low ambient light.
* **Evaluation:** The **SIFT** algorithm was used for feature detection and description. A total of 36 configurations (4 SIFT parameter sets x 3 view pairs x 3 lighting conditions) were evaluated.
* **Metrics:** Performance was measured by the number of matches, inlier counts (for Homography and Fundamental Matrix), reprojection error, and mean Sampson error .
* **Conclusion:** Parameter Set 2 under Light 1 (bright) provided the best balance of a high inlier count and low geometric error (Sampson error). This setup was chosen for the 3D reconstruction.

### 3. 3D Reconstruction (Structure from Motion)

Using the calibrated camera and the optimal matching setup, a 3D reconstruction was performed on the 4-view (Light 1) dataset.

1.  **N-View Matching:** SIFT features were extracted and matched across all four views to find consistent correspondences.
2.  **Initial Projective Calibration:** An initial two-view reconstruction was created using views 1 and 4. The Fundamental matrix was estimated, and points were triangulated, achieving a low mean reprojection error of 0.2662 pixels.
3.  **Resectioning:** The intermediate cameras (views 2 and 3) were added to the reconstruction by resectioning.
4.  **Projective Bundle Adjustment:** A projective bundle adjustment was run to refine the 3D point locations and all four camera projection matrices, improving the reprojection error from 35.31 to 22.58 pixels.
5.  **Euclidean Upgrade:** The reconstruction was upgraded from projective to Euclidean space. The Essential matrix was computed ($E = K^TFK$), and its factors were used with a cheirality check to find the correct rotation (R) and translation (t).

## Results

The final output is a Euclidean 3D point cloud of the scene and the estimated camera poses.

* **Completeness:** The reconstruction successfully captured 3 of the 4 objects (toothpaste, calculator, matchbox). The 4th object (powerbank) was missed entirely due to a lack of reliable, matched keypoints across the views.
* **Fidelity:** The pipeline successfully captured fine structural details, such as the thin, planar packaging of the calculator.
* **Error:** The final reprojection error after the Euclidean upgrade was high (190.5 pixels), indicating an accumulation of geometric errors, likely from small inaccuracies in matching or calibration [cite: 489, 543-547].

This project successfully demonstrates the full 3D reconstruction pipeline, from camera calibration to point cloud generation, and includes a rigorous analysis of the factors (lighting, parameters) that affect matching quality.
