//
//  HLTestHomePageController.m
//  HLWebViewControllerDemo
//
//  Created by cainiu on 2019/1/7.
//  Copyright © 2019 HL. All rights reserved.
//

#import "HLTestHomePageController.h"
#import "HLWebViewController.h"

@interface HLTestHomePageController ()

@property (nonatomic, copy) NSArray *datas;

@end

@implementation HLTestHomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datas = @[@"HLDemoTableViewFooterController"];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homepageCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"homepageCell"];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *vcName = self.datas[indexPath.row];
    if (vcName && vcName.length) {
        HLWebViewController *vc = (HLWebViewController *)[[NSClassFromString(vcName) alloc] init];
        vc.requestUrl = [NSURL URLWithString:@"https://www.baidu.com"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
