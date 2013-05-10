//
// Created by Aaron Douglas on 5/9/13.
// Copyright (c) 2013 WordPress. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PostSettingsFeaturedImagePreviewViewController.h"


@implementation PostSettingsFeaturedImagePreviewViewController

- (id)initWithImage:(UIImage *)image removeCompletion:(void (^)())removeCompletion
{
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:image];
        _removeCompletion = removeCompletion;
        self.title = NSLocalizedString(@"Featured Image", @"");
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Remove", @"") style:UIBarButtonItemStyleDone target:self action:@selector(removeImage:)];
    self.navigationItem.rightBarButtonItem = removeButton;

    self.imageView.frame = self.view.bounds;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
}

- (void)removeImage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

    if (self.removeCompletion) {
        self.removeCompletion();
    }
}

@end