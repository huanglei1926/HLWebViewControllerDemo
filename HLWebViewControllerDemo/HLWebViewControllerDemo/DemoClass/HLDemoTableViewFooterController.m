//
//  HLDemoWebController.m
//  HLWebViewControllerDemo
//
//  Created by cainiu on 2019/1/7.
//  Copyright © 2019 HL. All rights reserved.
//

#import "HLDemoTableViewFooterController.h"

#define kHLDemoWeakSelf __weak typeof(self) weakSelf = self;
#define kHLDemoScreenW [UIScreen mainScreen].bounds.size.width
#define kHLDemoScreenH [UIScreen mainScreen].bounds.size.height
#define kHLDemoSafeAreaTopHeight (kHLDemoScreenH == 812.0 ? 88 : 64)

#define kHLDemoColorHexValueAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]
#define kHLDemoColorHexValue(rgbValue) kHLDemoColorHexValueAlpha(rgbValue,1.0)

@interface HLDemoTableViewFooterController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HLDemoTableViewFooterController

- (BOOL)isShowProgress{
    return YES;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.footerView = [self getWebFooterView];
    kHLDemoWeakSelf
    [self requestDatasHandler:^(int code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadTableViewH];
            [weakSelf updateFooterViewLayout];
        });
    }];
}

- (UIView *)getWebFooterView{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kHLDemoScreenW, kHLDemoScreenH)];
    [footerView addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    return footerView;
}

- (UITableView *)createTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kHLDemoScreenW, kHLDemoScreenH) style:UITableViewStyleGrouped];
    tableView.backgroundColor = kHLDemoColorHexValue(0xeeeeee);
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    tableView.frame = CGRectMake(0, kHLDemoSafeAreaTopHeight, kHLDemoScreenW, kHLDemoScreenH-kHLDemoSafeAreaTopHeight);
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    return tableView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [self createTableView];
        _tableView.rowHeight = 44;
    }
    return _tableView;
}


- (void)reloadTableViewH{
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    CGFloat footerHeight = self.tableView.contentSize.height;
    CGRect frame = self.footerView.frame;
    frame.size.height = footerHeight;
    self.footerView.frame = frame;
    self.tableView.frame = CGRectMake(0, 0, kHLDemoScreenW, footerHeight);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *testStr = self.dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"testCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"testCell"];
    }
    cell.textLabel.text = testStr;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *testStr = self.dataSource[indexPath.row];
    NSLog(@"didSelectRowAtIndexPath-%@",testStr);
}

#pragma mark - 请求数据
- (void)requestDatasHandler:(void (^_Nonnull)(int code))handler{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [dataArray addObject:[NSString stringWithFormat:@"测试数据-%d",i]];
    }
    [self.dataSource addObjectsFromArray:dataArray];
    handler(1);
}



@end
