//
//  CalendarView.h
//  CalendarView
//
//  Created by xx on 2016/6/16.
//  Copyright (c) 2016年 Aze. All rights reserved.
//
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_RAT (SCREEN_WIDTH/320.0f)
#define INTTOSTR(intNum) [@(intNum) stringValue]

#import <UIKit/UIKit.h>


typedef void(^ParttimeComplete)(NSArray *resultArray);

@interface LDCalendarView : UIView

@property (nonatomic,strong) NSArray *defaultDates;
@property (nonatomic,copy) ParttimeComplete complete;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame withPrice:(float)price;

@end
