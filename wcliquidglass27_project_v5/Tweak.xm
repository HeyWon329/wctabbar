#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <objc/message.h>

#define WCLG27_CLAMP(v, lo, hi) MAX((lo), MIN((hi), (v)))

static const NSInteger kWCLG27GlassTag = 927027;
static const NSInteger kWCLG27OverlayTag = 927028;
static const NSInteger kWCLG27SearchButtonTag = 927127;
static const NSInteger kWCLG27HomeSearchButtonTag = 927128;
static const NSInteger kWCLG27FloatingBallTag = 927227;
static const void *kWCLG27GlassHostKey = &kWCLG27GlassHostKey;
static const void *kWCLG27LastScanKey = &kWCLG27LastScanKey;
static const void *kWCLG27TabSearchButtonKey = &kWCLG27TabSearchButtonKey;
static const void *kWCLG27HomeSearchItemKey = &kWCLG27HomeSearchItemKey;
static const void *kWCLG27TitleCapsuleKey = &kWCLG27TitleCapsuleKey;
static const void *kWCLG27OriginalTitleViewKey = &kWCLG27OriginalTitleViewKey;
static const void *kWCLG27OriginalHomeTitleKey = &kWCLG27OriginalHomeTitleKey;
static const void *kWCLG27OriginalHomeNavTitleKey = &kWCLG27OriginalHomeNavTitleKey;

static NSString *const kWCLG27EnabledKey = @"wclg27_enabled";
static NSString *const kWCLG27TintColorKey = @"wclg27_color_tint";
static NSString *const kWCLG27HomeColorKey = @"wclg27_color_home_bg";

static NSString *const kWCLG27FeatureTabBar = @"wclg27_feature_tabbar";
static NSString *const kWCLG27FeatureNavBar = @"wclg27_feature_navbar";
static NSString *const kWCLG27FeatureSearchGlass = @"wclg27_feature_search_glass";
static NSString *const kWCLG27FeatureInputGlass = @"wclg27_feature_input_glass";
static NSString *const kWCLG27FeatureBubbleGlass = @"wclg27_feature_bubble_glass";
static NSString *const kWCLG27FeatureChatTitleCapsule = @"wclg27_feature_chat_title_capsule";
static NSString *const kWCLG27FeatureMomentsNav = @"wclg27_feature_moments_nav";
static NSString *const kWCLG27FeatureHideHomeTitle = @"wclg27_feature_hide_home_title";
static NSString *const kWCLG27FeatureTabRightSearch = @"wclg27_feature_tab_right_search";
static NSString *const kWCLG27FeatureHomeSearchButton = @"wclg27_feature_home_search_button";
static NSString *const kWCLG27FeatureHomePureBG = @"wclg27_feature_home_pure_bg";
static NSString *const kWCLG27FeatureHidePinnedBG = @"wclg27_feature_hide_pinned_bg";
static NSString *const kWCLG27FeatureFloatingBall = @"wclg27_feature_floating_ball";

static NSString *const kWCLG27StrengthGlobal = @"wclg27_strength_global";
static NSString *const kWCLG27StrengthTabBar = @"wclg27_strength_tabbar";
static NSString *const kWCLG27StrengthNavBar = @"wclg27_strength_navbar";
static NSString *const kWCLG27StrengthSearch = @"wclg27_strength_search";
static NSString *const kWCLG27StrengthInput = @"wclg27_strength_input";
static NSString *const kWCLG27StrengthBubble = @"wclg27_strength_bubble";
static NSString *const kWCLG27StrengthTitle = @"wclg27_strength_title";
static NSString *const kWCLG27StrengthMoments = @"wclg27_strength_moments";

@class WCLG27SettingsViewController;
@class WCLG27ColorPickerFallbackController;


// Compile-fix forward declarations for helpers inserted before their implementations.
static void WCLG27RemoveGlassHost(UIView *target);
static void WCLG27PresentSettings(void);
static void WCLG27UpdateLiquidLayers(UIView *host, CGFloat alpha);
static BOOL WCLG27ViewLooksVisibleOnScreen(UIView *view);
static void WCLG27ApplyInputGlass(UIView *view);
static BOOL WCLG27RuntimeMayScan(void);
static BOOL WCLG27RegisterPluginManagerEntrySync(void);
static BOOL WCLG27RegisterPluginManagerEntryWithManager(id manager);
static void WCLG27RegisterPluginManagerEntry(void);
static UIView *WCLG27EnsureGlassHost(UIView *target, CGFloat cornerRadius, CGFloat alpha);
static UIView *WCLG27EnsureGlassHostInFrame(UIView *target, CGRect frame, CGFloat cornerRadius, CGFloat alpha);
static void WCLG27ScanViewTree(UIView *root, NSInteger depth);
static void WCLG27ApplyBottomInputForTextInput(UIView *input);
static void WCLG27ApplyTabBar(UITabBar *tabBar);
static void WCLG27ApplyNavigationBar(UINavigationBar *bar);

static BOOL WCLG27RuntimeEnabled(void);
static void WCLG27ScheduleFallbackFloatingBallCheck(void);
static void WCLG27EnsureFallbackFloatingBall(BOOL show);

static BOOL WCLG27StringContains(NSString *s, NSArray<NSString *> *needles) {
    if (s.length == 0) return NO;
    for (NSString *n in needles) {
        if ([s rangeOfString:n options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    }
    return NO;
}

static NSUserDefaults *WCLG27Defaults(void) {
    return [NSUserDefaults standardUserDefaults];
}

static BOOL WCLG27Bool(NSString *key, BOOL fallback) {
    id value = [WCLG27Defaults() objectForKey:key];
    if (!value) return fallback;
    return [WCLG27Defaults() boolForKey:key];
}

static CGFloat WCLG27Float(NSString *key, CGFloat fallback) {
    id value = [WCLG27Defaults() objectForKey:key];
    if (!value) return fallback;
    return WCLG27_CLAMP([WCLG27Defaults() doubleForKey:key], 0.0, 1.0);
}

static void WCLG27SetBool(NSString *key, BOOL value) {
    [WCLG27Defaults() setBool:value forKey:key];
    [WCLG27Defaults() synchronize];
}

static void WCLG27SetFloat(NSString *key, CGFloat value) {
    [WCLG27Defaults() setDouble:WCLG27_CLAMP(value, 0.0, 1.0) forKey:key];
    [WCLG27Defaults() synchronize];
}

static BOOL WCLG27Enabled(void) {
    return WCLG27Bool(kWCLG27EnabledKey, NO);
}

static BOOL WCLG27Feature(NSString *key, BOOL fallback) {
    return WCLG27Enabled() && WCLG27Bool(key, fallback);
}

static NSInteger WCLG27MajorOSVersion(void) {
    return [NSProcessInfo processInfo].operatingSystemVersion.majorVersion;
}

static NSString *WCLG27ColorComponentKey(NSString *base, NSString *component) {
    return [NSString stringWithFormat:@"%@_%@", base, component];
}

static UIColor *WCLG27ColorForKey(NSString *base, UIColor *fallback) {
    NSUserDefaults *d = WCLG27Defaults();
    if (![d objectForKey:WCLG27ColorComponentKey(base, @"r")]) return fallback;
    CGFloat r = [d doubleForKey:WCLG27ColorComponentKey(base, @"r")];
    CGFloat g = [d doubleForKey:WCLG27ColorComponentKey(base, @"g")];
    CGFloat b = [d doubleForKey:WCLG27ColorComponentKey(base, @"b")];
    CGFloat a = [d objectForKey:WCLG27ColorComponentKey(base, @"a")] ? [d doubleForKey:WCLG27ColorComponentKey(base, @"a")] : 1.0;
    return [UIColor colorWithRed:WCLG27_CLAMP(r, 0, 1) green:WCLG27_CLAMP(g, 0, 1) blue:WCLG27_CLAMP(b, 0, 1) alpha:WCLG27_CLAMP(a, 0, 1)];
}

static void WCLG27SetColorForKey(NSString *base, UIColor *color) {
    CGFloat r = 1, g = 1, b = 1, a = 1;
    if (![color getRed:&r green:&g blue:&b alpha:&a]) {
        CGFloat white = 1;
        [color getWhite:&white alpha:&a];
        r = g = b = white;
    }
    NSUserDefaults *d = WCLG27Defaults();
    [d setDouble:r forKey:WCLG27ColorComponentKey(base, @"r")];
    [d setDouble:g forKey:WCLG27ColorComponentKey(base, @"g")];
    [d setDouble:b forKey:WCLG27ColorComponentKey(base, @"b")];
    [d setDouble:a forKey:WCLG27ColorComponentKey(base, @"a")];
    [d synchronize];
}

static BOOL WCLG27IsPluginPreferenceKey(NSString *key) {
    if (![key isKindOfClass:[NSString class]] || key.length == 0) return NO;
    return [key hasPrefix:@"wclg27_"] ||
           [key hasPrefix:@"wcliquidglass27_"] ||
           [key hasPrefix:@"WCLG27"] ||
           [key hasPrefix:@"WCLG_"] ||
           [key hasPrefix:@"WCLG"] ||
           [key hasPrefix:@"WeChatLiquidGlass"];
}

static NSInteger WCLG27PurgePluginPreferences(BOOL leavePluginDisabled) {
    NSUserDefaults *d = WCLG27Defaults();
    NSDictionary *all = [d dictionaryRepresentation];
    NSInteger removed = 0;
    for (NSString *key in all.allKeys) {
        if (WCLG27IsPluginPreferenceKey(key)) {
            [d removeObjectForKey:key];
            removed++;
        }
    }
    if (leavePluginDisabled) {
        [d setBool:NO forKey:kWCLG27EnabledKey];
    }
    [d synchronize];
    return removed;
}

static NSString *WCLG27ClearConfigMarkerPath(void) {
    return @"/var/mobile/Library/Preferences/wclg27_clear_config";
}

static void WCLG27ConsumeExternalClearConfigMarkerIfNeeded(void) {
    NSString *path = WCLG27ClearConfigMarkerPath();
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        WCLG27PurgePluginPreferences(YES);
        [fm removeItemAtPath:path error:nil];
    }
}

static CGFloat WCLG27FeatureAlpha(NSString *strengthKey, CGFloat fallback) {
    CGFloat global = WCLG27Float(kWCLG27StrengthGlobal, 0.86);
    CGFloat feature = WCLG27Float(strengthKey, fallback);
    return WCLG27_CLAMP(feature * (0.62 + global * 0.38), 0.08, 1.0);
}

static UIColor *WCLG27TintColor(void) {
    return WCLG27ColorForKey(kWCLG27TintColorKey, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.18]);
}

static UIColor *WCLG27HomeBackgroundColor(void) {
    if (@available(iOS 13.0, *)) {
        return WCLG27ColorForKey(kWCLG27HomeColorKey, [UIColor systemGroupedBackgroundColor]);
    }
    return WCLG27ColorForKey(kWCLG27HomeColorKey, [UIColor colorWithWhite:0.96 alpha:1.0]);
}

static UIVisualEffect *WCLG27CreateEffect(void) {
    if (WCLG27MajorOSVersion() >= 26) {
        Class glassClass = NSClassFromString(@"UIGlassEffect");
        if (glassClass) {
            id effect = nil;
            SEL initWithStyle = NSSelectorFromString(@"initWithStyle:");
            if ([glassClass instancesRespondToSelector:initWithStyle]) {
                effect = ((id (*)(id, SEL, NSInteger))objc_msgSend)([glassClass alloc], initWithStyle, 0);
            } else {
                effect = [[glassClass alloc] init];
            }
            if (effect) {
                SEL setInteractive = NSSelectorFromString(@"setInteractive:");
                SEL setIsInteractive = NSSelectorFromString(@"setIsInteractive:");
                if ([effect respondsToSelector:setInteractive]) {
                    ((void (*)(id, SEL, BOOL))objc_msgSend)(effect, setInteractive, YES);
                } else if ([effect respondsToSelector:setIsInteractive]) {
                    ((void (*)(id, SEL, BOOL))objc_msgSend)(effect, setIsInteractive, YES);
                }
                SEL setTintColor = NSSelectorFromString(@"setTintColor:");
                if ([effect respondsToSelector:setTintColor]) {
                    ((void (*)(id, SEL, UIColor *))objc_msgSend)(effect, setTintColor, WCLG27TintColor());
                }
                return (UIVisualEffect *)effect;
            }
        }
    }
    if (@available(iOS 13.0, *)) return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
}

static void WCLG27ApplyLayerStyle(UIView *host, CGFloat cornerRadius, CGFloat alpha) {
    host.alpha = alpha;
    host.layer.cornerRadius = MIN(cornerRadius, MIN(CGRectGetWidth(host.bounds), CGRectGetHeight(host.bounds)) / 2.0);
    if (@available(iOS 13.0, *)) host.layer.cornerCurve = kCACornerCurveContinuous;
    host.layer.borderWidth = 0.5;
    host.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.26] CGColor];
    host.layer.shadowColor = [UIColor blackColor].CGColor;
    host.layer.shadowOpacity = 0.10;
    host.layer.shadowRadius = 14.0;
    host.layer.shadowOffset = CGSizeMake(0, 5);
}

static UIView *WCLG27EnsureGlassHost(UIView *target, CGFloat cornerRadius, CGFloat alpha) {
    if (!target || target.bounds.size.width < 2 || target.bounds.size.height < 2) return nil;

    UIView *host = objc_getAssociatedObject(target, kWCLG27GlassHostKey);
    if (!host || ![host isDescendantOfView:target]) {
        host = [[UIView alloc] initWithFrame:target.bounds];
        host.tag = kWCLG27GlassTag;
        host.userInteractionEnabled = NO;
        host.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        host.clipsToBounds = YES;
        host.backgroundColor = [UIColor clearColor];
        [target insertSubview:host atIndex:0];
        objc_setAssociatedObject(target, kWCLG27GlassHostKey, host, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:WCLG27CreateEffect()];
        effectView.tag = kWCLG27GlassTag + 1;
        effectView.userInteractionEnabled = NO;
        effectView.frame = host.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [host addSubview:effectView];

        UIView *shine = [[UIView alloc] initWithFrame:host.bounds];
        shine.tag = kWCLG27GlassTag + 2;
        shine.userInteractionEnabled = NO;
        shine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [host addSubview:shine];
    }

    host.frame = target.bounds;
    WCLG27ApplyLayerStyle(host, cornerRadius, alpha);

    for (UIView *sub in host.subviews) {
        if (sub.tag == kWCLG27GlassTag + 1 && [sub isKindOfClass:[UIVisualEffectView class]]) {
            ((UIVisualEffectView *)sub).effect = WCLG27CreateEffect();
        } else if (sub.tag == kWCLG27GlassTag + 2) {
            sub.backgroundColor = [WCLG27TintColor() colorWithAlphaComponent:0.12];
        }
    }
    return host;
}


#pragma mark - WCLG27 Fitted Glass Host

static CGRect WCLG27ClampRectToBounds(CGRect frame, CGRect bounds) {
    if (CGRectIsEmpty(frame) || CGRectIsNull(frame) || CGRectGetWidth(frame) < 2 || CGRectGetHeight(frame) < 2) {
        return bounds;
    }
    CGRect result = CGRectIntersection(frame, bounds);
    if (CGRectIsEmpty(result) || CGRectIsNull(result) || CGRectGetWidth(result) < 2 || CGRectGetHeight(result) < 2) {
        return bounds;
    }
    return CGRectIntegral(result);
}

static UIView *WCLG27EnsureGlassHostInFrame(UIView *target, CGRect frame, CGFloat cornerRadius, CGFloat alpha) {
    if (!target || CGRectGetWidth(target.bounds) < 2 || CGRectGetHeight(target.bounds) < 2) return nil;

    frame = WCLG27ClampRectToBounds(frame, target.bounds);

    UIView *host = objc_getAssociatedObject(target, kWCLG27GlassHostKey);
    if (!host || ![host isDescendantOfView:target]) {
        host = [[UIView alloc] initWithFrame:frame];
        host.tag = kWCLG27GlassTag;
        host.userInteractionEnabled = NO;
        host.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        host.clipsToBounds = YES;
        host.backgroundColor = [UIColor clearColor];
        [target insertSubview:host atIndex:0];
        objc_setAssociatedObject(target, kWCLG27GlassHostKey, host, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:WCLG27CreateEffect()];
        effectView.tag = kWCLG27GlassTag + 1;
        effectView.userInteractionEnabled = NO;
        effectView.frame = host.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [host addSubview:effectView];

        UIView *shine = [[UIView alloc] initWithFrame:host.bounds];
        shine.tag = kWCLG27GlassTag + 2;
        shine.userInteractionEnabled = NO;
        shine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [host addSubview:shine];
    }

    host.frame = frame;
    WCLG27ApplyLayerStyle(host, cornerRadius, alpha);

    for (UIView *sub in host.subviews) {
        sub.frame = host.bounds;
        if (sub.tag == kWCLG27GlassTag + 1 && [sub isKindOfClass:[UIVisualEffectView class]]) {
            ((UIVisualEffectView *)sub).effect = WCLG27CreateEffect();
        } else if (sub.tag == kWCLG27GlassTag + 2) {
            sub.backgroundColor = [WCLG27TintColor() colorWithAlphaComponent:0.12];
        }
    }
    return host;
}

static CGRect WCLG27NavigationBarGlassFrame(UINavigationBar *bar) {
    CGRect b = bar.bounds;
    CGFloat w = CGRectGetWidth(b);
    CGFloat h = CGRectGetHeight(b);
    if (w < 20 || h < 20) return b;

    CGFloat horizontal = 8.0;
    CGFloat targetH = 44.0;

    if (h >= 86.0) {
        targetH = 48.0;
    } else if (h >= 58.0) {
        targetH = 44.0;
    } else {
        targetH = MAX(34.0, h - 6.0);
    }

    targetH = MIN(targetH, h - 4.0);
    CGFloat y = MAX(2.0, h - targetH - 2.0);

    return CGRectMake(horizontal, y, MAX(2.0, w - horizontal * 2.0), targetH);
}

static UITextField *WCLG27FindTextFieldInView(UIView *view, NSInteger depth) {
    if (!view || depth > 6) return nil;
    if ([view isKindOfClass:[UITextField class]]) return (UITextField *)view;
    for (UIView *sub in view.subviews) {
        UITextField *found = WCLG27FindTextFieldInView(sub, depth + 1);
        if (found) return found;
    }
    return nil;
}

static CGRect WCLG27SearchGlassFrame(UIView *view) {
    CGRect b = view.bounds;
    CGFloat w = CGRectGetWidth(b);
    CGFloat h = CGRectGetHeight(b);
    if (w < 20 || h < 20) return b;

    CGFloat horizontal = (w > UIScreen.mainScreen.bounds.size.width * 0.72) ? 12.0 : 4.0;
    CGFloat targetH = MIN(40.0, MAX(30.0, h - 8.0));
    if (h <= 38.0) targetH = MAX(28.0, h - 4.0);

    CGFloat y = (h - targetH) * 0.5;
    return CGRectMake(horizontal, y, MAX(2.0, w - horizontal * 2.0), targetH);
}

static void WCLG27ApplySearchGlass(UIView *view) {
    if (!view || !WCLG27RuntimeEnabled()) return;
    if (!WCLG27Feature(kWCLG27FeatureSearchGlass, NO)) {
        WCLG27RemoveGlassHost(view);
        return;
    }

    UITextField *field = WCLG27FindTextFieldInView(view, 0);
    if (field) {
        field.backgroundColor = [UIColor clearColor];
        field.borderStyle = UITextBorderStyleNone;
        if ([field respondsToSelector:@selector(setLayer:)]) {
            field.layer.cornerRadius = MIN(18.0, CGRectGetHeight(field.bounds) / 2.0);
            field.layer.masksToBounds = NO;
        }
        WCLG27EnsureGlassHostInFrame(field,
                                     CGRectInset(field.bounds, 0.0, 0.0),
                                     MIN(18.0, CGRectGetHeight(field.bounds) / 2.0),
                                     WCLG27FeatureAlpha(kWCLG27StrengthSearch, 0.82));
        return;
    }

    view.backgroundColor = [UIColor clearColor];
    CGRect frame = WCLG27SearchGlassFrame(view);
    WCLG27EnsureGlassHostInFrame(view,
                                 frame,
                                 MIN(18.0, CGRectGetHeight(frame) / 2.0),
                                 WCLG27FeatureAlpha(kWCLG27StrengthSearch, 0.82));
}

static void WCLG27RemoveGlassHost(UIView *target) {
    UIView *host = objc_getAssociatedObject(target, kWCLG27GlassHostKey);
    [host removeFromSuperview];
    objc_setAssociatedObject(target, kWCLG27GlassHostKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

static void WCLG27HideNativeBackgroundSubviews(UIView *view) {
    for (UIView *sub in view.subviews) {
        if (sub.tag == kWCLG27GlassTag || sub.tag == kWCLG27OverlayTag) continue;
        NSString *cls = NSStringFromClass([sub class]);
        if (WCLG27StringContains(cls, @[@"BarBackground", @"Background", @"Backdrop", @"ShadowView", @"SeparatorView"])) {
            sub.alpha = 0.01;
            sub.hidden = YES;
        }
    }
}

static UIWindow *WCLG27KeyWindow(void) {
    UIWindow *key = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState != UISceneActivationStateForegroundActive) continue;
            for (UIWindow *w in windowScene.windows) {
                if (w.isKeyWindow) return w;
                if (!key && !w.hidden && w.alpha > 0.01) key = w;
            }
        }
    }
    if (!key) key = UIApplication.sharedApplication.keyWindow;
    if (!key) key = UIApplication.sharedApplication.windows.firstObject;
    return key;
}

static UIViewController *WCLG27TopViewController(void) {
    UIViewController *vc = WCLG27KeyWindow().rootViewController;
    while (YES) {
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        } else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        } else {
            break;
        }
    }
    return vc;
}

static BOOL WCLG27TitleLooksLikeHome(NSString *title) {
    return [title isEqualToString:@"微信"] || [title isEqualToString:@"WeChat"] || [title isEqualToString:@"Chats"];
}

static BOOL WCLG27IsHomeController(UIViewController *vc) {
    if (!vc) return NO;
    NSString *cls = NSStringFromClass([vc class]);
    NSString *title = vc.navigationItem.title ?: vc.title ?: @"";
    if (WCLG27TitleLooksLikeHome(title)) return YES;
    return WCLG27StringContains(cls, @[@"MainFrame", @"NewMainFrame", @"Session", @"MessageList", @"Home", @"SMSHome"]);
}

static BOOL WCLG27IsMomentsController(UIViewController *vc) {
    if (!vc) return NO;
    NSString *cls = NSStringFromClass([vc class]);
    NSString *title = vc.navigationItem.title ?: vc.title ?: @"";
    if ([title containsString:@"朋友圈"] || [title rangeOfString:@"Moments" options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    return WCLG27StringContains(cls, @[@"Sns", @"Timeline", @"Moment", @"WCContent", @"Album"]);
}

static BOOL WCLG27IsChatController(UIViewController *vc) {
    if (!vc) return NO;
    if (WCLG27IsHomeController(vc) || WCLG27IsMomentsController(vc)) return NO;
    NSString *cls = NSStringFromClass([vc class]);
    NSString *title = vc.navigationItem.title ?: vc.title ?: @"";
    if (title.length == 0 || WCLG27TitleLooksLikeHome(title)) return NO;
    return WCLG27StringContains(cls, @[@"Chat", @"Message", @"MsgContent", @"Conversation", @"BaseMsgContent"]);
}

static void WCLG27SetBackgroundRecursively(UIView *root, UIColor *color, NSInteger depth) {
    if (!root || depth > 7) return;
    if ([root isKindOfClass:[UITableView class]] || [root isKindOfClass:[UICollectionView class]] || [root isKindOfClass:[UIScrollView class]]) {
        root.backgroundColor = [UIColor clearColor];
    }
    if ([root isKindOfClass:[UITableViewCell class]]) {
        root.backgroundColor = [UIColor clearColor];
        UITableViewCell *cell = (UITableViewCell *)root;
        cell.contentView.backgroundColor = [UIColor clearColor];
        UIView *selected = [[UIView alloc] initWithFrame:CGRectZero];
        selected.backgroundColor = [WCLG27TintColor() colorWithAlphaComponent:0.08];
        cell.selectedBackgroundView = selected;
    }
    for (UIView *sub in [root.subviews copy]) WCLG27SetBackgroundRecursively(sub, color, depth + 1);
}

static void WCLG27HideHomeTitleInView(UIView *root, NSInteger depth) {
    if (!root || depth > 7) return;
    CGFloat maxY = 150.0;
    CGRect screenFrame = [root convertRect:root.bounds toView:WCLG27KeyWindow()];
    if (CGRectGetMinY(screenFrame) <= maxY) {
        if ([root isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)root;
            NSString *text = label.text ?: @"";
            if (WCLG27TitleLooksLikeHome(text)) label.alpha = 0.0;
        } else if ([root isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)root;
            NSString *title = [button titleForState:UIControlStateNormal] ?: @"";
            if (WCLG27TitleLooksLikeHome(title)) button.alpha = 0.0;
        }
    }
    for (UIView *sub in [root.subviews copy]) WCLG27HideHomeTitleInView(sub, depth + 1);
}

static void WCLG27HidePinnedBackgroundInView(UIView *root, NSInteger depth) {
    if (!root || depth > 7) return;
    NSString *cls = NSStringFromClass([root class]);
    BOOL maybeSessionCell = [root isKindOfClass:[UITableViewCell class]] || WCLG27StringContains(cls, @[@"Session", @"Contact", @"Conversation", @"MessageCell", @"MMTableViewCell"]);
    BOOL maybePinned = WCLG27StringContains(cls, @[@"Top", @"Sticky", @"Pin", @"Pinned"]);
    if (maybeSessionCell || maybePinned) {
        root.backgroundColor = [UIColor clearColor];
        if ([root isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)root;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            if (!cell.backgroundView) {
                UIView *bg = [[UIView alloc] initWithFrame:CGRectZero];
                bg.backgroundColor = [UIColor clearColor];
                cell.backgroundView = bg;
            } else {
                cell.backgroundView.backgroundColor = [UIColor clearColor];
            }
        }
    }
    for (UIView *sub in [root.subviews copy]) WCLG27HidePinnedBackgroundInView(sub, depth + 1);
}

static BOOL WCLG27SendActionWithSelectors(NSArray<NSString *> *selectorNames, id sender) {
    UIApplication *app = UIApplication.sharedApplication;
    for (NSString *name in selectorNames) {
        SEL sel = NSSelectorFromString(name);
        if ([app sendAction:sel to:nil from:sender forEvent:nil]) return YES;
    }
    return NO;
}


static BOOL WCLG27FocusHomeSearchInputIncludingHidden(void);
static void WCLG27HideOriginalHomeSearchBoxIfNeeded(UIViewController *vc, BOOL hide);

static void WCLG27TriggerSearch(id sender) {
    /*
     搜索替换模式：
     右上角按钮优先代理首页原搜索框，而不是再去猜微信私有 selector。
    */
    if (WCLG27FocusHomeSearchInputIncludingHidden()) return;

    NSArray<NSString *> *selectors = @[
        @"onSearchButtonTapped",
        @"onSearchBarClicked:",
        @"onSearchButtonClicked:",
        @"searchButtonClicked:",
        @"searchButtonClicked",
        @"showSearch",
        @"showSearchController",
        @"openSearch",
        @"openSearchViewController",
        @"startSearch",
        @"enterSearch"
    ];
    if (!WCLG27SendActionWithSelectors(selectors, sender)) {
        WCLG27PresentSettings();
    }
}

static void WCLG27ScanAllWindows(void);
static void WCLG27PresentSettings(void);

static UIButton *WCLG27MakeRoundButton(NSString *title, UIImage *image) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    button.tintColor = [UIColor labelColor];
    [button setTitle:title forState:UIControlStateNormal];
    if (image) [button setImage:image forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.clipsToBounds = NO;
    return button;
}

static void WCLG27LongPressSettings(UILongPressGestureRecognizer *gr) {
    if (gr.state == UIGestureRecognizerStateBegan) WCLG27PresentSettings();
}

static void WCLG27TabSearchTapped(UIButton *button) {
    WCLG27TriggerSearch(button);
}

static void WCLG27ApplyTabRightSearch(UITabBar *tabBar) {
    UIButton *button = objc_getAssociatedObject(tabBar, kWCLG27TabSearchButtonKey);
    if (!WCLG27Feature(kWCLG27FeatureTabRightSearch, NO)) {
        [button removeFromSuperview];
        objc_setAssociatedObject(tabBar, kWCLG27TabSearchButtonKey, nil, OBJC_ASSOCIATION_ASSIGN);
        return;
    }
    if (!button || ![button isDescendantOfView:tabBar]) {
        UIImage *img = nil;
        if (@available(iOS 13.0, *)) img = [UIImage systemImageNamed:@"magnifyingglass"];
        button = WCLG27MakeRoundButton(img ? @"" : @"⌕", img);
        button.tag = kWCLG27SearchButtonTag;
        button.accessibilityLabel = @"WCLiquidGlass27 Search";
        [button addTarget:(id)button action:@selector(wclg27_tabSearchTap) forControlEvents:UIControlEventTouchUpInside];
        [tabBar addSubview:button];
        objc_setAssociatedObject(tabBar, kWCLG27TabSearchButtonKey, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:(id)button action:@selector(wclg27_openSettingsLongPress:)];
        [button addGestureRecognizer:lp];
    }
    CGFloat size = 42.0;
    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) safeBottom = tabBar.safeAreaInsets.bottom;
    button.frame = CGRectMake(CGRectGetWidth(tabBar.bounds) - size - 10.0, 6.0, size, size);
    button.layer.cornerRadius = size / 2.0;
    if (@available(iOS 13.0, *)) button.layer.cornerCurve = kCACornerCurveContinuous;
    button.hidden = CGRectGetHeight(tabBar.bounds) < size + safeBottom;
    UIView *host = WCLG27EnsureGlassHost(button, size / 2.0, 0.92);
    if (host) WCLG27UpdateLiquidLayers(host, 0.92);
}




#pragma mark - WCLG27 Liquid Bottom V2

static NSArray<UIView *> *WCLG27TabBarItemViews(UITabBar *tabBar) {
    NSMutableArray<UIView *> *items = [NSMutableArray array];
    if (!tabBar) return items;

    for (UIView *sub in tabBar.subviews) {
        if (sub.tag == kWCLG27GlassTag || sub.tag == kWCLG27SearchButtonTag || sub.hidden || sub.alpha < 0.05) continue;
        NSString *cls = NSStringFromClass([sub class]);

        if ([cls containsString:@"UITabBarButton"] ||
            [cls containsString:@"TabBarButton"] ||
            [cls containsString:@"TabBarItemView"]) {
            CGRect f = sub.frame;
            if (CGRectGetWidth(f) >= 32 && CGRectGetHeight(f) >= 32) {
                [items addObject:sub];
            }
        }
    }

    [items sortUsingComparator:^NSComparisonResult(UIView *a, UIView *b) {
        CGFloat ax = CGRectGetMinX(a.frame);
        CGFloat bx = CGRectGetMinX(b.frame);
        if (ax < bx) return NSOrderedAscending;
        if (ax > bx) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    return items;
}

static CGRect WCLG27TabBarPlatterRect(UITabBar *tabBar) {
    if (!tabBar || CGRectGetWidth(tabBar.bounds) < 20 || CGRectGetHeight(tabBar.bounds) < 20) return CGRectZero;

    NSArray<UIView *> *items = WCLG27TabBarItemViews(tabBar);
    CGRect unionRect = CGRectNull;
    for (UIView *item in items) {
        CGRect f = item.frame;
        if (CGRectGetWidth(f) < 10 || CGRectGetHeight(f) < 10) continue;
        unionRect = CGRectIsNull(unionRect) ? f : CGRectUnion(unionRect, f);
    }

    CGFloat safeBottom = 0.0;
    if (@available(iOS 11.0, *)) safeBottom = tabBar.safeAreaInsets.bottom;

    CGFloat barW = CGRectGetWidth(tabBar.bounds);
    CGFloat barH = CGRectGetHeight(tabBar.bounds);
    CGFloat contentH = MAX(44.0, barH - safeBottom);
    CGFloat targetH = MIN(56.0, MAX(42.0, contentH - 10.0));
    CGFloat y = MAX(5.0, (contentH - targetH) * 0.5 + 2.0);

    CGRect rect;
    if (!CGRectIsNull(unionRect) && CGRectGetWidth(unionRect) > 80) {
        rect = CGRectInset(unionRect, -12.0, -3.0);
        rect.origin.y = y;
        rect.size.height = targetH;
        CGFloat minX = 8.0;
        CGFloat maxW = barW - minX * 2.0;
        if (WCLG27Feature(kWCLG27FeatureTabRightSearch, NO)) {
            maxW -= 50.0;
        }
        if (CGRectGetMinX(rect) < minX) rect.origin.x = minX;
        if (CGRectGetMaxX(rect) > minX + maxW) rect.size.width = minX + maxW - CGRectGetMinX(rect);
    } else {
        CGFloat margin = WCLG27Feature(kWCLG27FeatureTabRightSearch, NO) ? 62.0 : 8.0;
        rect = CGRectMake(8.0, y, barW - margin - 8.0, targetH);
    }

    if (CGRectGetWidth(rect) < 80) {
        rect = CGRectMake(8.0, y, barW - 16.0, targetH);
    }

    return CGRectIntegral(rect);
}

static CAGradientLayer *WCLG27NamedGradientLayer(UIView *view, NSString *name) {
    for (CALayer *layer in [view.layer.sublayers copy]) {
        if ([layer.name isEqualToString:name] && [layer isKindOfClass:[CAGradientLayer class]]) {
            return (CAGradientLayer *)layer;
        }
    }
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.name = name;
    [view.layer addSublayer:layer];
    return layer;
}

static void WCLG27UpdateLiquidLayers(UIView *host, CGFloat alpha) {
    if (!host) return;

    UIVisualEffectView *blur = nil;
    UIView *tint = nil;
    for (UIView *sub in host.subviews) {
        if (sub.tag == kWCLG27GlassTag + 1 && [sub isKindOfClass:[UIVisualEffectView class]]) blur = (UIVisualEffectView *)sub;
        if (sub.tag == kWCLG27GlassTag + 2) tint = sub;
    }

    if (!blur) {
        blur = [[UIVisualEffectView alloc] initWithEffect:WCLG27CreateEffect()];
        blur.tag = kWCLG27GlassTag + 1;
        blur.userInteractionEnabled = NO;
        [host insertSubview:blur atIndex:0];
    }
    blur.frame = host.bounds;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blur.effect = WCLG27CreateEffect();

    if (!tint) {
        tint = [[UIView alloc] initWithFrame:host.bounds];
        tint.tag = kWCLG27GlassTag + 2;
        tint.userInteractionEnabled = NO;
        [host addSubview:tint];
    }
    tint.frame = host.bounds;
    tint.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tint.backgroundColor = [WCLG27TintColor() colorWithAlphaComponent:0.13 * alpha];

    CAGradientLayer *top = WCLG27NamedGradientLayer(host, @"wclg27_liquid_top_highlight");
    top.frame = CGRectMake(0, 0, CGRectGetWidth(host.bounds), MAX(1.0, CGRectGetHeight(host.bounds) * 0.45));
    top.startPoint = CGPointMake(0.5, 0.0);
    top.endPoint = CGPointMake(0.5, 1.0);
    top.colors = @[
        (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.30 * alpha].CGColor,
        (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.08 * alpha].CGColor,
        (__bridge id)[UIColor clearColor].CGColor
    ];
    top.locations = @[@0.0, @0.42, @1.0];

    CAGradientLayer *side = WCLG27NamedGradientLayer(host, @"wclg27_liquid_side_sheen");
    side.frame = host.bounds;
    side.startPoint = CGPointMake(0.0, 0.5);
    side.endPoint = CGPointMake(1.0, 0.5);
    side.colors = @[
        (__bridge id)[UIColor clearColor].CGColor,
        (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.12 * alpha].CGColor,
        (__bridge id)[UIColor clearColor].CGColor
    ];
    side.locations = @[@0.0, @0.50, @1.0];

    host.layer.borderWidth = 0.55;
    host.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.24 * alpha].CGColor;
}



#pragma mark - WCLG27 Unified Liquid Styling

static UIView *WCLG27ApplyUnifiedLiquidHost(UIView *target, CGRect frame, CGFloat radius, CGFloat alpha, BOOL frameMode) {
    if (!target || CGRectGetWidth(target.bounds) < 2 || CGRectGetHeight(target.bounds) < 2) return nil;

    UIView *host = frameMode
        ? WCLG27EnsureGlassHostInFrame(target, frame, radius, alpha)
        : WCLG27EnsureGlassHost(target, radius, alpha);

    if (!host) return nil;

    WCLG27ApplyLayerStyle(host, radius, alpha);
    WCLG27UpdateLiquidLayers(host, alpha);

    host.layer.shadowColor = [UIColor blackColor].CGColor;
    host.layer.shadowOpacity = 0.12 * alpha;
    host.layer.shadowOffset = CGSizeMake(0, 4);
    host.layer.shadowRadius = 16.0;

    return host;
}

static void WCLG27LiquidClearNativeBackground(UIView *view) {
    if (!view) return;
    view.backgroundColor = [UIColor clearColor];
    if ([view respondsToSelector:@selector(setOpaque:)]) {
        view.opaque = NO;
    }
}


static void WCLG27SuppressNativeTabBarBackgrounds(UITabBar *tabBar, BOOL suppress) {
    if (!tabBar) return;
    for (UIView *sub in tabBar.subviews) {
        if (sub.tag == kWCLG27GlassTag || sub.tag == kWCLG27SearchButtonTag) continue;
        NSString *cls = NSStringFromClass([sub class]);

        BOOL looksBackground = [cls containsString:@"BarBackground"] ||
                               [cls containsString:@"Background"] ||
                               [cls containsString:@"Backdrop"] ||
                               [cls containsString:@"VisualEffect"];

        if (!looksBackground || [cls containsString:@"Button"] || [cls containsString:@"Item"]) continue;

        NSNumber *oldAlpha = objc_getAssociatedObject(sub, @selector(wclg27_tabbar_oldAlpha));
        if (suppress) {
            if (!oldAlpha) objc_setAssociatedObject(sub, @selector(wclg27_tabbar_oldAlpha), @(sub.alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            sub.alpha = 0.02;
        } else if (oldAlpha) {
            sub.alpha = oldAlpha.doubleValue;
            objc_setAssociatedObject(sub, @selector(wclg27_tabbar_oldAlpha), nil, OBJC_ASSOCIATION_ASSIGN);
        }
    }
}

static void WCLG27BringTabBarItemsToFront(UITabBar *tabBar) {
    for (UIView *item in WCLG27TabBarItemViews(tabBar)) {
        [tabBar bringSubviewToFront:item];
    }
    UIButton *search = objc_getAssociatedObject(tabBar, kWCLG27TabSearchButtonKey);
    if (search) [tabBar bringSubviewToFront:search];
}

static void WCLG27ApplyBottomInputForTextInput(UIView *input) {
    if (!input || !WCLG27RuntimeEnabled() || !WCLG27Feature(kWCLG27FeatureInputGlass, NO)) return;
    if (!WCLG27ViewLooksVisibleOnScreen(input)) return;

    UIView *cur = input.superview;
    UIView *candidate = nil;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;

    for (NSInteger i = 0; i < 8 && cur; i++, cur = cur.superview) {
        CGRect s = [cur convertRect:cur.bounds toView:nil];
        CGFloat h = CGRectGetHeight(cur.bounds);
        CGFloat w = CGRectGetWidth(cur.bounds);
        BOOL nearBottom = CGRectGetMaxY(s) > screenH * 0.58;
        if (nearBottom && w > 160 && h >= 32 && h <= 160) {
            candidate = cur;
            NSString *cls = NSStringFromClass([cur class]);
            if (WCLG27StringContains(cls, @[@"Input", @"Tool", @"Chat", @"Composer", @"Bar", @"Text"])) break;
        }
    }

    if (!candidate) return;
    WCLG27ApplyInputGlass(candidate);
}


static void WCLG27ApplyTabBar(UITabBar *tabBar) {
    if (!WCLG27RuntimeEnabled()) return;
    if (!tabBar) return;

    NSNumber *applying = objc_getAssociatedObject(tabBar, @selector(WCLG27ApplyTabBar));
    if (applying.boolValue) return;
    objc_setAssociatedObject(tabBar, @selector(WCLG27ApplyTabBar), @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    @try {
        BOOL glassEnabled = WCLG27Feature(kWCLG27FeatureTabBar, NO);

        if (!glassEnabled) {
            WCLG27SuppressNativeTabBarBackgrounds(tabBar, NO);
            WCLG27RemoveGlassHost(tabBar);
            WCLG27ApplyTabRightSearch(tabBar);
            objc_setAssociatedObject(tabBar, @selector(WCLG27ApplyTabBar), nil, OBJC_ASSOCIATION_ASSIGN);
            return;
        }

        /*
         Precise Liquid TabBar:
         模仿原插件底部液态效果：
         1. 不改 UITabBarAppearance；
         2. 不清空 tabBar 本体；
         3. 不移动系统 item；
         4. 按真实 TabBar item union frame 计算玻璃托盘；
         5. 只弱化系统背景层；
         6. 自建 blur/tint/highlight/sheen/border/shadow 液态托盘。
        */
        tabBar.translucent = YES;
        WCLG27SuppressNativeTabBarBackgrounds(tabBar, YES);

        CGRect rect = WCLG27TabBarPlatterRect(tabBar);
        if (CGRectIsEmpty(rect) || CGRectGetWidth(rect) < 80 || CGRectGetHeight(rect) < 32) {
            objc_setAssociatedObject(tabBar, @selector(WCLG27ApplyTabBar), nil, OBJC_ASSOCIATION_ASSIGN);
            return;
        }

        UIView *host = objc_getAssociatedObject(tabBar, kWCLG27GlassHostKey);
        if (!host || ![host isDescendantOfView:tabBar]) {
            host = [[UIView alloc] initWithFrame:rect];
            host.tag = kWCLG27GlassTag;
            host.userInteractionEnabled = NO;
            host.clipsToBounds = YES;
            host.backgroundColor = [UIColor clearColor];
            host.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            [tabBar insertSubview:host atIndex:0];
            objc_setAssociatedObject(tabBar, kWCLG27GlassHostKey, host, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }

        host.frame = rect;
        host.hidden = NO;
        host.userInteractionEnabled = NO;

        CGFloat radius = MIN(30.0, MAX(18.0, CGRectGetHeight(rect) / 2.0));
        CGFloat alpha = WCLG27FeatureAlpha(kWCLG27StrengthTabBar, 0.90);
        WCLG27ApplyLayerStyle(host, radius, alpha);
        WCLG27UpdateLiquidLayers(host, alpha);

        host.layer.shadowColor = [UIColor blackColor].CGColor;
        host.layer.shadowOpacity = 0.18 * alpha;
        host.layer.shadowOffset = CGSizeMake(0, -2);
        host.layer.shadowRadius = 14.0;

        WCLG27ApplyTabRightSearch(tabBar);
        WCLG27BringTabBarItemsToFront(tabBar);
    } @catch (__unused NSException *exception) {
        WCLG27SuppressNativeTabBarBackgrounds(tabBar, NO);
        WCLG27RemoveGlassHost(tabBar);
    }

    objc_setAssociatedObject(tabBar, @selector(WCLG27ApplyTabBar), nil, OBJC_ASSOCIATION_ASSIGN);
}


static void WCLG27ApplyNavigationBar(UINavigationBar *bar) {
    if (!WCLG27RuntimeEnabled()) return;
    if (!bar) return;

    if (!WCLG27Feature(kWCLG27FeatureNavBar, NO)) {
        WCLG27RemoveGlassHost(bar);
        return;
    }

    /*
     Unified Nav Liquid:
     不再整条铺满，也不反复改系统 appearance。
     只在导航内容区放一块自有液态底板，保留微信导航按钮事件链。
    */
    bar.translucent = YES;

    CGRect frame = WCLG27NavigationBarGlassFrame(bar);
    CGFloat alpha = WCLG27FeatureAlpha(kWCLG27StrengthNavBar, 0.84);
    UIView *host = WCLG27ApplyUnifiedLiquidHost(bar,
                                                frame,
                                                MIN(22.0, CGRectGetHeight(frame) / 2.0),
                                                alpha,
                                                YES);
    if (host) [bar sendSubviewToBack:host];

    for (UIView *sub in bar.subviews) {
        if (sub == host || sub.tag == kWCLG27GlassTag) continue;
        NSString *cls = NSStringFromClass([sub class]);
        if ([cls containsString:@"BarBackground"] || [cls containsString:@"Backdrop"]) {
            NSNumber *oldAlpha = objc_getAssociatedObject(sub, @selector(wclg27_nav_oldAlpha));
            if (!oldAlpha) objc_setAssociatedObject(sub, @selector(wclg27_nav_oldAlpha), @(sub.alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            sub.alpha = 0.05;
        }
    }
}





#pragma mark - WCLG27 Search/Input Behavior Fix

static UIView *WCLG27FindTextInputViewInView(UIView *view, NSInteger depth) {
    if (!view || depth > 9) return nil;
    if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) return view;
    for (UIView *sub in view.subviews) {
        UIView *found = WCLG27FindTextInputViewInView(sub, depth + 1);
        if (found) return found;
    }
    return nil;
}

static BOOL WCLG27ViewLooksVisibleOnScreen(UIView *view) {
    if (!view || view.hidden || view.alpha < 0.05 || !view.window) return NO;
    CGRect screen = [view convertRect:view.bounds toView:nil];
    if (CGRectGetWidth(screen) < 20 || CGRectGetHeight(screen) < 20) return NO;
    return CGRectIntersectsRect(screen, UIScreen.mainScreen.bounds);
}

static UIView *WCLG27FindVisibleSearchInputInView(UIView *view, NSInteger depth) {
    if (!view || depth > 10) return nil;

    NSString *cls = NSStringFromClass([view class]);
    BOOL isInput = [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]];
    BOOL searchHint = WCLG27StringContains(cls, @[@"Search", @"Find", @"UISearch"]) ||
                      WCLG27StringContains(view.accessibilityLabel ?: @"", @[@"搜索", @"Search", @"search"]) ||
                      WCLG27StringContains(view.accessibilityIdentifier ?: @"", @[@"search", @"Search"]);

    if (isInput && WCLG27ViewLooksVisibleOnScreen(view)) {
        UITextField *tf = [view isKindOfClass:[UITextField class]] ? (UITextField *)view : nil;
        NSString *placeholder = tf.placeholder ?: @"";
        if (searchHint ||
            [placeholder containsString:@"搜索"] ||
            [placeholder rangeOfString:@"Search" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return view;
        }
    }

    for (UIView *sub in view.subviews) {
        UIView *found = WCLG27FindVisibleSearchInputInView(sub, depth + 1);
        if (found) return found;
    }
    return nil;
}

static UIView *WCLG27CurrentVisibleSearchInput(void) {
    UIViewController *top = WCLG27TopViewController();
    UIView *found = WCLG27FindVisibleSearchInputInView(top.view, 0);
    if (found) return found;

    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        found = WCLG27FindVisibleSearchInputInView(window, 0);
        if (found) return found;
    }
    return nil;
}

static BOOL WCLG27FocusVisibleSearchInputIfPossible(void) {
    UIView *input = WCLG27CurrentVisibleSearchInput();
    if (!input) return NO;

    if ([input respondsToSelector:@selector(becomeFirstResponder)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [input becomeFirstResponder];
        });
        return YES;
    }
    return NO;
}

static BOOL WCLG27HomePageAlreadyHasSearchBox(UIViewController *vc) {
    if (!vc) return NO;
    UIView *found = WCLG27FindVisibleSearchInputInView(vc.view, 0);
    return found != nil;
}

static BOOL WCLG27InputContainerLooksLikeChatBar(UIView *view, NSString *cls) {
    if (!view || view.hidden || view.alpha < 0.05 || !view.window) return NO;
    CGRect b = view.bounds;
    if (CGRectGetWidth(b) < 180 || CGRectGetHeight(b) < 34 || CGRectGetHeight(b) > 150) return NO;

    CGRect screen = [view convertRect:view.bounds toView:nil];
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    BOOL nearBottom = CGRectGetMaxY(screen) > screenH * 0.62;
    if (!nearBottom) return NO;

    UIView *input = WCLG27FindTextInputViewInView(view, 0);
    if (input) return YES;

    return WCLG27StringContains(cls, @[@"Input", @"Tool", @"Chat", @"Composer", @"Text", @"Message"]);
}

static CGRect WCLG27InputGlassFrameForContainer(UIView *container) {
    CGRect b = container.bounds;
    CGFloat w = CGRectGetWidth(b);
    CGFloat h = CGRectGetHeight(b);
    if (w < 30 || h < 20) return b;

    CGFloat left = 6.0;
    CGFloat right = 6.0;
    CGFloat targetH = MIN(42.0, MAX(32.0, h - 8.0));
    CGFloat y = (h - targetH) * 0.5;

    return CGRectMake(left, y, MAX(2.0, w - left - right), targetH);
}

static void WCLG27ApplyInputGlass(UIView *view) {
    if (!view || !WCLG27RuntimeEnabled()) return;
    if (!WCLG27Feature(kWCLG27FeatureInputGlass, NO)) {
        WCLG27RemoveGlassHost(view);
        return;
    }

    UIView *input = WCLG27FindTextInputViewInView(view, 0);
    UIView *container = input.superview ?: input ?: view;

    if (input) {
        WCLG27LiquidClearNativeBackground(input);
        input.layer.masksToBounds = NO;
        if ([input isKindOfClass:[UITextField class]]) {
            ((UITextField *)input).borderStyle = UITextBorderStyleNone;
        }
    }

    if (!container || CGRectGetWidth(container.bounds) < 40 || CGRectGetHeight(container.bounds) < 24) {
        container = view;
    }

    WCLG27LiquidClearNativeBackground(container);
    CGRect frame = WCLG27InputGlassFrameForContainer(container);
    CGFloat alpha = WCLG27FeatureAlpha(kWCLG27StrengthInput, 0.86);
    UIView *host = WCLG27ApplyUnifiedLiquidHost(container,
                                                frame,
                                                MIN(22.0, CGRectGetHeight(frame) / 2.0),
                                                alpha,
                                                YES);
    if (host) [container sendSubviewToBack:host];
}


static BOOL WCLG27IsInputToolLike(UIView *view, NSString *cls) {
    if (!view || view.hidden || view.alpha < 0.05) return NO;
    CGRect b = view.bounds;
    if (CGRectGetWidth(b) < 120 || CGRectGetHeight(b) < 34 || CGRectGetHeight(b) > 150) return NO;

    if (WCLG27InputContainerLooksLikeChatBar(view, cls)) return YES;

    return WCLG27StringContains(cls, @[@"InputTool", @"InputBar", @"ChatInput", @"ToolView", @"ToolBar", @"SmileyPanel", @"Keyboard", @"Composer"]);
}

static BOOL WCLG27IsSearchLike(UIView *view, NSString *cls) {
    if (!view || view.hidden || view.alpha < 0.05) return NO;
    CGRect b = view.bounds;
    if (CGRectGetWidth(b) < 100 || CGRectGetHeight(b) < 28 || CGRectGetHeight(b) > 85) return NO;
    return WCLG27StringContains(cls, @[@"SearchBar", @"SearchView", @"SearchField", @"SearchCell", @"UISearch"]);
}

static BOOL WCLG27IsBubbleLike(UIView *view, NSString *cls) {
    if (!view || view.hidden || view.alpha < 0.05) return NO;
    if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UITableView class]] || [view isKindOfClass:[UICollectionView class]]) return NO;
    CGRect b = view.bounds;
    if (CGRectGetWidth(b) < 48 || CGRectGetHeight(b) < 24 || CGRectGetWidth(b) > UIScreen.mainScreen.bounds.size.width * 0.90) return NO;
    return WCLG27StringContains(cls, @[@"Bubble", @"MessageContent", @"MsgContent", @"ChatContent", @"MessageWrap", @"RichCard", @"Emoticon", @"PayCard"]);
}



#pragma mark - WCLG27 Bubble/Card Liquid

static BOOL WCLG27CanApplyBubbleLiquid(UIView *view) {
    if (!view || view.hidden || view.alpha < 0.05) return NO;
    if ([view isKindOfClass:[UILabel class]] ||
        [view isKindOfClass:[UIButton class]] ||
        [view isKindOfClass:[UIImageView class]] ||
        [view isKindOfClass:[UITableView class]] ||
        [view isKindOfClass:[UICollectionView class]] ||
        [view isKindOfClass:[UIScrollView class]]) return NO;

    CGRect b = view.bounds;
    CGFloat w = CGRectGetWidth(b);
    CGFloat h = CGRectGetHeight(b);
    if (w < 48 || h < 24 || w > UIScreen.mainScreen.bounds.size.width * 0.88 || h > 240) return NO;
    return YES;
}

static void WCLG27ApplyBubbleLiquid(UIView *view) {
    if (!WCLG27CanApplyBubbleLiquid(view)) return;

    WCLG27LiquidClearNativeBackground(view);
    CGFloat alpha = WCLG27FeatureAlpha(kWCLG27StrengthBubble, 0.70);
    CGFloat radius = MIN(18.0, MAX(12.0, CGRectGetHeight(view.bounds) * 0.28));
    UIView *host = WCLG27ApplyUnifiedLiquidHost(view,
                                                CGRectInset(view.bounds, 0.0, 0.0),
                                                radius,
                                                alpha,
                                                YES);
    if (host) [view sendSubviewToBack:host];
}


static void WCLG27ApplyGenericView(UIView *view) {
    if (!view || view.tag == kWCLG27GlassTag || [view isKindOfClass:[UIVisualEffectView class]]) return;
    NSString *cls = NSStringFromClass([view class]);

    if ([view isKindOfClass:[UITabBar class]]) {
        WCLG27ApplyTabBar((UITabBar *)view);
        return;
    }
    if ([view isKindOfClass:[UINavigationBar class]]) {
        WCLG27ApplyNavigationBar((UINavigationBar *)view);
        return;
    }

    if (WCLG27Feature(kWCLG27FeatureInputGlass, NO) && WCLG27IsInputToolLike(view, cls)) {
        WCLG27ApplyInputGlass(view);
    } else if (WCLG27Feature(kWCLG27FeatureSearchGlass, NO) && WCLG27IsSearchLike(view, cls)) {
        WCLG27ApplySearchGlass(view);
    } else if (WCLG27Feature(kWCLG27FeatureBubbleGlass, NO) && WCLG27IsBubbleLike(view, cls)) {
        WCLG27ApplyBubbleLiquid(view);
    }
}

static void WCLG27ScanViewTree(UIView *root, NSInteger depth) {
    if (!WCLG27RuntimeEnabled()) return;
    if (!root || depth > 7) return;
    WCLG27ApplyGenericView(root);
    NSArray<UIView *> *children = [root.subviews copy];
    for (UIView *sub in children) {
        if (sub.tag == kWCLG27GlassTag || sub.tag == kWCLG27GlassTag + 1 || sub.tag == kWCLG27GlassTag + 2 || sub.tag == kWCLG27SearchButtonTag || sub.tag == kWCLG27HomeSearchButtonTag) continue;
        WCLG27ScanViewTree(sub, depth + 1);
    }
}



#pragma mark - WCLG27 Search Replace Mode

static BOOL WCLG27ViewLooksLikeSearchBoxContainer(UIView *view) {
    if (!view) return NO;
    NSString *cls = NSStringFromClass([view class]);
    if (WCLG27StringContains(cls, @[@"SearchBar", @"SearchView", @"SearchField", @"SearchCell", @"UISearch"])) return YES;
    if (WCLG27StringContains(view.accessibilityLabel ?: @"", @[@"搜索", @"Search", @"search"])) return YES;
    if (WCLG27StringContains(view.accessibilityIdentifier ?: @"", @[@"search", @"Search"])) return YES;
    return NO;
}

static UIView *WCLG27FindSearchInputAnyVisibilityInView(UIView *view, NSInteger depth) {
    if (!view || depth > 10) return nil;
    BOOL isInput = [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]];
    if (isInput) {
        UITextField *tf = [view isKindOfClass:[UITextField class]] ? (UITextField *)view : nil;
        NSString *placeholder = tf.placeholder ?: @"";
        NSString *cls = NSStringFromClass([view class]);
        if ([placeholder containsString:@"搜索"] ||
            [placeholder rangeOfString:@"Search" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            WCLG27StringContains(cls, @[@"Search", @"UISearch"])) {
            return view;
        }
    }
    for (UIView *sub in view.subviews) {
        UIView *found = WCLG27FindSearchInputAnyVisibilityInView(sub, depth + 1);
        if (found) return found;
    }
    return nil;
}

static UIView *WCLG27FindSearchContainerFromInput(UIView *input) {
    UIView *cur = input;
    for (NSInteger i = 0; i < 6 && cur.superview; i++) {
        if (WCLG27ViewLooksLikeSearchBoxContainer(cur)) return cur;
        CGRect b = cur.bounds;
        CGFloat w = CGRectGetWidth(b);
        CGFloat h = CGRectGetHeight(b);
        if (w > 120 && h >= 28 && h <= 70 && WCLG27ViewLooksLikeSearchBoxContainer(cur.superview)) {
            return cur.superview;
        }
        cur = cur.superview;
    }
    return input ?: nil;
}

static UIView *WCLG27CurrentHomeSearchInputAnyVisibility(void) {
    UIViewController *top = WCLG27TopViewController();
    UIView *found = WCLG27FindSearchInputAnyVisibilityInView(top.view, 0);
    if (found) return found;

    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        found = WCLG27FindSearchInputAnyVisibilityInView(window, 0);
        if (found) return found;
    }
    return nil;
}

static BOOL WCLG27FocusHomeSearchInputIncludingHidden(void) {
    UIView *input = WCLG27CurrentHomeSearchInputAnyVisibility();
    if (!input) return NO;

    UIView *container = WCLG27FindSearchContainerFromInput(input);
    NSNumber *oldAlpha = objc_getAssociatedObject(container, @selector(wclg27_originalSearchAlpha));
    if (oldAlpha) {
        // 临时恢复一点点透明度以保证 becomeFirstResponder 更稳，然后继续保持视觉隐藏。
        container.alpha = 0.02;
        container.hidden = NO;
    }

    if ([input respondsToSelector:@selector(becomeFirstResponder)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [input becomeFirstResponder];
        });
        return YES;
    }
    return NO;
}

static void WCLG27HideOriginalHomeSearchBoxIfNeeded(UIViewController *vc, BOOL hide) {
    if (!vc || !WCLG27IsHomeController(vc)) return;
    UIView *input = WCLG27FindSearchInputAnyVisibilityInView(vc.view, 0);
    if (!input) return;
    UIView *container = WCLG27FindSearchContainerFromInput(input);
    if (!container) return;

    if (hide) {
        if (!objc_getAssociatedObject(container, @selector(wclg27_originalSearchAlpha))) {
            objc_setAssociatedObject(container, @selector(wclg27_originalSearchAlpha), @(container.alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(container, @selector(wclg27_originalSearchUserInteraction), @(container.userInteractionEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        /*
         不使用 hidden=YES，也不从父视图移除。
         这样保留微信原搜索控件和事件链，只做视觉隐藏，
         右上角按钮点击时仍可把焦点转给原搜索框。
        */
        container.alpha = 0.02;
        container.userInteractionEnabled = NO;
    } else {
        NSNumber *oldAlpha = objc_getAssociatedObject(container, @selector(wclg27_originalSearchAlpha));
        NSNumber *oldUI = objc_getAssociatedObject(container, @selector(wclg27_originalSearchUserInteraction));
        if (oldAlpha) container.alpha = oldAlpha.doubleValue;
        if (oldUI) container.userInteractionEnabled = oldUI.boolValue;
        objc_setAssociatedObject(container, @selector(wclg27_originalSearchAlpha), nil, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(container, @selector(wclg27_originalSearchUserInteraction), nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

static void WCLG27InstallHomeSearchButton(UIViewController *vc) {
    if (!vc || !WCLG27IsHomeController(vc)) return;
    UIBarButtonItem *item = objc_getAssociatedObject(vc, kWCLG27HomeSearchItemKey);

    if (!WCLG27Feature(kWCLG27FeatureHomeSearchButton, NO)) {
        WCLG27HideOriginalHomeSearchBoxIfNeeded(vc, NO);
        if (item) {
            NSMutableArray *items = [NSMutableArray arrayWithArray:vc.navigationItem.rightBarButtonItems ?: @[]];
            [items removeObject:item];
            vc.navigationItem.rightBarButtonItems = items;
        }
        return;
    }

    // 开启“首页右上角搜索按钮”时，用右上角按钮替代首页原搜索框。
    WCLG27HideOriginalHomeSearchBoxIfNeeded(vc, YES);

    if (!item) {
        UIImage *img = nil;
        if (@available(iOS 13.0, *)) img = [UIImage systemImageNamed:@"magnifyingglass"];
        UIButton *button = WCLG27MakeRoundButton(img ? @"" : @"搜", img);
        button.tag = kWCLG27HomeSearchButtonTag;
        button.frame = CGRectMake(0, 0, 36, 36);
        button.layer.cornerRadius = 18;
        [button addTarget:(id)button action:@selector(wclg27_tabSearchTap) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:(id)button action:@selector(wclg27_openSettingsLongPress:)];
        [button addGestureRecognizer:lp];
        WCLG27EnsureGlassHost(button, 18, 0.90);
        item = [[UIBarButtonItem alloc] initWithCustomView:button];
        objc_setAssociatedObject(vc, kWCLG27HomeSearchItemKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSMutableArray *items = [NSMutableArray arrayWithArray:vc.navigationItem.rightBarButtonItems ?: @[]];
    if (![items containsObject:item]) {
        [items insertObject:item atIndex:0];
        vc.navigationItem.rightBarButtonItems = items;
    }
}

static UIView *WCLG27MakeTitleCapsuleView(NSString *title) {
    CGFloat width = WCLG27_CLAMP(title.length * 17.0 + 48.0, 112.0, 236.0);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 38)];
    view.userInteractionEnabled = YES;
    view.clipsToBounds = NO;
    view.backgroundColor = [UIColor clearColor];

    UIView *glass = [[UIView alloc] initWithFrame:view.bounds];
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.userInteractionEnabled = NO;
    glass.backgroundColor = [UIColor clearColor];
    [view addSubview:glass];

    UIView *host = WCLG27EnsureGlassHost(glass, 19.0, WCLG27FeatureAlpha(kWCLG27StrengthTitle, 0.92));
    if (host) WCLG27UpdateLiquidLayers(host, WCLG27FeatureAlpha(kWCLG27StrengthTitle, 0.92));

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.bounds, 18, 0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.78;
    if (@available(iOS 13.0, *)) label.textColor = [UIColor labelColor]; else label.textColor = [UIColor blackColor];
    [view addSubview:label];

    return view;
}


static void WCLG27InstallChatTitleCapsule(UIViewController *vc) {
    if (!vc) return;
    if (!WCLG27Feature(kWCLG27FeatureChatTitleCapsule, NO)) {
        id original = objc_getAssociatedObject(vc, kWCLG27OriginalTitleViewKey);
        if (original) vc.navigationItem.titleView = [original isKindOfClass:[NSNull class]] ? nil : original;
        return;
    }
    if (!WCLG27IsChatController(vc)) return;
    NSString *title = vc.navigationItem.title ?: vc.title ?: @"";
    if (title.length == 0) return;
    if (!objc_getAssociatedObject(vc, kWCLG27OriginalTitleViewKey)) {
        objc_setAssociatedObject(vc, kWCLG27OriginalTitleViewKey, vc.navigationItem.titleView ?: [NSNull null], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UIView *capsule = objc_getAssociatedObject(vc, kWCLG27TitleCapsuleKey);
    UILabel *label = nil;
    for (UIView *sub in capsule.subviews) if ([sub isKindOfClass:[UILabel class]]) label = (UILabel *)sub;
    if (!capsule || ![label.text isEqualToString:title]) {
        capsule = WCLG27MakeTitleCapsuleView(title);
        objc_setAssociatedObject(vc, kWCLG27TitleCapsuleKey, capsule, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    vc.navigationItem.titleView = capsule;
}

static void WCLG27ApplyMomentsNavigation(UIViewController *vc) {
    if (!WCLG27Feature(kWCLG27FeatureMomentsNav, NO) || !WCLG27IsMomentsController(vc)) return;
    UINavigationBar *bar = vc.navigationController.navigationBar;
    if (!bar) return;

    bar.translucent = YES;
    CGRect frame = WCLG27NavigationBarGlassFrame(bar);
    CGFloat alpha = WCLG27FeatureAlpha(kWCLG27StrengthMoments, 0.96);
    UIView *host = WCLG27ApplyUnifiedLiquidHost(bar,
                                                frame,
                                                MIN(24.0, CGRectGetHeight(frame) / 2.0),
                                                alpha,
                                                YES);
    if (host) [bar sendSubviewToBack:host];

    if (@available(iOS 13.0, *)) {
        bar.tintColor = [UIColor labelColor];
        bar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor labelColor], NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]};
    }
}


static void WCLG27ApplyControllerSpecificTweaks(UIViewController *vc) {
    if (!WCLG27RuntimeEnabled()) return;
    if (!vc || !WCLG27Enabled()) return;
    if (WCLG27IsHomeController(vc)) {
        if (WCLG27Feature(kWCLG27FeatureHomePureBG, NO)) {
            UIColor *bg = WCLG27HomeBackgroundColor();
            vc.view.backgroundColor = bg;
            WCLG27SetBackgroundRecursively(vc.view, bg, 0);
        }
        if (WCLG27Feature(kWCLG27FeatureHideHomeTitle, NO)) {
            if (!objc_getAssociatedObject(vc, kWCLG27OriginalHomeTitleKey)) objc_setAssociatedObject(vc, kWCLG27OriginalHomeTitleKey, vc.title ?: @"", OBJC_ASSOCIATION_COPY_NONATOMIC);
            if (!objc_getAssociatedObject(vc, kWCLG27OriginalHomeNavTitleKey)) objc_setAssociatedObject(vc, kWCLG27OriginalHomeNavTitleKey, vc.navigationItem.title ?: @"", OBJC_ASSOCIATION_COPY_NONATOMIC);
            vc.navigationItem.title = @"";
            vc.title = @"";
            WCLG27HideHomeTitleInView(vc.view, 0);
            WCLG27HideHomeTitleInView(vc.navigationController.navigationBar, 0);
        } else {
            NSString *oldTitle = objc_getAssociatedObject(vc, kWCLG27OriginalHomeTitleKey);
            NSString *oldNavTitle = objc_getAssociatedObject(vc, kWCLG27OriginalHomeNavTitleKey);
            if (oldTitle.length) vc.title = oldTitle;
            if (oldNavTitle.length) vc.navigationItem.title = oldNavTitle;
        }
        if (WCLG27Feature(kWCLG27FeatureHidePinnedBG, NO)) {
            WCLG27HidePinnedBackgroundInView(vc.view, 0);
        }
        WCLG27InstallHomeSearchButton(vc);
    }
    WCLG27InstallChatTitleCapsule(vc);
    WCLG27ApplyMomentsNavigation(vc);
}

static void WCLG27ScanWindow(UIWindow *window) {
    if (!WCLG27RuntimeMayScan()) return;
    if (!WCLG27RuntimeEnabled()) return;
    if (!WCLG27Enabled() || !window) return;
    NSNumber *last = objc_getAssociatedObject(window, kWCLG27LastScanKey);
    NSTimeInterval now = CACurrentMediaTime();
    if (last && now - last.doubleValue < 0.16) return;
    objc_setAssociatedObject(window, kWCLG27LastScanKey, @(now), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    WCLG27ScanViewTree(window, 0);
    WCLG27ApplyControllerSpecificTweaks(WCLG27TopViewController());
}

static void WCLG27ScanAllWindows(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIWindow *window in UIApplication.sharedApplication.windows) WCLG27ScanWindow(window);
    });
}





#pragma mark - WCLG27 Crash Guard

static NSString * const kWCLG27BootingKey = @"wclg27_booting_previous_launch";
static NSString * const kWCLG27LastCrashGuardKey = @"wclg27_last_crash_guard_time";
static NSString * const kWCLG27SafeNoticeKey = @"wclg27_safe_notice_pending";

static void WCLG27DisableAllPrefsForCrashGuard(void) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSArray *keys = @[
        @"wclg27_enabled",
        @"wclg27_feature_tabbar",
        @"wclg27_feature_navbar",
        @"wclg27_feature_search_glass",
        @"wclg27_feature_input_glass",
        @"wclg27_feature_bubble_glass",
        @"wclg27_feature_chat_title_capsule",
        @"wclg27_feature_moments_nav",
        @"wclg27_feature_hide_home_title",
        @"wclg27_feature_tab_right_search",
        @"wclg27_feature_home_search_button",
        @"wclg27_feature_home_pure_bg",
        @"wclg27_feature_hide_pinned_bg"
    ];
    for (NSString *key in keys) {
        [d setBool:NO forKey:key];
    }
    [d setBool:YES forKey:kWCLG27SafeNoticeKey];
    [d setObject:@(NSDate.date.timeIntervalSince1970) forKey:kWCLG27LastCrashGuardKey];
    [d synchronize];
}

static void WCLG27CrashGuardBeginLaunch(void) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([d boolForKey:kWCLG27BootingKey]) {
        WCLG27DisableAllPrefsForCrashGuard();
    }
    [d setBool:YES forKey:kWCLG27BootingKey];
    [d synchronize];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kWCLG27BootingKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

static void WCLG27ShowCrashGuardNoticeIfNeeded(void) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (![d boolForKey:kWCLG27SafeNoticeKey]) return;
    [d setBool:NO forKey:kWCLG27SafeNoticeKey];
    [d synchronize];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *top = WCLG27TopViewController();
        if (!top) return;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"LiquidGlass 已进入安全模式"
                                                                       message:@"检测到上次启动可能因为插件设置导致微信异常退出，已自动关闭总开关和所有子功能。请进入设置后只先开启 TabBar / 顶栏这类低风险功能。"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
        [top presentViewController:alert animated:YES completion:nil];
    });
}

static BOOL WCLG27AnyFeatureEnabled(void) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSArray *keys = @[
        @"wclg27_feature_tabbar",
        @"wclg27_feature_navbar",
        @"wclg27_feature_search_glass",
        @"wclg27_feature_input_glass",
        @"wclg27_feature_bubble_glass",
        @"wclg27_feature_chat_title_capsule",
        @"wclg27_feature_moments_nav",
        @"wclg27_feature_hide_home_title",
        @"wclg27_feature_tab_right_search",
        @"wclg27_feature_home_search_button",
        @"wclg27_feature_home_pure_bg",
        @"wclg27_feature_hide_pinned_bg"
    ];
    for (NSString *key in keys) {
        if ([d boolForKey:key]) return YES;
    }
    return NO;
}

static BOOL WCLG27RuntimeMayScan(void) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (![d boolForKey:@"wclg27_enabled"]) return NO;
    return WCLG27AnyFeatureEnabled();
}


#pragma mark - WCLG27 Safe Mode Patch

static NSString * const kWCLG27SafeModeKey = @"wclg27_safe_mode";
static NSString * const kWCLG27ManualScanRequestedKey = @"wclg27_manual_scan_requested";

static BOOL WCLG27FileExists(NSString *path) {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

static BOOL WCLG27ExternalDisableRequested(void) {
    NSArray<NSString *> *paths = @[
        @"/var/mobile/Library/Preferences/wclg27_disable",
        @"/var/mobile/Library/Preferences/wcliquidglass27_disable",
        @"/var/mobile/Documents/wclg27_disable"
    ];
    for (NSString *path in paths) {
        if (WCLG27FileExists(path)) return YES;
    }
    return NO;
}

/*
 安全启动策略：
 1. 第一次安装默认不启用美化，防止微信启动页直接卡死；
 2. 如果用户手动设置了 wclg27_enabled=YES，才启用；
 3. 外部存在 disable 文件时强制不启用；
 4. 注册插件管理入口不受影响，保证能进设置页开启/关闭。
*/
static BOOL WCLG27RuntimeEnabled(void) {
    if (WCLG27ExternalDisableRequested()) return NO;
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:@"wclg27_enabled"];
    if (!value) return NO;
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"wclg27_enabled"];
}


#pragma mark - Settings UI

static UIColor *WCLG27SettingsAccentColor(void) {
    return [UIColor colorWithRed:0.16 green:0.74 blue:1.0 alpha:1.0];
}

static UIColor *WCLG27SettingsPurpleColor(void) {
    return [UIColor colorWithRed:0.64 green:0.38 blue:1.0 alpha:1.0];
}

static UIColor *WCLG27SettingsCardColor(void) {
    return [UIColor colorWithWhite:1.0 alpha:0.085];
}

static UIColor *WCLG27SettingsTextColor(void) {
    return [UIColor colorWithWhite:1.0 alpha:0.96];
}

static UIColor *WCLG27SettingsSubTextColor(void) {
    return [UIColor colorWithWhite:1.0 alpha:0.62];
}

static UIVisualEffect *WCLG27DarkGlassEffect(void) {
    if (@available(iOS 13.0, *)) return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
}

@interface WCLG27SettingsGradientView : UIView
@end
@implementation WCLG27SettingsGradientView
+ (Class)layerClass { return [CAGradientLayer class]; }
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAGradientLayer *g = (CAGradientLayer *)self.layer;
        g.startPoint = CGPointMake(0.08, 0.0);
        g.endPoint = CGPointMake(0.95, 1.0);
        g.colors = @[
            (id)[UIColor colorWithRed:0.04 green:0.06 blue:0.12 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.10 green:0.07 blue:0.20 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.02 green:0.09 blue:0.14 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.01 green:0.02 blue:0.05 alpha:1.0].CGColor
        ];
        g.locations = @[@0.0, @0.34, @0.72, @1.0];
    }
    return self;
}
@end

@interface WCLG27SliderCell : UITableViewCell
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, copy) NSString *prefKey;
@end

@implementation WCLG27SliderCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        self.textLabel.textColor = WCLG27SettingsTextColor();
        self.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        self.detailTextLabel.textColor = WCLG27SettingsSubTextColor();
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightSemibold];
        self.valueLabel.textAlignment = NSTextAlignmentRight;
        self.valueLabel.textColor = WCLG27SettingsAccentColor();
        [self.contentView addSubview:self.valueLabel];
        self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
        self.slider.minimumValue = 0.0;
        self.slider.maximumValue = 1.0;
        self.slider.minimumTrackTintColor = WCLG27SettingsAccentColor();
        self.slider.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.18];
        [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.slider];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.contentView.bounds);
    self.valueLabel.frame = CGRectMake(w - 88, 11, 70, 22);
    self.slider.frame = CGRectMake(20, 53, w - 40, 28);
}
- (void)setPrefKey:(NSString *)prefKey {
    _prefKey = [prefKey copy];
    self.slider.value = WCLG27Float(_prefKey, 0.86);
    [self updateValueText];
}
- (void)sliderChanged:(UISlider *)slider {
    WCLG27SetFloat(self.prefKey, slider.value);
    [self updateValueText];
    if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
}
- (void)updateValueText {
    self.valueLabel.text = [NSString stringWithFormat:@"%d%%", (int)round(self.slider.value * 100.0)];
}
@end

@interface WCLG27ColorPickerFallbackController : UIViewController
@property (nonatomic, copy) NSString *colorKey;
@property (nonatomic, strong) UIColor *initialColor;
@property (nonatomic, strong) UISlider *r;
@property (nonatomic, strong) UISlider *g;
@property (nonatomic, strong) UISlider *b;
@property (nonatomic, strong) UISlider *a;
@property (nonatomic, strong) UIView *preview;
@end

@implementation WCLG27ColorPickerFallbackController
- (instancetype)initWithKey:(NSString *)key title:(NSString *)title color:(UIColor *)color {
    self = [super init];
    if (self) {
        self.colorKey = key;
        self.title = title;
        self.initialColor = color;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    WCLG27SettingsGradientView *bg = [[WCLG27SettingsGradientView alloc] initWithFrame:self.view.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:bg];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationController.navigationBar.tintColor = WCLG27SettingsAccentColor();
    CGFloat r=1,g=1,b=1,a=1;
    [self.initialColor getRed:&r green:&g blue:&b alpha:&a];
    self.preview = [[UIView alloc] initWithFrame:CGRectMake(24, 116, CGRectGetWidth(self.view.bounds)-48, 74)];
    self.preview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.preview.layer.cornerRadius = 22;
    if (@available(iOS 13.0, *)) self.preview.layer.cornerCurve = kCACornerCurveContinuous;
    self.preview.layer.borderWidth = 0.6;
    self.preview.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.28] CGColor];
    [self.view addSubview:self.preview];
    self.r = [self makeSlider:r y:246 text:@"红色 R"];
    self.g = [self makeSlider:g y:306 text:@"绿色 G"];
    self.b = [self makeSlider:b y:366 text:@"蓝色 B"];
    self.a = [self makeSlider:a y:426 text:@"透明 A"];
    [self updatePreview];
}
- (UISlider *)makeSlider:(CGFloat)value y:(CGFloat)y text:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, y-28, 160, 22)];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    label.textColor = WCLG27SettingsTextColor();
    [self.view addSubview:label];
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(24, y, CGRectGetWidth(self.view.bounds)-48, 32)];
    slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    slider.value = value;
    slider.minimumTrackTintColor = WCLG27SettingsAccentColor();
    slider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.18];
    [slider addTarget:self action:@selector(updatePreview) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    return slider;
}
- (void)updatePreview {
    self.preview.backgroundColor = [UIColor colorWithRed:self.r.value green:self.g.value blue:self.b.value alpha:self.a.value];
}
- (void)done {
    UIColor *color = [UIColor colorWithRed:self.r.value green:self.g.value blue:self.b.value alpha:self.a.value];
    WCLG27SetColorForKey(self.colorKey, color);
    if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
    [self.navigationController popViewControllerAnimated:YES];
}
@end

@interface WCLG27SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIColorPickerViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, copy) NSString *pickingColorKey;
@end

@implementation WCLG27SettingsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    self.view.backgroundColor = [UIColor blackColor];

    self.backgroundView = [[WCLG27SettingsGradientView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backgroundView];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    self.navigationController.navigationBar.tintColor = WCLG27SettingsAccentColor();
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *ap = [[UINavigationBarAppearance alloc] init];
        [ap configureWithTransparentBackground];
        ap.backgroundColor = [UIColor clearColor];
        ap.titleTextAttributes = @{NSForegroundColorAttributeName: WCLG27SettingsTextColor()};
        self.navigationController.navigationBar.standardAppearance = ap;
        self.navigationController.navigationBar.scrollEdgeAppearance = ap;
        self.navigationController.navigationBar.compactAppearance = ap;
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
    }

    UITableViewStyle style = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) style = UITableViewStyleInsetGrouped;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:style];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerClass:[WCLG27SliderCell class] forCellReuseIdentifier:@"slider"];
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = [self makeHeaderViewWithWidth:CGRectGetWidth(self.view.bounds)];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *header = self.tableView.tableHeaderView;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (fabs(CGRectGetWidth(header.frame) - width) > 1.0) {
        self.tableView.tableHeaderView = [self makeHeaderViewWithWidth:width];
    }
}
- (UIView *)makeHeaderViewWithWidth:(CGFloat)width {
    CGFloat safeWidth = MAX(width, 320.0);
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, safeWidth, 246)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *eyebrow = [[UILabel alloc] initWithFrame:CGRectMake(24, 10, safeWidth - 48, 18)];
    eyebrow.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    eyebrow.textColor = [WCLG27SettingsAccentColor() colorWithAlphaComponent:0.85];
    eyebrow.attributedText = [[NSAttributedString alloc] initWithString:@"WECHAT LIQUIDGLASS" attributes:@{NSKernAttributeName: @1.2}];
    [header addSubview:eyebrow];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(24, 30, safeWidth - 48, 44)];
    title.text = @"LiquidGlass 设置";
    title.font = [UIFont systemFontOfSize:34 weight:UIFontWeightHeavy];
    title.textColor = WCLG27SettingsTextColor();
    [header addSubview:title];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(24, 74, safeWidth - 48, 24)];
    sub.text = @"iOS 26 / iOS 27 风格 · 微信 UI 美化";
    sub.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    sub.textColor = WCLG27SettingsSubTextColor();
    [header addSubview:sub];

    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(18, 112, safeWidth - 36, 116)];
    card.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    card.clipsToBounds = YES;
    card.layer.cornerRadius = 26;
    if (@available(iOS 13.0, *)) card.layer.cornerCurve = kCACornerCurveContinuous;
    card.layer.borderWidth = 0.7;
    card.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.24] CGColor];
    [header addSubview:card];

    UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:WCLG27DarkGlassEffect()];
    blur.frame = card.bounds;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [card addSubview:blur];

    CAGradientLayer *shine = [CAGradientLayer layer];
    shine.frame = card.bounds;
    shine.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.18].CGColor,
        (id)[WCLG27SettingsPurpleColor() colorWithAlphaComponent:0.10].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.04].CGColor
    ];
    shine.startPoint = CGPointMake(0.0, 0.0);
    shine.endPoint = CGPointMake(1.0, 1.0);
    [card.layer insertSublayer:shine above:blur.layer];

    UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, 54, 54)];
    logo.text = @"LG";
    logo.textAlignment = NSTextAlignmentCenter;
    logo.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBlack];
    logo.textColor = [UIColor whiteColor];
    logo.backgroundColor = [WCLG27SettingsAccentColor() colorWithAlphaComponent:0.28];
    logo.layer.cornerRadius = 18;
    logo.clipsToBounds = YES;
    logo.layer.borderWidth = 0.6;
    logo.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.32] CGColor];
    [card addSubview:logo];

    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(88, 20, CGRectGetWidth(card.bounds)-106, 26)];
    name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    name.text = @"WeChat LiquidGlass 27";
    name.font = [UIFont systemFontOfSize:19 weight:UIFontWeightBold];
    name.textColor = WCLG27SettingsTextColor();
    [card addSubview:name];

    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(88, 48, CGRectGetWidth(card.bounds)-106, 22)];
    info.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    info.text = @"独立重写版 · 无联网授权 · 可单项开关";
    info.font = [UIFont systemFontOfSize:12.5 weight:UIFontWeightMedium];
    info.textColor = WCLG27SettingsSubTextColor();
    [card addSubview:info];

    NSArray *tags = @[@"Liquid Glass", @"iOS26+", @"iOS27 Ready"];
    CGFloat x = 88;
    for (NSString *tag in tags) {
        CGSize size = [tag sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11 weight:UIFontWeightBold]}];
        UILabel *pill = [[UILabel alloc] initWithFrame:CGRectMake(x, 78, size.width + 18, 24)];
        pill.text = tag;
        pill.textAlignment = NSTextAlignmentCenter;
        pill.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
        pill.textColor = [UIColor whiteColor];
        pill.backgroundColor = (x < 90 ? WCLG27SettingsAccentColor() : WCLG27SettingsPurpleColor());
        pill.alpha = 0.88;
        pill.layer.cornerRadius = 12;
        pill.clipsToBounds = YES;
        [card addSubview:pill];
        x += size.width + 24;
    }
    return header;
}
- (void)close {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)refresh { if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows(); [self.tableView reloadData]; }

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 5; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 2;
        case 1: return 12;
        case 2: return 8;
        case 3: return 2;
        case 4: return 4;
        default: return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *titles = @[@"总开关", @"功能开关", @"玻璃强度", @"颜色选择器", @"操作"];
    UIView *wrap = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 38)];
    UILabel *dot = [[UILabel alloc] initWithFrame:CGRectMake(24, 12, 10, 10)];
    dot.backgroundColor = (section % 2 == 0) ? WCLG27SettingsAccentColor() : WCLG27SettingsPurpleColor();
    dot.layer.cornerRadius = 5;
    dot.clipsToBounds = YES;
    [wrap addSubview:dot];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(42, 6, CGRectGetWidth(tableView.bounds)-66, 24)];
    label.text = titles[section];
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightHeavy];
    label.textColor = WCLG27SettingsTextColor();
    [wrap addSubview:label];
    return wrap;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 38.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 8.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 2 ? 92.0 : 58.0;
}
- (void)decorateCell:(UITableViewCell *)cell {
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = WCLG27SettingsTextColor();
    cell.detailTextLabel.textColor = WCLG27SettingsSubTextColor();

    UIView *bg = [[UIView alloc] initWithFrame:CGRectInset(cell.bounds, 14, 4)];
    bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    bg.backgroundColor = [UIColor clearColor];
    bg.layer.cornerRadius = 20;
    if (@available(iOS 13.0, *)) bg.layer.cornerCurve = kCACornerCurveContinuous;
    bg.layer.borderWidth = 0.55;
    bg.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.22] CGColor];
    bg.layer.shadowColor = [UIColor blackColor].CGColor;
    bg.layer.shadowOpacity = 0.20;
    bg.layer.shadowRadius = 18;
    bg.layer.shadowOffset = CGSizeMake(0, 8);
    bg.clipsToBounds = NO;

    UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:WCLG27CreateEffect()];
    blur.frame = bg.bounds;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blur.userInteractionEnabled = NO;
    blur.layer.cornerRadius = 20;
    blur.layer.masksToBounds = YES;
    if (@available(iOS 13.0, *)) blur.layer.cornerCurve = kCACornerCurveContinuous;
    [bg addSubview:blur];

    UIView *tint = [[UIView alloc] initWithFrame:bg.bounds];
    tint.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tint.userInteractionEnabled = NO;
    tint.backgroundColor = WCLG27SettingsCardColor();
    tint.layer.cornerRadius = 20;
    tint.layer.masksToBounds = YES;
    [bg addSubview:tint];

    CAGradientLayer *shine = [CAGradientLayer layer];
    shine.frame = bg.bounds;
    shine.startPoint = CGPointMake(0.0, 0.0);
    shine.endPoint = CGPointMake(1.0, 1.0);
    shine.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.20].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.04].CGColor,
        (id)[UIColor clearColor].CGColor
    ];
    shine.locations = @[@0.0, @0.45, @1.0];
    [bg.layer addSublayer:shine];

    cell.backgroundView = bg;

    UIView *selected = [[UIView alloc] initWithFrame:bg.frame];
    selected.backgroundColor = [WCLG27SettingsAccentColor() colorWithAlphaComponent:0.18];
    selected.layer.cornerRadius = 20;
    cell.selectedBackgroundView = selected;
}

- (NSArray<NSDictionary *> *)featureRows {
    return @[
        @{@"title": @"底部 TabBar 玻璃", @"key": kWCLG27FeatureTabBar, @"default": @NO},
        @{@"title": @"顶部导航栏玻璃", @"key": kWCLG27FeatureNavBar, @"default": @NO},
        @{@"title": @"搜索框玻璃", @"key": kWCLG27FeatureSearchGlass, @"default": @NO},
        @{@"title": @"聊天输入栏玻璃", @"key": kWCLG27FeatureInputGlass, @"default": @NO},
        @{@"title": @"聊天气泡/卡片玻璃", @"key": kWCLG27FeatureBubbleGlass, @"default": @NO},
        @{@"title": @"聊天标题胶囊", @"key": kWCLG27FeatureChatTitleCapsule, @"default": @NO},
        @{@"title": @"朋友圈导航栏优化", @"key": kWCLG27FeatureMomentsNav, @"default": @NO},
        @{@"title": @"首页标题隐藏", @"key": kWCLG27FeatureHideHomeTitle, @"default": @NO},
        @{@"title": @"底部 TabBar 右侧搜索按钮", @"key": kWCLG27FeatureTabRightSearch, @"default": @NO},
        @{@"title": @"首页右上角搜索按钮替代原搜索框", @"key": kWCLG27FeatureHomeSearchButton, @"default": @NO},
        @{@"title": @"主页背景纯色", @"key": kWCLG27FeatureHomePureBG, @"default": @NO},
        @{@"title": @"置顶聊天背景隐藏", @"key": kWCLG27FeatureHidePinnedBG, @"default": @NO},
        @{@"title": @"备用悬浮球入口", @"key": kWCLG27FeatureFloatingBall, @"default": @NO}
    ];
}
- (NSArray<NSDictionary *> *)sliderRows {
    return @[
        @{@"title": @"全局强度", @"detail": @"控制所有玻璃效果的整体透明/模糊强度", @"key": kWCLG27StrengthGlobal, @"default": @0.86},
        @{@"title": @"TabBar 强度", @"detail": @"底部栏玻璃底板", @"key": kWCLG27StrengthTabBar, @"default": @0.92},
        @{@"title": @"导航栏强度", @"detail": @"顶部导航栏玻璃", @"key": kWCLG27StrengthNavBar, @"default": @0.90},
        @{@"title": @"搜索框强度", @"detail": @"搜索胶囊/搜索框", @"key": kWCLG27StrengthSearch, @"default": @0.86},
        @{@"title": @"输入栏强度", @"detail": @"聊天底部输入栏", @"key": kWCLG27StrengthInput, @"default": @0.88},
        @{@"title": @"气泡强度", @"detail": @"聊天气泡、富媒体卡片", @"key": kWCLG27StrengthBubble, @"default": @0.72},
        @{@"title": @"标题胶囊强度", @"detail": @"聊天页标题胶囊", @"key": kWCLG27StrengthTitle, @"default": @0.92},
        @{@"title": @"朋友圈导航强度", @"detail": @"朋友圈顶部栏", @"key": kWCLG27StrengthMoments, @"default": @0.96}
    ];
}
- (UIImage *)badgeWithText:(NSString *)text color:(UIColor *)color {
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize size = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(2, 2, 26, 26) cornerRadius:9];
    [color setFill];
    [path fill];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightHeavy], NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: style};
    [text drawInRect:CGRectMake(2, 8, 26, 16) withAttributes:attr];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        WCLG27SliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"slider" forIndexPath:indexPath];
        NSDictionary *row = [self sliderRows][indexPath.row];
        cell.textLabel.text = row[@"title"];
        cell.detailTextLabel.text = row[@"detail"];
        NSString *key = row[@"key"];
        if (![WCLG27Defaults() objectForKey:key]) WCLG27SetFloat(key, [row[@"default"] doubleValue]);
        cell.prefKey = key;
        cell.imageView.image = [self badgeWithText:@"强" color:WCLG27SettingsPurpleColor()];
        [self decorateCell:cell];
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    cell.detailTextLabel.text = nil;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.imageView.image = nil;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"启用 WCLiquidGlass27";
            cell.detailTextLabel.text = WCLG27Enabled() ? @"当前允许手动启用美化模块" : @"当前插件已关闭";
            cell.imageView.image = [self badgeWithText:@"总" color:WCLG27SettingsAccentColor()];
            UISwitch *sw = [[UISwitch alloc] init];
            sw.on = WCLG27Enabled();
            sw.onTintColor = WCLG27SettingsAccentColor();
            sw.accessibilityIdentifier = kWCLG27EnabledKey;
            [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.textLabel.text = @"打开方式";
            cell.detailTextLabel.text = @"长按底部右侧搜索按钮 / 首页搜索按钮";
            cell.imageView.image = [self badgeWithText:@"入" color:WCLG27SettingsPurpleColor()];
        }
    } else if (indexPath.section == 1) {
        NSDictionary *row = [self featureRows][indexPath.row];
        cell.textLabel.text = row[@"title"];
        cell.imageView.image = [self badgeWithText:@"开" color:(indexPath.row % 2 == 0 ? WCLG27SettingsAccentColor() : WCLG27SettingsPurpleColor())];
        UISwitch *sw = [[UISwitch alloc] init];
        sw.on = WCLG27Bool(row[@"key"], [row[@"default"] boolValue]);
        sw.onTintColor = WCLG27SettingsAccentColor();
        sw.accessibilityIdentifier = row[@"key"];
        [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sw;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"玻璃高光颜色";
            cell.detailTextLabel.text = @"控制卡片高光、滑条和按钮强调色";
            cell.imageView.image = [self swatch:WCLG27TintColor()];
        } else {
            cell.textLabel.text = @"主页纯色背景";
            cell.detailTextLabel.text = @"开启主页背景纯色后生效";
            cell.imageView.image = [self swatch:WCLG27HomeBackgroundColor()];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"立即重新扫描界面";
            cell.detailTextLabel.text = @"刷新当前微信页面的玻璃效果";
            cell.imageView.image = [self badgeWithText:@"刷" color:WCLG27SettingsAccentColor()];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"恢复默认设置";
            cell.detailTextLabel.text = @"重置所有开关、强度和颜色";
            cell.imageView.image = [self badgeWithText:@"默" color:[UIColor colorWithRed:1.0 green:0.38 blue:0.36 alpha:1.0]];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"清除插件配置并关闭";
            cell.detailTextLabel.text = @"删除历史配置，防止更新后沿用旧参数";
            cell.imageView.image = [self badgeWithText:@"清" color:[UIColor colorWithRed:1.0 green:0.24 blue:0.42 alpha:1.0]];
        } else {
            cell.textLabel.text = @"版本说明";
            cell.detailTextLabel.text = @"v1.0-1 · 安全启动版 · 默认全关";
            cell.imageView.image = [self badgeWithText:@"i" color:WCLG27SettingsPurpleColor()];
        }
    }
    [self decorateCell:cell];
    return cell;
}
- (UIImage *)swatch:(UIColor *)color {
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize size = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(2, 2, 26, 26) cornerRadius:9];
    [color setFill];
    [path fill];
    [[UIColor colorWithWhite:1 alpha:0.45] setStroke];
    path.lineWidth = 1;
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)switchChanged:(UISwitch *)sw {
    WCLG27SetBool(sw.accessibilityIdentifier, sw.isOn);
    if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
    [self.tableView reloadData];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3) {
        NSString *key = indexPath.row == 0 ? kWCLG27TintColorKey : kWCLG27HomeColorKey;
        NSString *title = indexPath.row == 0 ? @"玻璃高光颜色" : @"主页纯色背景";
        UIColor *color = indexPath.row == 0 ? WCLG27TintColor() : WCLG27HomeBackgroundColor();
        self.pickingColorKey = key;
        if (@available(iOS 14.0, *)) {
            UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
            picker.title = title;
            picker.selectedColor = color;
            picker.supportsAlpha = YES;
            picker.delegate = self;
            picker.view.tintColor = WCLG27SettingsAccentColor();
            [self.navigationController pushViewController:picker animated:YES];
        } else {
            WCLG27ColorPickerFallbackController *fallback = [[WCLG27ColorPickerFallbackController alloc] initWithKey:key title:title color:color];
            [self.navigationController pushViewController:fallback animated:YES];
        }
    } else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
        } else if (indexPath.row == 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"恢复默认设置" message:@"会重置所有开关、强度和颜色。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"恢复" style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action) { [self resetPrefs]; }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else if (indexPath.row == 2) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清除插件配置并关闭" message:@"会删除本插件保存的所有历史配置，并把总开关设为关闭。适合更新插件前使用，避免新版继续读取旧参数。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"清除并关闭" style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction *action) { [self purgePrefsAndDisable]; }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else if (indexPath.row == 3) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"版本说明" message:@"WCLiquidGlass27 v2.7-27\n独立重写版，不包含授权/联网校验。\n新增：清除插件配置并关闭、外部清理标记文件。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}
- (void)purgePrefsAndDisable {
    NSInteger count = WCLG27PurgePluginPreferences(YES);
    [self.tableView reloadData];
    if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
    NSString *msg = [NSString stringWithFormat:@"已清除 %ld 项插件配置，并已关闭插件。建议完全退出微信后重新打开，再安装或启用新版。", (long)count];
    UIAlertController *done = [UIAlertController alertControllerWithTitle:@"已清除" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [done addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:done animated:YES completion:nil];
}

- (void)resetPrefs {
    NSArray *keys = @[
        kWCLG27EnabledKey, kWCLG27FeatureTabBar, kWCLG27FeatureNavBar, kWCLG27FeatureSearchGlass, kWCLG27FeatureInputGlass,
        kWCLG27FeatureBubbleGlass, kWCLG27FeatureChatTitleCapsule, kWCLG27FeatureMomentsNav, kWCLG27FeatureHideHomeTitle,
        kWCLG27FeatureTabRightSearch, kWCLG27FeatureHomeSearchButton, kWCLG27FeatureHomePureBG, kWCLG27FeatureHidePinnedBG, kWCLG27FeatureFloatingBall,
        kWCLG27StrengthGlobal, kWCLG27StrengthTabBar, kWCLG27StrengthNavBar, kWCLG27StrengthSearch, kWCLG27StrengthInput,
        kWCLG27StrengthBubble, kWCLG27StrengthTitle, kWCLG27StrengthMoments,
        WCLG27ColorComponentKey(kWCLG27TintColorKey, @"r"), WCLG27ColorComponentKey(kWCLG27TintColorKey, @"g"),
        WCLG27ColorComponentKey(kWCLG27TintColorKey, @"b"), WCLG27ColorComponentKey(kWCLG27TintColorKey, @"a"),
        WCLG27ColorComponentKey(kWCLG27HomeColorKey, @"r"), WCLG27ColorComponentKey(kWCLG27HomeColorKey, @"g"),
        WCLG27ColorComponentKey(kWCLG27HomeColorKey, @"b"), WCLG27ColorComponentKey(kWCLG27HomeColorKey, @"a")
    ];
    for (NSString *key in keys) [WCLG27Defaults() removeObjectForKey:key];
    [WCLG27Defaults() synchronize];
    [self.tableView reloadData];
    if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
}
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    if (self.pickingColorKey) WCLG27SetColorForKey(self.pickingColorKey, viewController.selectedColor);
    if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
    [self.tableView reloadData];
}
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    if (self.pickingColorKey) WCLG27SetColorForKey(self.pickingColorKey, viewController.selectedColor);
    if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
    [self.tableView reloadData];
}
@end

static void WCLG27PresentSettings(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *top = WCLG27TopViewController();
        if (!top || [top isKindOfClass:[WCLG27SettingsViewController class]]) return;
        WCLG27SettingsViewController *settings = [[WCLG27SettingsViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [top presentViewController:nav animated:YES completion:nil];
    });
}


#pragma mark - WCPlugins Manager Entry

static BOOL WCLG27PluginManagerEntryRegistered = NO;


#pragma mark - Fallback Floating Ball Entry

static UIWindow *WCLG27MainWindowForEntry(void) {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState != UISceneActivationStateForegroundActive) continue;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) { keyWindow = window; break; }
            }
            if (keyWindow) break;
        }
    }
    if (!keyWindow) {
        SEL keyWindowSel = NSSelectorFromString(@"keyWindow");
        if ([UIApplication.sharedApplication respondsToSelector:keyWindowSel]) {
            keyWindow = ((UIWindow *(*)(id, SEL))objc_msgSend)(UIApplication.sharedApplication, keyWindowSel);
        }
    }
    if (!keyWindow) keyWindow = UIApplication.sharedApplication.windows.firstObject;
    return keyWindow;
}

static void WCLG27EnsureFallbackFloatingBall(BOOL show) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = WCLG27MainWindowForEntry();
        if (!window) return;
        UIView *old = [window viewWithTag:kWCLG27FloatingBallTag];
        if (!show) {
            [old removeFromSuperview];
            return;
        }
        UIButton *ball = nil;
        if ([old isKindOfClass:[UIButton class]]) {
            ball = (UIButton *)old;
        } else {
            [old removeFromSuperview];
            ball = [UIButton buttonWithType:UIButtonTypeSystem];
            ball.tag = kWCLG27FloatingBallTag;
            ball.accessibilityLabel = @"WCLiquidGlass27 Settings Fallback";
            [ball setTitle:@"LG" forState:UIControlStateNormal];
            [ball setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            ball.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            ball.backgroundColor = [[UIColor colorWithRed:0.13 green:0.48 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.82];
            ball.layer.cornerRadius = 26.0;
            ball.layer.shadowColor = UIColor.blackColor.CGColor;
            ball.layer.shadowOpacity = 0.28;
            ball.layer.shadowRadius = 12.0;
            ball.layer.shadowOffset = CGSizeMake(0, 6);
            [ball addTarget:(id)ball action:@selector(wclg27_openSettingsTap) forControlEvents:UIControlEventTouchUpInside];
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:ball action:@selector(wclg27_floatPan:)];
            [ball addGestureRecognizer:pan];
            [window addSubview:ball];
        }
        CGFloat side = 52.0;
        if (CGRectIsEmpty(ball.frame)) {
            CGFloat w = CGRectGetWidth(window.bounds), h = CGRectGetHeight(window.bounds);
            ball.frame = CGRectMake(MAX(12, w - side - 18), MAX(120, h * 0.58), side, side);
        }
        [window bringSubviewToFront:ball];
    });
}

static void WCLG27ScheduleFallbackFloatingBallCheck(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL manuallyEnabled = WCLG27Bool(kWCLG27FeatureFloatingBall, NO);
        if (manuallyEnabled || !WCLG27PluginManagerEntryRegistered) {
            WCLG27EnsureFallbackFloatingBall(YES);
        }
    });
}


static BOOL WCLG27PluginEntryAlreadyExists(id manager, NSString *controllerName) {
    if (!manager || ![manager respondsToSelector:@selector(plugins)]) return NO;
    NSArray *plugins = ((id (*)(id, SEL))objc_msgSend)(manager, @selector(plugins));
    if (![plugins isKindOfClass:[NSArray class]]) return NO;
    for (id plugin in plugins) {
        NSString *title = nil;
        NSString *controller = nil;
        if ([plugin respondsToSelector:@selector(title)]) {
            title = ((id (*)(id, SEL))objc_msgSend)(plugin, @selector(title));
        }
        if ([plugin respondsToSelector:@selector(controller)]) {
            controller = ((id (*)(id, SEL))objc_msgSend)(plugin, @selector(controller));
        }
        if ([controller isKindOfClass:[NSString class]] && [controller isEqualToString:controllerName]) return YES;
        if ([title isKindOfClass:[NSString class]] && [title isEqualToString:@"WeChatLiquidGlass"] && [controller isKindOfClass:[NSString class]] && [controller hasPrefix:@"WCLG27"]) return YES;
    }
    return NO;
}

static void WCLG27RegisterPluginManagerEntry(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (WCLG27PluginManagerEntryRegistered) return;
        Class mgrClass = NSClassFromString(@"WCPluginsMgr");
        if (!mgrClass || ![mgrClass respondsToSelector:@selector(sharedInstance)]) return;
        id manager = ((id (*)(id, SEL))objc_msgSend)((id)mgrClass, @selector(sharedInstance));
        if (!manager || ![manager respondsToSelector:@selector(registerControllerWithTitle:version:controller:)]) return;

        NSString *controllerName = NSStringFromClass([WCLG27SettingsViewController class]);
        if (WCLG27PluginEntryAlreadyExists(manager, controllerName)) {
            WCLG27PluginManagerEntryRegistered = YES;
            WCLG27EnsureFallbackFloatingBall(NO);
            return;
        }

        ((void (*)(id, SEL, id, id, id))objc_msgSend)(manager,
                                                        @selector(registerControllerWithTitle:version:controller:),
                                                        @"WeChatLiquidGlass",
                                                        @"Version 1.0-1",
                                                        controllerName);
        WCLG27PluginManagerEntryRegistered = YES;
        WCLG27EnsureFallbackFloatingBall(NO);
    });
}

static void WCLG27SchedulePluginManagerEntryRegistration(void) {
    WCLG27RegisterPluginManagerEntrySync();
    dispatch_async(dispatch_get_main_queue(), ^{ WCLG27RegisterPluginManagerEntrySync(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27RegisterPluginManagerEntrySync(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27RegisterPluginManagerEntrySync(); });
    WCLG27RegisterPluginManagerEntry();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27RegisterPluginManagerEntry(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27RegisterPluginManagerEntry(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27RegisterPluginManagerEntry(); });
}



#pragma mark - WCPlugins Fast Entry Patch

static NSArray *WCLG27FastPluginArrayDirect(id manager) {
    if (!manager) return nil;
    Ivar ivar = class_getInstanceVariable([manager class], "_plugins");
    if (ivar) {
        id value = object_getIvar(manager, ivar);
        if ([value isKindOfClass:[NSArray class]]) return value;
    }
    return nil;
}

static BOOL WCLG27FastEntryExistsInArray(NSArray *plugins, NSString *controllerName) {
    if (![plugins isKindOfClass:[NSArray class]]) return NO;
    for (id plugin in plugins) {
        NSString *title = nil;
        NSString *controller = nil;
        if ([plugin respondsToSelector:@selector(title)]) {
            title = ((id (*)(id, SEL))objc_msgSend)(plugin, @selector(title));
        }
        if ([plugin respondsToSelector:@selector(controller)]) {
            controller = ((id (*)(id, SEL))objc_msgSend)(plugin, @selector(controller));
        }
        if ([controller isKindOfClass:[NSString class]] && [controller isEqualToString:controllerName]) return YES;
        if ([title isKindOfClass:[NSString class]] && [title isEqualToString:@"WeChatLiquidGlass"]) return YES;
    }
    return NO;
}

static BOOL WCLG27RegisterPluginManagerEntryWithManager(id manager) {
    if (!manager || ![manager respondsToSelector:@selector(registerControllerWithTitle:version:controller:)]) return NO;

    NSString *controllerName = NSStringFromClass([WCLG27SettingsViewController class]);
    NSArray *plugins = WCLG27FastPluginArrayDirect(manager);
    if (WCLG27FastEntryExistsInArray(plugins, controllerName)) {
        WCLG27PluginManagerEntryRegistered = YES;
        WCLG27EnsureFallbackFloatingBall(NO);
        return YES;
    }

    ((void (*)(id, SEL, id, id, id))objc_msgSend)(manager,
                                                  @selector(registerControllerWithTitle:version:controller:),
                                                  @"WeChatLiquidGlass",
                                                  @"Version 1.0-1",
                                                  controllerName);

    NSArray *after = WCLG27FastPluginArrayDirect(manager);
    if (WCLG27FastEntryExistsInArray(after, controllerName)) {
        WCLG27PluginManagerEntryRegistered = YES;
        WCLG27EnsureFallbackFloatingBall(NO);
        return YES;
    }

    // 有些 wcplugins 版本注册后不会马上暴露 _plugins，这里不判死，后续重试继续补。
    return NO;
}

static BOOL WCLG27RegisterPluginManagerEntrySync(void) {
    if (WCLG27PluginManagerEntryRegistered) return YES;
    Class mgrClass = NSClassFromString(@"WCPluginsMgr");
    if (!mgrClass || ![mgrClass respondsToSelector:@selector(sharedInstance)]) return NO;
    id manager = ((id (*)(id, SEL))objc_msgSend)((id)mgrClass, @selector(sharedInstance));
    return WCLG27RegisterPluginManagerEntryWithManager(manager);
}


#pragma mark - Runtime Button Actions

@interface UIButton (WCLG27Actions)
- (void)wclg27_tabSearchTap;
- (void)wclg27_openSettingsLongPress:(UILongPressGestureRecognizer *)gr;
- (void)wclg27_openSettingsTap;
- (void)wclg27_floatPan:(UIPanGestureRecognizer *)gr;
@end
@implementation UIButton (WCLG27Actions)
- (void)wclg27_tabSearchTap { WCLG27TabSearchTapped(self); }
- (void)wclg27_openSettingsLongPress:(UILongPressGestureRecognizer *)gr { WCLG27LongPressSettings(gr); }
- (void)wclg27_openSettingsTap { WCLG27PresentSettings(); }
- (void)wclg27_floatPan:(UIPanGestureRecognizer *)gr {
    UIView *view = gr.view;
    UIView *superview = view.superview;
    if (!view || !superview) return;
    CGPoint t = [gr translationInView:superview];
    view.center = CGPointMake(view.center.x + t.x, view.center.y + t.y);
    [gr setTranslation:CGPointZero inView:superview];
    if (gr.state == UIGestureRecognizerStateEnded || gr.state == UIGestureRecognizerStateCancelled) {
        CGFloat side = CGRectGetWidth(view.bounds);
        CGFloat maxX = CGRectGetWidth(superview.bounds) - side / 2.0 - 12.0;
        CGFloat minX = side / 2.0 + 12.0;
        CGFloat maxY = CGRectGetHeight(superview.bounds) - side / 2.0 - 38.0;
        CGFloat minY = side / 2.0 + 80.0;
        CGPoint c = view.center;
        c.x = (c.x < CGRectGetMidX(superview.bounds)) ? minX : maxX;
        c.y = MAX(minY, MIN(maxY, c.y));
        [UIView animateWithDuration:0.22 animations:^{ view.center = c; }];
    }
}
@end


#pragma mark - WCLG27 Scan Routing

static BOOL WCLG27NeedsDeepViewScan(void) {
    if (!WCLG27RuntimeEnabled()) return NO;
    return WCLG27Feature(kWCLG27FeatureInputGlass, NO) ||
           WCLG27Feature(kWCLG27FeatureSearchGlass, NO) ||
           WCLG27Feature(kWCLG27FeatureBubbleGlass, NO);
}

static BOOL WCLG27NeedsControllerSpecificScan(void) {
    if (!WCLG27RuntimeEnabled()) return NO;
    return WCLG27Feature(kWCLG27FeatureHomeSearchButton, NO) ||
           WCLG27Feature(kWCLG27FeatureHideHomeTitle, NO) ||
           WCLG27Feature(kWCLG27FeatureChatTitleCapsule, NO) ||
           WCLG27Feature(kWCLG27FeatureMomentsNav, NO) ||
           WCLG27Feature(kWCLG27FeatureHomePureBG, NO) ||
           WCLG27Feature(kWCLG27FeatureHidePinnedBG, NO);
}


#pragma mark - WCLG27 WeChat 8.0.72 Precise Hooks

/*
  These class names were checked from com.tencent.xin 8.0.72 Mach-O strings:
  - MMInputToolView / InputToolViewBar / InputSetContainerView / InputSetHostView / MMInputMsgReferView
  - BaseMsgContentViewController
  - MainTabBarViewController / MMTabBar / NewMainFrameViewController
  - WCSearchTextField / WCSearchGradientView / CellSearchBarViewController / CellNewSearchBarResultTableView
  - WCTimeLineViewController / FindFriendEntryViewController
*/

static void WCLG27PreciseApplyChatInputView(UIView *view) {
    if (!view || !WCLG27RuntimeEnabled() || !WCLG27Feature(kWCLG27FeatureInputGlass, NO)) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *target = view;
        if ([target isKindOfClass:[UITextField class]] || [target isKindOfClass:[UITextView class]]) {
            WCLG27ApplyBottomInputForTextInput(target);
            return;
        }

        UIView *input = WCLG27FindTextInputViewInView(target, 0);
        if (input) {
            WCLG27ApplyBottomInputForTextInput(input);
        } else {
            WCLG27ApplyInputGlass(target);
        }
    });
}

static void WCLG27PreciseApplySearchView(UIView *view) {
    if (!view || !WCLG27RuntimeEnabled() || !WCLG27Feature(kWCLG27FeatureSearchGlass, NO)) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        WCLG27ApplySearchGlass(view);
    });
}

static void WCLG27PreciseApplyNavigationForController(UIViewController *vc) {
    if (!vc || !WCLG27RuntimeEnabled()) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationBar *bar = vc.navigationController.navigationBar;
        if (bar && WCLG27Feature(kWCLG27FeatureNavBar, NO)) WCLG27ApplyNavigationBar(bar);
        if (WCLG27NeedsControllerSpecificScan()) WCLG27ApplyControllerSpecificTweaks(vc);
    });
}

static void WCLG27PreciseApplyTabBarController(UIViewController *vc) {
    if (!vc || !WCLG27RuntimeEnabled()) return;
    UITabBar *tabBar = nil;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        tabBar = ((UITabBarController *)vc).tabBar;
    } else if ([vc respondsToSelector:@selector(tabBar)]) {
        id value = ((id (*)(id, SEL))objc_msgSend)(vc, @selector(tabBar));
        if ([value isKindOfClass:[UITabBar class]]) tabBar = value;
    }
    if (tabBar) WCLG27ApplyTabBar(tabBar);
}


#pragma mark - Hooks



%hook MMInputToolView
- (void)layoutSubviews {
    %orig;
    WCLG27PreciseApplyChatInputView((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCLG27PreciseApplyChatInputView((UIView *)self);
}
%end

%hook InputToolViewBar
- (void)layoutSubviews {
    %orig;
    WCLG27PreciseApplyChatInputView((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCLG27PreciseApplyChatInputView((UIView *)self);
}
%end

%hook InputSetContainerView
- (void)layoutSubviews {
    %orig;
    WCLG27PreciseApplyChatInputView((UIView *)self);
}
%end

%hook InputSetHostView
- (void)layoutSubviews {
    %orig;
    WCLG27PreciseApplyChatInputView((UIView *)self);
}
%end

%hook MMInputMsgReferView
- (void)layoutSubviews {
    %orig;
    WCLG27PreciseApplyChatInputView(((UIView *)self).superview ?: (UIView *)self);
}
%end

%hook BaseMsgContentViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
    if (WCLG27Feature(kWCLG27FeatureInputGlass, NO)) WCLG27ScanViewTree(((UIViewController *)self).view, 0);
}
- (void)viewDidLayoutSubviews {
    %orig;
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
    if (WCLG27Feature(kWCLG27FeatureInputGlass, NO)) WCLG27ScanViewTree(((UIViewController *)self).view, 0);
}
%end

%hook MainTabBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    WCLG27PreciseApplyTabBarController((UIViewController *)self);
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
}
- (void)viewDidLayoutSubviews {
    %orig;
    WCLG27PreciseApplyTabBarController((UIViewController *)self);
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
}
%end

%hook NewMainFrameViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
    if (WCLG27Feature(kWCLG27FeatureSearchGlass, NO)) WCLG27ScanViewTree(((UIViewController *)self).view, 0);
}
- (void)viewDidLayoutSubviews {
    %orig;
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
    if (WCLG27Feature(kWCLG27FeatureSearchGlass, NO)) WCLG27ScanViewTree(((UIViewController *)self).view, 0);
}
%end

%hook MMTabBar
- (void)layoutSubviews {
    %orig;
    WCLG27ApplyTabBar((UITabBar *)self);
}
%end

%hook WCSearchTextField
- (void)layoutSubviews {
    %orig;
    WCLG27PreciseApplySearchView((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCLG27PreciseApplySearchView((UIView *)self);
}
%end

%hook WCSearchGradientView
- (void)layoutSubviews {
    %orig;
    WCLG27PreciseApplySearchView((UIView *)self);
}
%end

%hook CellNewSearchBarResultTableView
- (void)layoutSubviews {
    %orig;
    if (WCLG27Feature(kWCLG27FeatureSearchGlass, NO)) WCLG27ScanViewTree((UIView *)self, 0);
}
%end

%hook CellSearchBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    if (WCLG27Feature(kWCLG27FeatureSearchGlass, NO)) WCLG27ScanViewTree(((UIViewController *)self).view, 0);
}
- (void)viewDidLayoutSubviews {
    %orig;
    if (WCLG27Feature(kWCLG27FeatureSearchGlass, NO)) WCLG27ScanViewTree(((UIViewController *)self).view, 0);
}
%end

%hook WCTimeLineViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
}
- (void)viewDidLayoutSubviews {
    %orig;
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
}
%end

%hook FindFriendEntryViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
}
- (void)viewDidLayoutSubviews {
    %orig;
    WCLG27PreciseApplyNavigationForController((UIViewController *)self);
}
%end


%hook UITextView
- (void)layoutSubviews {
    %orig;
    WCLG27ApplyBottomInputForTextInput((UIView *)self);
}
%end

%hook UITextField
- (void)layoutSubviews {
    %orig;
    WCLG27ApplyBottomInputForTextInput((UIView *)self);
}
%end


%hook UITabBar
- (void)layoutSubviews {
    %orig;
    WCLG27ApplyTabBar((UITabBar *)self);
}
%end

%hook UINavigationBar
- (void)layoutSubviews {
    %orig;
    WCLG27ApplyNavigationBar((UINavigationBar *)self);
}
%end

%hook UITableView
- (void)layoutSubviews {
    %orig;
    if (WCLG27NeedsDeepViewScan()) WCLG27ScanViewTree((UIView *)self, 0);
}
%end

%hook UICollectionView
- (void)layoutSubviews {
    %orig;
    if (WCLG27NeedsDeepViewScan()) WCLG27ScanViewTree((UIView *)self, 0);
}
%end

%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    if (WCLG27NeedsDeepViewScan()) WCLG27ScanWindow(self.view.window);
    if (WCLG27NeedsControllerSpecificScan()) WCLG27ApplyControllerSpecificTweaks((UIViewController *)self);
}
- (void)viewDidLayoutSubviews {
    %orig;
    if (WCLG27NeedsDeepViewScan()) WCLG27ScanWindow(self.view.window);
    if (WCLG27NeedsControllerSpecificScan()) WCLG27ApplyControllerSpecificTweaks((UIViewController *)self);
}
%end



#pragma mark - WCLG27 Plugin Manager Strong Registration Patch

static void WCLG27SchedulePluginManagerEntryRegistrationStrong(void) {
    WCLG27SchedulePluginManagerEntryRegistration();
        WCLG27ShowCrashGuardNoticeIfNeeded();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27RegisterPluginManagerEntry(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ WCLG27RegisterPluginManagerEntry(); });
}


%hook WCPluginsMgr
+ (id)sharedInstance {
    id manager = %orig;
    WCLG27RegisterPluginManagerEntryWithManager(manager);
    return manager;
}
- (id)plugins {
    WCLG27RegisterPluginManagerEntryWithManager((id)self);
    return %orig;
}
%end

%hook WCPluginsViewController
- (void)initData {
    WCLG27RegisterPluginManagerEntrySync();
    %orig;
    WCLG27RegisterPluginManagerEntrySync();
}
- (void)viewDidLoad {
    WCLG27RegisterPluginManagerEntrySync();
    %orig;
}
- (void)viewWillAppear:(BOOL)animated {
    WCLG27RegisterPluginManagerEntrySync();
    %orig(animated);
}
- (void)reloadTableData {
    WCLG27RegisterPluginManagerEntrySync();
    %orig;
}
%end


%hook UIApplication
- (void)didFinishLaunching {
    %orig;
    WCLG27SchedulePluginManagerEntryRegistrationStrong();
    WCLG27ScheduleFallbackFloatingBallCheck();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ if (WCLG27RuntimeEnabled()) if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows(); });
}
%end

%ctor {
    @autoreleasepool {
        
        WCLG27CrashGuardBeginLaunch();
if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.tencent.xin"]) return;
        WCLG27ConsumeExternalClearConfigMarkerIfNeeded();
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *note) {
            if (WCLG27RuntimeEnabled() && WCLG27Feature(kWCLG27FeatureInputGlass, NO)) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows(); });
            }
        }];
[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *note) {
            WCLG27ConsumeExternalClearConfigMarkerIfNeeded();
            WCLG27SchedulePluginManagerEntryRegistrationStrong();
            if (WCLG27RuntimeEnabled()) if (WCLG27RuntimeMayScan()) WCLG27ScanAllWindows();
        }];
        WCLG27SchedulePluginManagerEntryRegistrationStrong();
        WCLG27ScheduleFallbackFloatingBallCheck();
    }
}
