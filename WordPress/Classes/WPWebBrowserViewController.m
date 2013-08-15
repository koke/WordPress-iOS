//
//  WPWebBrowserViewController.m
//  WordPress
//
//  Created by Jorge Bernal on 8/15/13.
//  Copyright (c) 2013 WordPress. All rights reserved.
//

#import "WPWebBrowserViewController.h"
#import "WordPressAppDelegate.h"
#import "WPActivityDefaults.h"
#import "WPMobileStats.h"

@interface WPWebBrowserViewController () <UIWebViewDelegate>

@end

@implementation WPWebBrowserViewController {
    UIWebView *_webView;
    UIBarButtonItem *_backButton;
    UIBarButtonItem *_forwardButton;
    UIBarButtonItem *_reloadButton;
    UIBarButtonItem *_stopButton;
    UIBarButtonItem *_shareButton;
    UIActivityIndicatorView *_activityIndicator;
    BOOL _webViewHasLoadedURL;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (void)loadView
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.delegate = self;
    self.view = _webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupButtons];

    if (_url) {
        [self loadURL:_url];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)setupButtons
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];

    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    _forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    _reloadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync"] style:UIBarButtonItemStylePlain target:self action:@selector(reload:)];
    _stopButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_unapprove"] style:UIBarButtonItemStylePlain target:self action:@selector(stop:)];
    _shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];

    UIColor *tintColor = [UIColor UIColorFromHex:0x464646];
    _backButton.tintColor = tintColor;
    _forwardButton.tintColor = tintColor;
    _reloadButton.tintColor = tintColor;
    _stopButton.tintColor = tintColor;

    [self updateToolbarItems];
}

- (void)updateToolbarItems
{
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 10.f;

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:7];

    _backButton.enabled = _webView.canGoBack;
    [toolbarItems addObject:_backButton];

    [toolbarItems addObject:fixedSpace];

    _forwardButton.enabled = _webView.canGoForward;
    [toolbarItems addObject:_forwardButton];

    [toolbarItems addObject:fixedSpace];

    if (_webView.isLoading) {
        [toolbarItems addObject:_stopButton];
    } else {
        [toolbarItems addObject:_reloadButton];
    }

    if (NSClassFromString(@"UIActivity") != nil && [self webURL]) {
        [toolbarItems addObject:flexibleSpace];

        _shareButton.enabled = !_webView.isLoading;
        [toolbarItems addObject:_shareButton];
    }

    self.toolbarItems = [NSArray arrayWithArray:toolbarItems];
}

- (void)loadURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[[WordPressAppDelegate sharedWordPressApplicationDelegate] applicationUserAgent] forHTTPHeaderField:@"User-Agent"];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];

    [_webView loadRequest:request];
    self.title = [url absoluteString];
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self loadURL:url];
}

#pragma mark - Button actions

- (void)goBack:(id)sender
{
    [_webView goBack];
}

- (void)goForward:(id)sender
{
    [_webView goForward];
}

- (void)reload:(id)sender
{
    if (_webViewHasLoadedURL) {
        [_webView reload];
    } else {
        [self loadURL:_url];
    }
}

- (void)stop:(id)sender
{
    [_webView stopLoading];
}

- (void)share:(id)sender
{
    [WPMobileStats trackEventForWPCom:[NSString stringWithFormat:@"WebBrowser - %@", StatsEventWebviewClickedShowLinkOptions]];
    NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:2];
    NSString *title = [self webTitle];
    if (title) {
        [activityItems addObject:title];
    }

    [activityItems addObject:[self webURL]];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:[WPActivityDefaults defaultActivities]];
    if (title) {
        [activityViewController setValue:title forKey:@"subject"];
    }
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (!completed)
            return;
        [WPActivityDefaults trackActivityType:activityType withPrefix:@"WebBrowser"];
    };
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Helper methods

- (NSString *)webTitle
{
    NSString *title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([title length]) {
        return title;
    } else {
        return nil;
    }
}

- (NSURL *)webURL
{
    if (_webViewHasLoadedURL) {
        return _webView.request.URL;
    } else {
        return _url;
    }
}

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    WPFLogMethodParam(request);

    // Some things like facebook/twitter widgets will trigger this method with the wrong navigation type
    // Only change the title when web view isn't loading as a result of user navigation
    if (navigationType != UIWebViewNavigationTypeOther && !_webView.isLoading) {
        self.title = [request.URL absoluteString];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    WPFLogMethod();
    [_activityIndicator startAnimating];
    [self updateToolbarItems];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    WPFLogMethod();
    _webViewHasLoadedURL = YES;
    [_activityIndicator stopAnimating];

    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([title length]) {
        self.title = title;
    }
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    WPFLogMethodParam(error);
    [_activityIndicator stopAnimating];
    [self updateToolbarItems];
}

@end
