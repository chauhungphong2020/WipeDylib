#import <UIKit/UIKit.h>
#import <Security/Security.h>

@interface WipeController : NSObject
+ (void)doWipe;
@end

@implementation WipeController
+ (void)doWipe {
    // 1. Xóa sạch Keychain (ID định danh nằm ở đây)
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

    // 2. Xóa sạch file trong Documents, Library, tmp
    NSString *home = NSHomeDirectory();
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *folders = @[@"Documents", @"Library", @"tmp"];
    for (NSString *folder in folders) {
        NSString *path = [home stringByAppendingPathComponent:folder];
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // 3. Reset UserDefaults
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];

    exit(0);
}
@end

__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        // Căn giữa màn hình
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat btnWidth = 140;
        btn.frame = CGRectMake((screenWidth - btnWidth) / 2, 60, btnWidth, 45); 
        
        [btn setTitle:@"WIPE & RESET" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.9]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 12;
        btn.layer.zPosition = 9999;
        
        [btn addTarget:[WipeController class] action:@selector(doWipe) forControlEvents:UIControlEventTouchUpInside];
        
        // Thêm vào cửa sổ chính
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:btn];
    });
}
