#import <UIKit/UIKit.h>

@interface WipeButton : UIButton
@end

@implementation WipeButton

// Hàm xóa dữ liệu
- (void)wipeData {
    NSString *homeDir = NSHomeDirectory();
    NSArray *folders = @[@"Documents", @"Library", @"tmp"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    for (NSString *folder in folders) {
        NSString *path = [homeDir stringByAppendingPathComponent:folder];
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // Thông báo và thoát app để nhận dữ liệu mới
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Xong!" message:@"Dữ liệu đã xóa. App sẽ đóng để khởi động lại." preferredStyle:UIAlertControllerStyleAlert];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

@end

// Hàm khởi tạo nút bấm khi app load dylib
__attribute__((constructor))
static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 100, 80, 40);
        [btn setTitle:@"Wipe Data" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor redColor]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 10;
        
        // Thêm sự kiện nhấn nút
        [btn addTarget:nil action:@selector(wipeData) forControlEvents:UIControlEventTouchUpInside];
        
        [[UIApplication sharedApplication].keyWindow addSubview:btn];
    });
}
