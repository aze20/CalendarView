//
//  CalenderViewController.m
//  CalendarView
//
//  Created by xx on 2016/6/16.
//  Copyright (c) 2016年 Aze. All rights reserved.
//

#import "CalenderViewController.h"
#import "CalendarView.h"
#import "NSDate+extend.h"

@interface CalenderViewController ()
@property (nonatomic, strong)LDCalendarView *calendarView;      //日历控件
@property (nonatomic, strong)NSMutableArray *seletedDaysArray;  //选择的日期
@property (nonatomic, assign)float price;    //单价
@property (nonatomic, assign)float allPrice; //总价格

@end

@implementation CalenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalendarCell"];
    UILabel *showLab= (UILabel *)[cell.contentView viewWithTag:100.0];
    if (_seletedDaysArray.count) {
        showLab.text = [self showString];
    }else{
        showLab.text = @"请选择日期";
    }
    UILabel *priceLabel =(UILabel *)[cell.contentView viewWithTag:200];
    priceLabel.text = [NSString stringWithFormat:@" 订单总价格: %.1f",_allPrice];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.f;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //价格
    _price = 10.5;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //日期选择
    if (!_calendarView) {
        _calendarView = [[LDCalendarView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT) withPrice:_price];
        [self.view addSubview:_calendarView];
        
        __weak typeof(self) weakSelf = self;
        _calendarView.complete = ^(NSArray *result) {
            if (result) {
                weakSelf.seletedDaysArray = [result mutableCopy];
                weakSelf.allPrice = weakSelf.seletedDaysArray.count * weakSelf.price;
                [tableView reloadData];
            }
        };
    }
    //    [self.calendarView show];
    self.calendarView.defaultDates = _seletedDaysArray;
    
}

- (NSString *)showString {
    NSMutableString *str = [NSMutableString string];
    [str appendString:@""];
    //从小到大排序
    [_seletedDaysArray sortUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSNumber *interval in _seletedDaysArray) {
        NSString *partStr = [NSDate stringWithTimestamp:interval.doubleValue/1000.0 format:@"yyyy-MM-dd"];
        [str appendFormat:@"%@ ",partStr];
        
    }
    return [str copy];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
