//
//  OpenCVWrapper.h
//  iacu
//
//  Created by mac on 27/4/2018.
//  Copyright © 2018 lens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>


@interface OpenCVWrapper : NSObject

- (void)prepare;
- (UIImage *)filter:(UIImage *)image inRects:(NSArray<NSValue *> *)rects;
- (void) passPosition: (int)pos;

@end
