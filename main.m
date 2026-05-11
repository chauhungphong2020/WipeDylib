#import <UIKit/UIKit.h>

@interface WipeController : NSObject
+ (void)doWipe;
@end

@implementation WipeController
+ (void)doWipe {
    NSString *home = NSHomeDirectory();
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Danh sách các thư mục chứa ID và Credit
    NSArray *folders = @[@"Documents", @"Library", @"tmp"];
    
    for (NSString *folder in folders) {
        NSString *path = [home stringByAppendingPathComponent:folder];
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // Xóa thêm NSUserDefaults (nơi lưu userID và IDFV bạn thấy trong ảnh)
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];

    exit(0); // Thoát để app reset hoàn toàn
}
@end

__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        
        // Căn giữa màn hình phía trên
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        btn.frame = CGRectMake((screenWidth - 120) / 2, 50, 120, 45); 
        
        [btn setTitle:@"RESET CREDIT" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 15;
        btn.layer.zPosition = 9999; // Đảm bảo luôn nằm trên cùng
        
        // Gắn sự kiện
        [btn addTarget:[WipeController class] action:@selector(doWipe) forControlEvents:UIControlEventTouchUpInside];
        
        [[UIApplication sharedApplication].keyWindow addSubview:btn];
    });
}
