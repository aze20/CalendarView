//
//  UIColor+Hex.h

/*********************************
 文件名: UIColor+Hex.h
 功能描述: 16进制转UIColor
 *********************************/
#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHexString: (NSString *) stringToConvert;
+ (UIColor *)colorWithSETPRICE:(NSString *)SETPRICE price:(NSString*)PRICE;
+ (UIColor *)colorWithRAISELOSE:(NSString *)RAISELOSE;
@end
