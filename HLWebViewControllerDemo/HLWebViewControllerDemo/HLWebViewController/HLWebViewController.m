//
//  HLWebViewController.m
//  PersonalTax
//
//  Created by cainiu on 2019/1/5.
//  Copyright © 2019 HL. All rights reserved.
//

#import "HLWebViewController.h"

#define kHLScreenW [UIScreen mainScreen].bounds.size.width
#define kHLScreenH [UIScreen mainScreen].bounds.size.height
#define kHLSafeAreaTopHeight (kHLScreenH == 812.0 ? 88 : 64)

#define kHLColorHexValueAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]
#define kHLColorHexValue(rgbValue) kHLColorHexValueAlpha(rgbValue,1.0)

@interface HLWebViewController ()

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIBarButtonItem *backButtonItem;

@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;

@property (nonatomic, strong) UIBarButtonItem *refreshButtonItem;

@property (nonatomic, assign) BOOL isEnablePop;

@property (nonatomic, assign, readwrite) NSInteger pageIndex;

@property (nonatomic, strong, readwrite) UIProgressView *progressView;

@property (nonatomic, weak) UIImageView *navLineView;

@property (nonatomic, assign) BOOL webViewLoadFinish;

@end

@implementation HLWebViewController

/**
 获取导航栏黑线(传navigationBar)
 */
- (UIImageView *)getNavigationLineImageViewUnder:(UIView *)view{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0){
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self getNavigationLineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (UIImageView *)navLineView{
    if (!_navLineView) {
        _navLineView = [self getNavigationLineImageViewUnder:self.navigationController.navigationBar];
    }
    return _navLineView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isDisablePopGesture) {
        self.isEnablePop = self.navigationController.interactivePopGestureRecognizer.isEnabled;
    }
    if (!self.isShowNavigationLineView) {
        self.navLineView.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isDisablePopGesture) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (!self.isShowNavigationLineView) {
        self.navLineView.hidden = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.isDisablePopGesture) {
        if (self.isEnablePop) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

- (UIButton *)backButton{
    if (!_backButton) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"HLWebViewController.bundle/hl_webview_navback.png"] forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, 0, 30, 40);
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backButton = backButton;
    }
    return _backButton;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"HLWebViewController.bundle/hl_webview_close.png"] forState:UIControlStateNormal];
        closeButton.frame = CGRectMake(0, 0, 30, 30);
        closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        closeButton.hidden = YES;
        _closeButton = closeButton;
    }
    return _closeButton;
}

- (UIButton *)refreshButton{
    if (!_refreshButton) {
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshButton setImage:[UIImage imageNamed:@"HLWebViewController.bundle/hl_webview_refresh.png"] forState:UIControlStateNormal];
        refreshButton.frame = CGRectMake(0, 0, 30, 30);
        [refreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
        _refreshButton = refreshButton;
    }
    return _refreshButton;
}

- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)initSubViews{
    [self initNavButton];
    [self initWebView];
    [self initProgressView];
    [self initObserVer];
}

- (void)initProgressView{
    if (self.isShowProgress) {
        self.progressView = [[UIProgressView alloc] init];
        self.progressView.progressTintColor = kHLColorHexValue(0x4ca0f6);
        self.progressView.trackTintColor = kHLColorHexValue(0xf2f2f2);
        [self.view addSubview:self.progressView];
        self.progressView.frame = CGRectMake(0, kHLSafeAreaTopHeight, kHLScreenW, 1.5);
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [self.progressView setProgress:0.1 animated:YES];
    }
}

- (void)initObserVer{
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)initNavButton{
    NSMutableArray *itemsArray = [NSMutableArray array];
    
    if (self.backButton.allTargets.count == 0) {
        [self.backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    [itemsArray addObject:self.backButtonItem];
    
    if (!self.disableCloseButton) {
        if (self.closeButton.allTargets.count == 0) {
            [self.closeButton addTarget:self action:@selector(disMissVc) forControlEvents:UIControlEventTouchUpInside];
        }
        self.closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
        [itemsArray addObject:self.closeButtonItem];
    }
    self.navigationItem.leftBarButtonItems = itemsArray;
    
    
    if (!self.disableRefreshButton) {
        self.refreshButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.refreshButton];
        self.navigationItem.rightBarButtonItem = self.refreshButtonItem;
    }
    
    if (self.navigationTitle && self.navigationTitle.length) {
        self.navigationItem.title = self.navigationTitle;
    }
}

- (void)initWebView{
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.bounds;
    if (self.requestUrl) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.requestUrl];
        [self.webView loadRequest:request];
    }else{
        NSLog(@"URL 错误");
    }
}


/**
 刷新
 */
- (void)refreshAction{
    if (self.webView.URL) {
        [self.webView reload];
    }else{
        if (self.requestUrl) {
            NSURLRequest *request = [NSURLRequest requestWithURL:self.requestUrl];
            [self.webView loadRequest:request];
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if (!navigationAction.targetFrame) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载网页时展示出progressView
    if (self.isShowProgress) {
        self.progressView.alpha = 1.0;
        [self.view bringSubviewToFront:self.progressView];
    }
}


//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.isShowProgress) {
        self.progressView.alpha = 0;
    }
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.pageIndex++;
    if (self.pageIndex >= 2 && !self.disableCloseButton) {
        self.closeButton.hidden = NO;
    }
    if (self.isShowProgress) {
        self.progressView.alpha = 0.0;
    }
    
    if (self.footerView) {
        self.webViewLoadFinish = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFooterViewLayout];
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && self.isShowProgress) {
        if (self.webView.estimatedProgress > 0.1) {
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        }else{
            if (self.progressView.progress < 0.1) {
                [self.progressView setProgress:0.1 animated:YES];
            }
        }
        if (self.webView.estimatedProgress >= 1) {
            [UIView animateWithDuration:0.3f
                                  delay:0.5f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.progressView.alpha = 0.0f;
                             }
                             completion:^(BOOL finished) {
                                 [self.progressView setProgress:0 animated:NO];
                             }];
        }else{
            self.progressView.alpha = 1.0;
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        if (![self.webView.title isEqualToString:self.title] && !self.navigationTitle) {
            self.navigationItem.title = self.webView.title;
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)backAction:(UIButton *)button{
    if (self.backButtonAction) {
        self.backButtonAction();
        return;
    }
    if (!self.disableGoBack && [self.webView canGoBack]) {
        if (self.pageIndex >= 2) {
            self.pageIndex--;
        }
        [self.webView goBack];
    }else{
        [self disMissVc];
    }
}

- (void)disMissVc{
    if (self.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    if (self.isShowProgress) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    [self.webView removeObserver:self forKeyPath:@"title"];
}


- (void)updateFooterViewLayout{
    
    if (!self.footerView || !self.webViewLoadFinish) {
        return;
    }
    if (![self.webView.scrollView.subviews containsObject:self.footerView]) {
        [self.webView.scrollView addSubview:self.footerView];
    }
    
    CGFloat footerHeight = self.footerView.bounds.size.height;
    NSString *js = [NSString stringWithFormat:@"\
                    var appendDiv = document.getElementById(\"HLFooterView\");\
                    if (appendDiv) {\
                    appendDiv.style.height = %@+\"px\";\
                    } else {\
                    var appendDiv = document.createElement(\"div\");\
                    appendDiv.setAttribute(\"id\",\"HLFooterView\");\
                    appendDiv.style.width=%@+\"px\";\
                    appendDiv.style.height=%@+\"px\";\
                    document.body.appendChild(appendDiv);\
                    }\
                    ", @(footerHeight), @(self.webView.scrollView.contentSize.width), @(footerHeight)];
    [self.webView evaluateJavaScript:js completionHandler:nil];
    
    [self.webView evaluateJavaScript:@"document.body.offsetHeight;"completionHandler:^(id _Nullable result,NSError *_Nullable error) {
        //获取页面高度
        if ([result floatValue] >= self.footerView.bounds.size.height) {
            CGRect frame = self.footerView.frame;
            frame.origin.y = [result floatValue] - self.footerView.bounds.size.height;
            self.footerView.frame = frame;
        }else{
            CGRect frame = self.footerView.frame;
            frame.origin.y = [result floatValue];
            self.footerView.frame = frame;
        }
    }];
}

@end
