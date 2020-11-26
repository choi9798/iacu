//
//  DlibWrapper.h
//  iacu
//
//  Created by mac on 11/5/2018.
//  Copyright © 2018 lens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface DlibWrapper : NSObject

- (instancetype)init;
- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects;
- (void)prepare;

@end

