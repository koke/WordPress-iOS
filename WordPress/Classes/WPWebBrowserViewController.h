//
//  WPWebBrowserViewController.h
//  WordPress
//
//  Created by Jorge Bernal on 8/15/13.
//  Copyright (c) 2013 WordPress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPWebBrowserViewController : UIViewController

@property (nonatomic, strong) NSURL *url;

- (id)initWithURL:(NSURL *)url;

@end
