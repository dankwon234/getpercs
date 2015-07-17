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
+ (UIImage *)screenshot:(UIView *)view;
- (UIImage *)applyBlurOnImage:(CGFloat)blurRadius;
- (UIImage *)convertImageToGrayScale;
- (UIImage *)reflectedImage:(UIImage *)fromImage withBounds:(CGRect)bounds withHeight:(NSInteger)height;
@end
