#ifndef IMGTRANS_MLS_H
#define IMGTRANS_MLS_H

#include <vector>
#include <opencv2/core/core.hpp>

using std::vector;

using cv::Mat;
using cv::Mat_;
using cv::Point_;
using cv::Point;

//! The base class for Moving Least Square image warping.
/*!
 * Choose one of the subclasses, the easiest interface to generate
 * an output is to use setAllAndGenerate function.
 */
class ImgWarp_MLS {
   public:
    //ImgWarp_MLS();
    virtual ~ImgWarp_MLS() {}

    //! Set all and generate an output.
    /*!
      \param oriImg the image to be warped.
      \param qsrc A list of "from" points.
      \param qdst A list of "target" points.
      \param outW The width of the output image.
      \param outH The height of the output image.
      \param transRatio 1 means warp to target points, 0 means no warping

      This will do all the initialization and generate a warped image.
      After calling this, one can later call genNewImg with different
      transRatios to generate a warping animation.
    */
    template<typename T>
    Mat setAllAndGenerate(const Mat &oriImg, const vector<Point_<T> > &qsrc,
                          const vector<Point_<T> > &qdst, const int outW,
                          const int outH, const double transRatio = 1) {
        setSize(oriImg.cols, oriImg.rows);
        setTargetSize(outW, outH);
        setSrcPoints<T>(qsrc);
        setDstPoints<T>(qdst);
        calcDelta();
        return genNewImg(oriImg, transRatio);
    }

    //! Generate the warped image.
    /*! This function generate a warped image using PRE-CALCULATED data.
     *  DO NOT CALL THIS AT FIRST! Call this after at least one call of
     *  setAllAndGenerate.
     */
    Mat genNewImg(const Mat &oriImg, double transRatio);

    //! Calculate delta value which will be used for generating the warped
    //image.
    virtual void calcDelta() = 0;

    //! Parameter for MLS.
    double alpha;

    //! Parameter for MLS.
    int gridSize;

    //! Set the list of target points
    template<typename T>
    void setDstPoints(const vector<Point_<T> > &qdst) {
        nPoint = qdst.size();
        oldDotL.clear();
        oldDotL.reserve(nPoint);

        for (size_t i = 0; i < qdst.size(); i++) oldDotL.push_back(qdst[i]);
    }

    //! Set the list of source points
    template<typename T>
    void setSrcPoints(const vector<Point_<T> > &qsrc) {
        nPoint = qsrc.size();

        newDotL.clear();
        newDotL.reserve(nPoint);

        for (size_t i = 0; i < qsrc.size(); i++) newDotL.push_back(qsrc[i]);
    }

    //! The size of the original image. For precalculation.
    void setSize(int w, int h) { srcW = w, srcH = h; }

    //! The size of output image
    void setTargetSize(const int outW, const int outH) {
        tarW = outW;
        tarH = outH;
    }

    Mat_<double> /*! \brief delta_x */ rDx, /*! \brief delta_y */ rDy;

   protected:
    vector<Point_<double> > oldDotL, newDotL;

    int nPoint;
    int srcW, srcH;
    int tarW, tarH;
};

#endif  // IMGTRANS_MLS_H
