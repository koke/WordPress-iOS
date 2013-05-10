//
// Created by Aaron Douglas on 5/9/13.
// Copyright (c) 2013 WordPress. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PostSettingsFeaturedImagePreviewViewController : UIViewController

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) void (^removeCompletion)();

- (id)initWithImage:(UIImage *)image removeCompletion:(void (^)())removeCompletion;

@end