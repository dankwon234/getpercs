//
//  UIImage+PQImageEffects.h
//  Perq
//
//  Created by Dan Kwon on 8/3/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PQImageEffects)

+ (UIImage *)crop:(UIImage *)originalImage rect:(CGRect)cropRect;
- (UIImage *)applyBlurOnImage:(CGFloat)blurRadius;
- (UIImage *)convertImageToGrayScale;
@end
