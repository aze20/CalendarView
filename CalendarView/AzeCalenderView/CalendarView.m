//
//  CalendarView.m
//  CalendarView
//
//  Created by xx on 2016/6/16.
//  Copyright (c) 2016年 Aze. All rights reserved.
//
#import "CalendarView.h"
#import "NSDate+extend.h"
#import "UIColor+Hex.h"

#define UNIT_WIDTH  30 * SCREEN_RAT  //一个日期小单元的宽度
#define DEFAULT_COLOR [UIColor colorWithHexString:@"#3f3f4d"]    //默认文字颜色
#define SELECT_BG_COLOR [UIColor colorWithHexString:@"#ff4a39"]  //选中背景颜色
#define LIMIT_COLOR [UIColor colorWithHexString:@"#9d9da3"]      //不可选文字颜色
#define LIMIT_BG_COLOR [UIColor colorWithHexString:@"#f1f1f1"]   //不可选背景颜色
#define DEUIFONT [UIFont fontWithName:@"Arial-BoldMT" size:15]   //字体样式

//行 列 每小格宽度 格子总数
static const NSInteger kRow = 7;    //行数
static const NSInteger kCol = 7;    //列数
static const NSInteger kTotalNum = (kRow - 1) * kCol;   //格子总数

@interface LDCalendarView() {
    NSMutableArray *_currentMonthDateArray; //当前月的时间
    NSMutableArray *_selectArray;   //选择的数组
    UIView *_dateBgView;            //日期的背景
    UIView *_contentBgView;
    CGRect _touchRect;              //可操作区域
    BOOL _isSingleSelect;            //单选模式  单选 = YES , 多选 = NO
    
}
@property (nonatomic, assign) int32_t month;
@property (nonatomic, assign) int32_t year;
@property (nonatomic, strong) UILabel *titleLabel;   //View标题
@property (nonatomic, strong) NSDate *today;         //今天的时间
@property (nonatomic, strong) UIButton *lastBtn;     //标记btn
@property (nonatomic, strong) UILabel *lastLabel;
@property (nonatomic, strong) UILabel *priceLabel;   //价格label
@property (nonatomic, assign) float price;           //系统价格
@end

@implementation LDCalendarView

//获取今天的时间
- (NSDate *)today {
    if (!_today) {
        NSDate *currentDate = [NSDate date];
        NSInteger tYear = currentDate.year;
        NSInteger tMonth = currentDate.month;
        NSInteger tDay = currentDate.day;
        //字符串转换为日期
        //实例化一个NSDateFormatter对象
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormat setDateFormat:@"YYYY-MM-dd"];
        _today =[dateFormat dateFromString:[NSString stringWithFormat:@"%@-%@-%@",@(tYear),@(tMonth),@(tDay)]];
    }
    return _today;
}
//UI
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
#warning changeSelectStyle
        _isSingleSelect = NO;

        _contentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 250, SCREEN_WIDTH, 45+UNIT_WIDTH*kCol+50)];
        _contentBgView.userInteractionEnabled = YES;
        _contentBgView.backgroundColor = [UIColor colorWithHexString:@"#c0c0c0"];
        [self addSubview:_contentBgView];
        
        // <  >
        UIImageView *leftImage = [UIImageView new];
        leftImage.image = [UIImage imageNamed:@"com_arrows_right"];
        leftImage.transform=CGAffineTransformMakeRotation(M_PI);
        [_contentBgView addSubview:leftImage];
        leftImage.frame = CGRectMake(CGRectGetWidth(_contentBgView.frame)/3.0 - 8 - 10, (42-18)/2.0, 10, 18);
        UIImageView *rightImage = [UIImageView new];
        rightImage.image = [UIImage imageNamed:@"com_arrows_right"];
        [_contentBgView addSubview:rightImage];
        rightImage.frame = CGRectMake(CGRectGetWidth(_contentBgView.frame)*2/3.0 + 8, (42-18)/2.0, 10, 18);
        
        //标题 x月,xx年
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentBgView.frame), 42)];
        _titleLabel.font = DEUIFONT;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.userInteractionEnabled = YES;
        [_contentBgView addSubview:_titleLabel];
        
        UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchMonthTap:)];
        [_titleLabel addGestureRecognizer:titleTap];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame) - 0.5, CGRectGetWidth(_contentBgView.frame), 0.5)];
        line.backgroundColor = [UIColor grayColor];
        [_contentBgView addSubview:line];
        
        //日期背景
        _dateBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), CGRectGetWidth(_contentBgView.frame), UNIT_WIDTH*kCol)];
        _dateBgView.userInteractionEnabled = YES;
        _dateBgView.backgroundColor = [UIColor whiteColor];
        [_contentBgView addSubview:_dateBgView];
        
        UIView *_bottomLine  = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_dateBgView.frame), CGRectGetWidth(_contentBgView.frame), 0.5)];
        _bottomLine.backgroundColor = [UIColor grayColor];
        [_contentBgView addSubview:_bottomLine];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_dateBgView addGestureRecognizer:tap];
        
//        _priceLabel.text = price;
        
        //初始化数据
        [self initData];

    }
    return self;
}
-(id)initWithFrame:(CGRect)frame withPrice:(float)price{
    self.price = price;
    self = [self initWithFrame:frame];
    return self;
}

- (void)initData {
    
    _selectArray = @[].mutableCopy;
    //获取当前年月
    NSDate *currentDate = [NSDate date];
    self.month = (int32_t)currentDate.month;
    self.year = (int32_t)currentDate.year;
    [self refreshDateTitle];

    _currentMonthDateArray = [NSMutableArray array];
    for (int i = 0; i < kTotalNum; i++) {
        [_currentMonthDateArray addObject:@(0)];
    }
    
    [self showDateView];
}

- (void)showDateView {
    //移除之前子视图
    [_dateBgView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    CGFloat offX = 0.0;
    CGFloat offY = 0.0;
    CGFloat width = (CGRectGetWidth(_dateBgView.frame)) / kCol;
    CGFloat height = (CGRectGetHeight(_dateBgView.frame)) / kRow;
    CGRect baseRect = CGRectMake(offX,offY, width, height);
    NSArray *tmparr = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for(int i = 0; i < 7; i++){
        UILabel *lab = [[UILabel alloc] initWithFrame:baseRect];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.backgroundColor = LIMIT_BG_COLOR;
        lab.textColor = [UIColor colorWithHexString:@"#3f3f4d"];;
        lab.font = DEUIFONT;
        lab.text = [tmparr objectAtIndex:i];
        [_dateBgView addSubview:lab];
        baseRect.origin.x += baseRect.size.width;
    }

    //字符串转换为日期
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSDate *firstDay =[dateFormat dateFromString:[NSString stringWithFormat:@"%@-%@-%@",@(self.year),@(self.month),@(1)]];
    //获取当前月份第一天是星期几
    CGFloat startDayIndex = [NSDate acquireWeekDayFromDate:firstDay];
    //第一天是今天，特殊处理
    if (startDayIndex == 1) {
        //星期天（对应1）
        startDayIndex = 6;
    }else{
        //周一到周六（对应2-7）
        startDayIndex -= 2;
    }
    baseRect.origin.x = width * startDayIndex;
    baseRect.origin.y += (baseRect.size.height);
    NSInteger baseTag = 100;
    
    for (int i = startDayIndex; i < kTotalNum; i++) {
        
        if (i % kCol == 0 && i != 0){
            baseRect.origin.y += (baseRect.size.height);
            baseRect.origin.x = offX;
        }
        //设置触摸区域
        if (i == startDayIndex){
            _touchRect.origin = baseRect.origin;
            _touchRect.origin.x = 0;
            _touchRect.size.width = kCol * width;
            _touchRect.size.height = kRow * height;
        }

//设置日期(设置为btn的title)
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:baseRect];
        btn.tag = baseTag + i;
        btn.userInteractionEnabled = NO;
        btn.titleLabel.textColor = DEFAULT_COLOR;
        [btn.titleLabel setFont:DEUIFONT];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 15, 0);
        NSDate * date = [firstDay dateByAddingTimeInterval:(i - startDayIndex) * 24 * 60 * 60];
        _currentMonthDateArray[i] = @(([date timeIntervalSince1970]) * 1000);
        NSString *title = INTTOSTR(date.day);
        
        //今天,设置边框
        if ([date isToday]) {
            btn.layer.borderColor = [UIColor redColor].CGColor;
            btn.layer.borderWidth = 1;
        }

//TODO: 设置价格/节假日
        if ([self.today compare:date] <= 0) {
            //时间比今天大,同时是当前月
            [btn setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
            _priceLabel = [[UILabel alloc]init];
            _priceLabel.frame = CGRectMake(btn.frame.origin.x+10, btn.frame.origin.y+btn.frame.size.height/2.0f, btn.frame.size.width-10, btn.frame.size.height/2.0f);
            _priceLabel.textAlignment = NSTextAlignmentCenter;
            _priceLabel.font = DEUIFONT;
            _priceLabel.text = [NSString stringWithFormat:@"¥%.1f",_price];
            _priceLabel.textColor = [UIColor redColor];
            _priceLabel.tag = 1000 + i;
            [_dateBgView addSubview:_priceLabel];
            
        }else {
            btn.backgroundColor = LIMIT_BG_COLOR;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, btn.frame.size.height/2, btn.frame.size.width, btn.frame.size.height/2)];
            label.text = @"已过期";
            label.textAlignment = 1;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = LIMIT_COLOR;
            [btn addSubview:label];
            [btn setTitleColor:LIMIT_COLOR forState:UIControlStateNormal];
        }
        //单选模式隐藏下个月的日期
        if (_isSingleSelect == YES) {
            if (self.month < date.month || self.year < date.year) {
                _priceLabel.hidden = YES;
                btn.hidden = YES;
            }else{
                [btn setTitle:title forState:UIControlStateNormal];
            }
        }else{
            [btn setTitle:title forState:UIControlStateNormal];
        }
        
        [_dateBgView addSubview:btn];
        [_dateBgView sendSubviewToBack:btn];
        baseRect.origin.x += (baseRect.size.width);
        
    }
    //设置分割线
    for (int i = 1; i < 7; i++) {
        UILabel * xlabel = [[UILabel alloc]init];
        xlabel.frame = CGRectMake(i*SCREEN_WIDTH/7, 0.5, 0.5, CGRectGetHeight(_dateBgView.frame)-0.5);
        xlabel.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
        [_dateBgView addSubview:xlabel];
        UILabel * ylabel = [[UILabel alloc]init];
        ylabel.frame = CGRectMake(0, i* _dateBgView.frame.size.height/7,SCREEN_WIDTH,0.5);
        ylabel.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
        [_dateBgView addSubview:ylabel];
    }
    //高亮选中的
    [self refreshDateView];
}

- (void)refreshDateView {
    for(int i = 0; i < kTotalNum; i++)
    {
        UIButton *btn = (UIButton *)[_dateBgView viewWithTag:100 + i];
        NSNumber *interval = [_currentMonthDateArray objectAtIndex:i];
        
        UILabel * lab =(UILabel *)[_dateBgView viewWithTag: 1000 + i];
        if (i < [_currentMonthDateArray count] && btn)
        {
            if ([_selectArray containsObject:interval]) {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setBackgroundColor:SELECT_BG_COLOR];
                lab.textColor = [UIColor whiteColor];
                self.lastBtn = btn;
                self.lastLabel = lab;
            }
        }
    }
}

-(void)tap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_dateBgView];
    if (CGRectContainsPoint(_touchRect, point)) {
        CGFloat w = (CGRectGetWidth(_dateBgView.frame)) / kCol;
        CGFloat h = (CGRectGetHeight(_dateBgView.frame)) / kRow;
        int row = (int)((point.y - _touchRect.origin.y) / h);
        int col = (int)((point.x) / w);
        
        NSInteger index = row * kCol + col;
        [self clickForIndex:index];
    }
}
//TODO:- 日期点击事件
- (void)clickForIndex:(NSInteger)index
{
    UIButton *btn = (UIButton *)[_dateBgView viewWithTag:100 + index];
    _priceLabel = (UILabel *)[_dateBgView viewWithTag:1000 +index];
    //防止触摸 空白日期按钮 导致已选数据错乱
    if (btn.titleLabel.text == nil) {
        return;
    }
    if (index < [_currentMonthDateArray count]) {
        
        NSNumber *interval = [_currentMonthDateArray objectAtIndex:index];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval.doubleValue/1000.0];
        
        if ([self.today compare:date] <= 0) {
            //今天0点之后的时间,同时也是当前月
        }else {
            //今天0点之前的时间 (过期时间)
            return;
        }
        if (_isSingleSelect == NO) {
            //TODO:- 多选状态
            if ([_selectArray containsObject:interval]) {
                //已选中,取消
                [_selectArray removeObject:interval];
                [btn setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor clearColor]];
                //恢复选中状态的_priceLabel 的颜色为默认
                _priceLabel.textColor = [UIColor redColor];
                
            }else {
                //未选中,想选择
                [_selectArray addObject:interval];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setBackgroundColor:SELECT_BG_COLOR];
                _priceLabel.textColor = [UIColor whiteColor];
                
                //如果选中的是下个月切换到下个月
                if (date.month > self.month) {
                    [self rightSwitch];
                }
            }
        }else {
            //TODO:- 单选状态
            if ([_selectArray containsObject:interval]) {
                //反选
                [_selectArray removeObject:interval];
                [btn setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor clearColor]];
                _priceLabel.textColor = [UIColor redColor];
            }else {
                
                if (_selectArray.count == 0) {
                    //第一次选择
                    [_selectArray addObject:interval];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [btn setBackgroundColor:SELECT_BG_COLOR];
                    //记录btn
                    self.lastBtn = btn;
                    _priceLabel.textColor = [UIColor whiteColor];
                    self.lastLabel = _priceLabel;
                }else {
                    //改变已选择日期 先移除 改变UI
                    [_selectArray removeAllObjects];
                    [self.lastBtn setTitleColor:DEFAULT_COLOR forState:UIControlStateNormal];
                    [self.lastBtn setBackgroundColor:[UIColor clearColor]];
                    self.lastLabel.textColor = [UIColor redColor];
                    
                    //添加新数据 改变UI
                    [_selectArray addObject:interval];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [btn setBackgroundColor:SELECT_BG_COLOR];
                    _priceLabel.textColor = [UIColor whiteColor];
                    //再次记录
                    self.lastBtn = btn;
                    self.lastLabel = _priceLabel;
                }

            }
            
        }
    }
    
    //已选择日期数据
    if (_complete) {
        _complete([_selectArray mutableCopy]);
         for (NSNumber *interval in _selectArray) {
             NSString *partStr = [NSDate stringWithTimestamp:interval.doubleValue/1000.0 format:@"yyyy-MM-dd"];
             NSLog(@"已选择的日期 --> %@",partStr);
        }
    }
#warning  allPrice
//此处定义一个变量,计算总价格
    NSLog(@"_selectArray.count-->%lu",(unsigned long)_selectArray.count);
    float aaa = _price *_selectArray.count;
    NSLog(@"401行 -> %f",aaa);
    
    
}

//设置回调数组
- (void)setDefaultDates:(NSArray *)defaultDateArray {
    _defaultDates = defaultDateArray;
    
    if (defaultDateArray) {
        _selectArray = [defaultDateArray mutableCopy];
    }else {
        _selectArray = @[].mutableCopy;
    }
}

//标题触摸区域
- (void)switchMonthTap:(UITapGestureRecognizer *)tap {
    CGPoint loc =[tap locationInView:_titleLabel];
    CGFloat titleLabWidth = CGRectGetWidth(_titleLabel.frame);
    
    if (loc.x <= titleLabWidth/3.0) {
        //判断日期小于当前月,日期不改变
        NSDate *currentDate = [NSDate date];
        NSInteger tYear = currentDate.year;
        NSInteger tMonth = currentDate.month;
        //过期月份不触发事件
        if (self.year > tYear) {
            [self leftSwitch];
        }else if (self.month <= tMonth){
            return;
        }
        
        [self leftSwitch];
    }else if(loc.x >= titleLabWidth/3.0*2.0) {
        [self rightSwitch];
    }
}

- (void)leftSwitch{
    if (self.month > 1) {
        self.month -= 1;
    }else {
        self.month = 12;
        self.year -= 1;
    }
    [self refreshDateTitle];
}

- (void)rightSwitch {
    if (self.month < 12) {
        self.month += 1;
    }else {
        self.month = 1;
        self.year += 1;
    }
    [self refreshDateTitle];
}
//刷新标题显示的时间
- (void)refreshDateTitle {
    _titleLabel.text = [NSString stringWithFormat:@"%@年%@月",@(self.year),@(self.month)];
    [self showDateView];
}

@end
