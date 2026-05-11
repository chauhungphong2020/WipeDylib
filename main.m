#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation NSObject (WipeHack)

// Hàm tạo chuỗi ngẫu nhiên để làm ID mới
+ (NSString *)randomID {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:32];
    for (int i=0; i<32; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
}

+ (void)doWipe {
    // 1. Xóa sạch rác trong máy
    NSString *home = NSHomeDirectory();
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *folders = @[@"Documents", @"Library", @"tmp"];
    for (NSString *folder in folders) {
        NSString *path = [home stringByAppendingPathComponent:folder];
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // 2. Ép App tạo ID mới bằng cách ghi đè trực tiếp vào bộ nhớ tạm
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:[self randomID] forKey:@"stk_idfv_key"];
    [defs setObject:[self randomID] forKey:@"userID"];
    [defs setObject:[self randomID] forKey:@"uuidStringFromStore"];
    [defs synchronize];

    exit(0);
}
@end

__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        btn.frame = CGRectMake((screenWidth - 150) / 2, 60, 150, 45); 
        
        [btn setTitle:@"FORCE NEW ID" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.2 alpha:0.9]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 12;
        btn.layer.zPosition = 9999;
        
        [btn addTarget:[NSObject class] action:@selector(doWipe) forControlEvents:UIControlEventTouchUpInside];
        [[UIApplication sharedApplication].keyWindow addSubview:btn];
    });
}
