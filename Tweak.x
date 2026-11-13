// CCGlassDump - ban chan doan.
// Moi lan mo Control Center, ghi cay view ra:
//   /var/mobile/Documents/cc_dump.txt
#import <UIKit/UIKit.h>

static void dumpView(UIView *v, int depth, NSMutableString *out) {
    NSMutableString *indent = [NSMutableString string];
    for (int i = 0; i < depth; i++) [indent appendString:@"  "];
    [out appendFormat:@"%@%@ frame=%@ alpha=%.2f hidden=%d layer=%@ cornerR=%.1f clips=%d\n",
        indent,
        NSStringFromClass([v class]),
        NSStringFromCGRect(v.frame),
        v.alpha,
        v.hidden,
        NSStringFromClass([v.layer class]),
        v.layer.cornerRadius,
        v.clipsToBounds];
    for (UIView *s in v.subviews) dumpView(s, depth + 1, out);
}

%hook CCUIModularControlCenterOverlayViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    UIView *root = ((UIViewController *)self).view;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSMutableString *out = [NSMutableString string];
        [out appendFormat:@"iOS %@\n\n", [[UIDevice currentDevice] systemVersion]];
        dumpView(root, 0, out);
        [out writeToFile:@"/var/mobile/Documents/cc_dump.txt"
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:nil];
    });
}
%end
