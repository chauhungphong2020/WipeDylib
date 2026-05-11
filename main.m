#import <UIKit/UIKit.h>
#import <Security/Security.h>

@interface WipeController : NSObject
+ (void)doWipe;
@end

@implementation WipeController
+ (void)doWipe {
    // 1. Xoá sạch file trong Documents, Library, tmp
    NSString *home = NSHomeDirectory();
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *folders = @[@"Documents", @"Library", @"tmp"];
    for (NSString *folder in folders) {
        NSString *path = [home stringByAppendingPathComponent:folder];
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // 2. Xoá Keychain (Đây là chìa khoá để hồi Credit)
    NSArray *secClasses = @[
        (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecClassInternetPassword,
        (__bridge id)kSecClassCertificate,
        (__bridge id)kSecClassKey,
        (__bridge id)kSecClassIdentity
    ];
    for (id secClass in secClasses) {
        NSDictionary *spec = @{(__bridge id)kSecClass: secClass};
        SecItemDelete((__bridge CFDictionaryRef)spec);
    }

    // 3. Xoá NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Thoát app
    exit(0);
}
@end

__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        // Vị trí: Chính giữa phía trên (cách đỉnh 60px)
        btn.frame = CGRectMake((screenWidth - 140) / 2, 60, 140, 45); 
        
        [btn setTitle:@"CLEAR ALL DATA" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.9]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 12;
        btn.layer.zPosition = 9999;
        
        [btn addTarget:[WipeController class] action:@selector(doWipe) forControlEvents:UIControlEventTouchUpInside];
        [[UIApplication sharedApplication].keyWindow addSubview:btn];
    });
}
