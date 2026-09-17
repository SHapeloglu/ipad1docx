#import "AppDelegate.h"
#import "DocumentReaderViewController.h"

@implementation AppDelegate
@synthesize window=_window;

- (UIViewController *)homeController {
    UIViewController *vc=[[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    vc.title=@"DOCX Reader";
    vc.view.backgroundColor=[UIColor whiteColor];
    UILabel *label=[[[UILabel alloc] initWithFrame:CGRectMake(40,180,688,160)] autorelease];
    label.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=UITextAlignmentCenter;
    label.numberOfLines=0;
    label.font=[UIFont systemFontOfSize:20.0f];
    label.text=@"DOCX dosyalarını iPad1Files üzerinden açın.\n\nipad1docx://open?path=...";
    [vc.view addSubview:label];
    return vc;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)application;
    _window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *home=[self homeController];
    _navigationController=[[UINavigationController alloc] initWithRootViewController:home];
    _window.rootViewController=_navigationController;
    [_window makeKeyAndVisible];

    NSURL *url=[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if(url) [self openURL:url];
    return YES;
}

- (NSString *)decodedPathFromURL:(NSURL *)url {
    if(!url || ![[[url scheme] lowercaseString] isEqualToString:@"ipad1docx"]) return nil;
    if(![[[url host] lowercaseString] isEqualToString:@"open"]) return nil;
    NSString *query=[url query];
    if(![query length]) return nil;
    for(NSString *part in [query componentsSeparatedByString:@"&"]) {
        NSRange eq=[part rangeOfString:@"="];
        if(eq.location==NSNotFound) continue;
        NSString *key=[part substringToIndex:eq.location];
        if(![key isEqualToString:@"path"]) continue;
        NSString *value=[part substringFromIndex:eq.location+1];
        return [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (BOOL)openURL:(NSURL *)url {
    NSString *path=[self decodedPathFromURL:url];
    if(![path length]) return NO;
    if(![[[[path pathExtension] lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"docx"]) return NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;

    [_navigationController popToRootViewControllerAnimated:NO];
    DocumentReaderViewController *reader=[[[DocumentReaderViewController alloc] initWithDocumentPath:path] autorelease];
    [_navigationController pushViewController:reader animated:NO];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    (void)application;
    return [self openURL:url];
}

- (void)dealloc {
    [_navigationController release];
    [_window release];
    [super dealloc];
}
@end
