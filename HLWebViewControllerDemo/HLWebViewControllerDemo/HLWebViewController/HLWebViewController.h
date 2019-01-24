//
//  HLWebViewController.h
//  PersonalTax
//
//  Created by cainiu on 2019/1/5.
//  Copyright © 2019 HL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLWebViewController : UIViewController<WKNavigationDelegate>

@property (nonatomic, readonly) WKWebView *webView;
/** 进度条 */
@property (nonatomic, readonly) UIProgressView *progressView;
/** 当前加载页数 */
@property (nonatomic, readonly) NSInteger pageIndex;
/** 请求链接 */
@property (nonatomic, strong) NSURL *requestUrl;
/** 返回or回退 */
@property (nonatomic, strong) UIButton *backButton;
/** 关闭 */
@property (nonatomic, strong) UIButton *closeButton;
/** 刷新 */
@property (nonatomic, strong) UIButton *refreshButton;
/** 固定Title,设置后标题不会改变 */
@property (nonatomic, copy) NSString *navigationTitle;


/** 是否显示进度条(默认NO) */
@property (nonatomic, assign) BOOL isShowProgress;

/** 是否禁止侧滑(默认NO) */
@property (nonatomic, assign) BOOL isDisablePopGesture;

/** 是否禁止回退页面(默认NO) */
@property (nonatomic, assign) BOOL disableGoBack;

/** 是否禁止显示关闭按钮(默认NO) */
@property (nonatomic, assign) BOOL disableCloseButton;

/** 是否禁止显示刷新按钮(默认NO) */
@property (nonatomic, assign) BOOL disableRefreshButton;

/** 是否显示Navigation的分割线(默认NO) */
@property (nonatomic, assign) BOOL isShowNavigationLineView;

/** 如果手动监听,回退和返回上一控制器监听将失效 */
@property (nonatomic, copy) void(^backButtonAction)(void);

/** 在webView插入尾部视图 */
@property (nonatomic, strong) UIView *footerView;

/** webView是否加载完成 */
@property (nonatomic, readonly) BOOL webViewLoadFinish;

/** 更新尾部视图,(如高度更新,内容更新) */
- (void)updateFooterViewLayout;

@end

NS_ASSUME_NONNULL_END
