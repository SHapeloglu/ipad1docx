#import "AppDelegate.h"
#import "DocumentReaderViewController.h"

static NSString *IP1DOCXDebugLogPath(void) {
    return @"/var/mobile/Media/iPad1Files/ipad1docx-debug.log";
}

static void IP1DOCXDebugLog(NSString *message) {
    if(!message) return;
    NSString *line=[NSString stringWithFormat:@"%@\n",message];
    NSData *data=[line dataUsingEncoding:NSUTF8StringEncoding];
    NSFileManager *fm=[NSFileManager defaultManager];
    NSString *path=IP1DOCXDebugLogPath();
    if(![fm fileExistsAtPath:path]) [fm createFileAtPath:path contents:nil attributes:nil];
    NSFileHandle *handle=[NSFileHandle fileHandleForWritingAtPath:path];
    if(handle) {
        @try {
            [handle seekToEndOfFile];
            [handle writeData:data];
        } @catch(NSException *exception) {
            (void)exception;
        }
        [handle closeFile];
    }
}

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
    IP1DOCXDebugLog(@"APP launch begin");
    _window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *home=[self homeController];
    _navigationController=[[UINavigationController alloc] initWithRootViewController:home];
    _window.rootViewController=_navigationController;
    [_window makeKeyAndVisible];
    IP1DOCXDebugLog(@"APP window visible");

    NSURL *url=[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if(url) {
        IP1DOCXDebugLog([NSString stringWithFormat:@"APP launch URL: %@",[url absoluteString]]);
        [self openURL:url];
    } else {
        IP1DOCXDebugLog(@"APP launch without URL");
    }
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
    IP1DOCXDebugLog([NSString stringWithFormat:@"APP openURL begin: %@",[url absoluteString]]);
    NSString *path=[self decodedPathFromURL:url];
    IP1DOCXDebugLog([NSString stringWithFormat:@"APP decoded path: %@",path?:@"<nil>"]);
    if(![path length]) { IP1DOCXDebugLog(@"APP reject: empty path"); return NO; }
    if(![[[[path pathExtension] lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"docx"]) {
        IP1DOCXDebugLog(@"APP reject: extension is not docx");
        return NO;
    }
    BOOL exists=[[NSFileManager defaultManager] fileExistsAtPath:path];
    IP1DOCXDebugLog([NSString stringWithFormat:@"APP file exists: %@",exists?@"YES":@"NO"]);
    if(!exists) return NO;

    [_navigationController popToRootViewControllerAnimated:NO];
    IP1DOCXDebugLog(@"APP creating reader");
    DocumentReaderViewController *reader=[[[DocumentReaderViewController alloc] initWithDocumentPath:path] autorelease];
    IP1DOCXDebugLog(@"APP pushing reader");
    [_navigationController pushViewController:reader animated:NO];
    IP1DOCXDebugLog(@"APP reader pushed");
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    (void)application;
    IP1DOCXDebugLog([NSString stringWithFormat:@"APP handleOpenURL: %@",[url absoluteString]]);
    return [self openURL:url];
}

- (void)dealloc {
    IP1DOCXDebugLog(@"APP dealloc");
    [_navigationController release];
    [_window release];
    [super dealloc];
}
@end
