#ifndef ACUPOINTDECTER2D_H
#define ACUPOINTDECTER2D_H

#include <fstream>
#include <imgwarp/imgwarp_mls_similarity_acu.h>
#include <dlib/opencv.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>

#define ACUPOINTS_2D_LOAD_ERROR "Error loading landmarks/acupoints file"

class AcupointDetector2D {

private:
    ImgWarp_MLS_Similarity_acu image_warpper;

    std::vector<cv::Point> ref_landmarks;
    std::vector<cv::Point> ref_acupoints;

    int ref_width;

    std::vector<cv::Point> loadPoints(std::string &path) {
        std::vector<cv::Point> points;
        std::ifstream f;
        int num, pa, pb;
        f.open(path);
        f >> num;
        for (int i = 0; i < num; i++) {
            f >> pa >> pb;
            points.push_back(cv::Point(pa, pb));
        }
        f.close();
        return points;
    }

    std::vector<cv::Point2f> resizePoints(std::vector<cv::Point> &points, float scale_factor) {
        std::vector<cv::Point2f> scaled_points;
        for (int i = 0; i < points.size(); i++) {
            cv::Point2f point(
                    (points[i].x * scale_factor),
                    (points[i].y * scale_factor)
            );
            scaled_points.push_back(point);
        }
        return scaled_points;
    }

public:
    std::vector<cv::Point2f> ref_landmarks_resized;
    std::vector<cv::Point2f> ref_acupoints_resized;

    AcupointDetector2D() {
        image_warpper.alpha = 1;
        // grid size does not matter
        image_warpper.gridSize = 5;
    }

    void load(std::string landmarks_path, std::string reference_acupoints_path, int ref_width) {
        this->ref_width = ref_width;
        ref_landmarks = loadPoints(landmarks_path);
        ref_acupoints = loadPoints(reference_acupoints_path);
        if (ref_landmarks.size() == 0 || ref_acupoints.size() == 0)
            throw ACUPOINTS_2D_LOAD_ERROR;
    }

    void load(std::string landmarks_path, std::string reference_acupoints_path) {
        load(landmarks_path, reference_acupoints_path, 800);
    }

    void prepare(cv::Mat *frame) {
        float scale_factor = (float) frame->rows / (float) ref_width; // TODO remove hard-coded size
        ref_landmarks_resized = resizePoints(ref_landmarks, scale_factor);
        ref_acupoints_resized = resizePoints(ref_acupoints, scale_factor);
    }

    void reset() {

    }

    template<typename T>
    std::vector<Point_<T>> detect(cv::Mat *frame,
                                  std::vector<Point_<T>> &detected_landmarks,
                                  std::vector<Point_<T>> &ref_landmarks,
                                  std::vector<Point_<T>> &ref_acupoints) {

        std::vector<cv::Point_<T>> detected_acupoints;
        image_warpper.setAll<T>(*frame, detected_landmarks, ref_landmarks,
                                frame->cols, frame->rows, ref_acupoints);
        detected_acupoints.reserve(ref_acupoints.size());
        for (int i = 0; i < ref_acupoints.size(); i++) {
            cv::Point2f acupoint;
            acupoint.x = (ref_acupoints[i].x +
                          image_warpper.rDx(ref_acupoints[i].y, ref_acupoints[i].x));
            acupoint.y = (ref_acupoints[i].y +
                          image_warpper.rDy(ref_acupoints[i].y, ref_acupoints[i].x));
            detected_acupoints.push_back(acupoint);
        }
        return detected_acupoints;
    }

    template<typename T>
    std::vector<Point_<T>> detect(cv::Mat *frame, dlib::full_object_detection &d) {
        return detect<T>(frame, d, ref_landmarks_resized, ref_acupoints_resized);
    }

    template<typename T>
    std::vector<Point_<T>> detect(cv::Mat *frame, std::vector<cv::Point_<T>> landmarks) {
        return detect<T>(frame, landmarks, ref_landmarks_resized, ref_acupoints_resized);
    }

    template<typename T>
    std::vector<Point_<T>> detect(cv::Mat *frame, dlib::full_object_detection &d,
                                  std::vector<Point_<T>> &ref_landmarks,
                                  std::vector<Point_<T>> &ref_acupoints) {
        std::vector<cv::Point2f> points;
        for (unsigned int i = 0; i < 68; i++) {
            cv::Point p(d.part(i).x(), d.part(i).y());
            points.push_back(p);
        }
        return detect<T>(frame, points, ref_landmarks, ref_acupoints);
    }
};

#endif
