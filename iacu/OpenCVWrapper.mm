//
//  OpenCVWrapper.m
//  iacu
//
//  Created by mac on 27/4/2018.
//  Copyright © 2018 lens. All rights reserved.
//

#import "OpenCVWrapper.h"

#include <dlib/image_processing.h>
#include <dlib/opencv.h>
#include <imgwarp/imgwarp_mls_similarity_acu.h>


@implementation OpenCVWrapper {
    dlib::shape_predictor landmarkDetector;
    std::vector<cv::Point2f> landmarks;
    std::vector<cv::Point> ref_landmarks;
    std::vector<cv::Point> ref_acupoints;
    std::vector<cv::Point2f> ref_landmarks_resized;
    std::vector<cv::Point2f> ref_acupoints_resized;
    std::vector<cv::Point2f> detected_acupoints;
    
    std::vector<int> acupoint_position;
    int ref_width;
    //ImgWarp_MLS_Similarity_acu image_warpper;
    
}


- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> landmarkDetector;
    
    
    
    ref_width = 800;
    NSString *ref_2d_acupoint = [[NSBundle mainBundle] pathForResource:@"ref_2d_acupoints" ofType:@"txt"];
    NSString *ref_2d_landmarks = [[NSBundle mainBundle] pathForResource:@"ref_2d_landmarks" ofType:@"txt"];
    std::ifstream f;
    int num,pa,pb;
    
    // read the ref acupoints from file
    f.open([ref_2d_acupoint UTF8String]);
    f >> num;
    for (int i=0;i<num;i++) {
        f >> pa >> pb;
        //std::cout << pa << "\t" << pb << "\n";
        ref_acupoints.push_back(cv::Point(pa, pb));
    }
    f.close();
    
    // read the ref landmarks from file
    f.open([ref_2d_landmarks UTF8String]);
    f >> num;
    for (int i=0;i<num;i++) {
        f >> pa >> pb;
        //std::cout << pa << "\t" << pb << "\n";
        ref_landmarks.push_back(cv::Point(pa, pb));
    }
    f.close();
    std::cout << "ref_acu below: \n";
    for(int i=0;i<ref_acupoints.size();i++) {
        std::cout << ref_acupoints[i] << "\n";
    }
    std::cout << "ref landmark below: \n";
    for(int i=0;i<ref_landmarks.size();i++) {
        std::cout << ref_landmarks[i] << "\n";
    }
}


- (UIImage *)filter:(UIImage *)image inRects:(NSArray<NSValue *> *)rects {
    landmarks.clear();
    ref_acupoints_resized.clear();
    ref_landmarks_resized.clear();
    detected_acupoints.clear();
    
    cv::Mat mat_img, gray_mat;
    UIImageToMat(image, mat_img, true);
    
    cv::cvtColor(mat_img, gray_mat, CV_BGR2GRAY);
    
    dlib::cv_image<uchar> img(gray_mat);
    
    // convert the face bounds list to dlib format
    std::vector<dlib::rectangle> convertedRectangles = [self convertCGRectValueArray:rects];
    
    // for every detected face
    for (unsigned long j = 0; j < convertedRectangles.size(); ++j)
    {
        dlib::rectangle oneFaceRect = convertedRectangles[j];
        
        // detect all landmarks
        dlib::full_object_detection shape = landmarkDetector(img, oneFaceRect);
        
        // and draw them into the image (samplebuffer)
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            cv::Point2f p(shape.part(k).x(), shape.part(k).y());
            landmarks.push_back(p);
            //cv::line(mat_img, p, p, cv::Scalar(0,255,255), 6);
        }
        
    }
    [self acu_prepare:gray_mat];

    detected_acupoints = detect(&gray_mat, landmarks, ref_landmarks_resized, ref_acupoints_resized);
    
    for (int i=0;i<detected_acupoints.size();i++) {
        std::cout << i+1  << ":" << detected_acupoints[i] << std::endl;
    }
    
    for(int i=0;i<acupoint_position.size();i++) {
        cv::line(mat_img, detected_acupoints[acupoint_position[i]], detected_acupoints[acupoint_position[i]], cv::Scalar(0,255,255), 7);
    }
    
    acupoint_position.clear();
    return MatToUIImage(mat_img);
}

- (void) passPosition: (int)pos {
    acupoint_position.push_back(pos);
}


- (std::vector<cv::Point2f>) resizePoints: (std::vector<cv::Point>)points factor:(float)scale_factor {
    std::vector<cv::Point2f> scaled_points;
    for (int i = 0; i < points.size(); i++) {
        cv::Point2f point((points[i].x * scale_factor), (points[i].y * scale_factor));
        scaled_points.push_back(point);
    }
    /*std::cout << "list the point: ";
    for (int i=0;i<scaled_points.size();i++) {
        std::cout << scaled_points[i] << "\n";
    }*/
    
    return scaled_points;
}

- (void)acu_prepare: (cv::Mat)frame{
    float scale_factor = (float) frame.rows / (float) ref_width;
    ref_landmarks_resized = [self resizePoints:ref_landmarks factor:scale_factor];
    ref_acupoints_resized = [self resizePoints:ref_acupoints factor:scale_factor];
}

/*- (std::vector<cv::Point2f>)de: (cv::Mat)frame detected_landmark:(std::vector<cv::Point2f>)detected_landmarks ref_landmark:(std::vector<cv::Point2f>)ref_landmarks ref_acupoint:(std::vector<cv::Point2f>)ref_acupoints {
    
    image_warpper.setAll(frame, detected_landmarks, ref_landmarks, frame.cols, frame.rows, ref_acupoints);
    for(int i=0;i<ref_acupoints.size();i++) {
        cv::Point2f acupoint;
        acupoint.x = (ref_acupoints[i].x + image_warpper.rDx(ref_acupoints[i].y, ref_acupoints[i].x));
        acupoint.y = (ref_acupoints[i].y + image_warpper.rDy(ref_acupoints[i].y, ref_acupoints[i].x));
        detected_acupoints.push_back(acupoint);
    }
}*/
template<typename T>
std::vector<cv::Point_<T>> detect(cv::Mat *frame,
                                  std::vector<cv::Point_<T>> &detected_landmarks,
                                  std::vector<cv::Point_<T>> &ref_landmarks,
                                  std::vector<cv::Point_<T>> &ref_acupoints) {
    ImgWarp_MLS_Similarity_acu image_warpper;
    image_warpper.alpha = 1;
    image_warpper.gridSize = 5;
    
    std::vector<cv::Point_<T>> points;
    image_warpper.setAll<T>(*frame, detected_landmarks, ref_landmarks,
                            frame->cols, frame->rows, ref_acupoints);
    points.reserve(ref_acupoints.size());
    for (int i = 0; i < ref_acupoints.size(); i++) {
        cv::Point2f acupoint;
        acupoint.x = (ref_acupoints[i].x +
                      image_warpper.rDx(ref_acupoints[i].y, ref_acupoints[i].x));
        acupoint.y = (ref_acupoints[i].y +
                      image_warpper.rDy(ref_acupoints[i].y, ref_acupoints[i].x));
        points.push_back(acupoint);
    }
    return points;
}


- (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects {
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect = [rectValue CGRectValue];
        long left = rect.origin.x;
        long top = rect.origin.y;
        long right = left + rect.size.width;
        long bottom = top + rect.size.height;
        dlib::rectangle dlibRect(left, top, right, bottom);
        
        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}










UIImage* MatToUIImage(const cv::Mat& image) {
    
    NSData *data = [NSData dataWithBytes:image.data
                                  length:image.step.p[0] * image.rows];
    
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Preserve alpha transparency, if exists
    bool alpha = image.channels() == 4;
    CGBitmapInfo bitmapInfo = (alpha ? kCGImageAlphaLast : kCGImageAlphaNone) | kCGBitmapByteOrderDefault;
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,
                                        image.rows,
                                        8 * image.elemSize1(),
                                        8 * image.elemSize(),
                                        image.step.p[0],
                                        colorSpace,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

void UIImageToMat(const UIImage* image,
                  cv::Mat& m, bool alphaExist) {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = CGImageGetWidth(image.CGImage), rows = CGImageGetHeight(image.CGImage);
    CGContextRef contextRef;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome)
    {
        m.create(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
        bitmapInfo = kCGImageAlphaNone;
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNone;
        else
            m = cv::Scalar(0);
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    else
    {
        m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNoneSkipLast |
            kCGBitmapByteOrderDefault;
        else
            m = cv::Scalar(0);
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows),
                       image.CGImage);
    CGContextRelease(contextRef);
}

@end
