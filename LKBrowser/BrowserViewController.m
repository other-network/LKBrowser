//
//  ViewController.m
//  LKBrowser
//
//  Created by Lookis on 09/03/2017.
//  Copyright © 2017 Lookis. All rights reserved.
//

#import "BrowserViewController.h"

static float const PROGRESS_VIEW_INTERVAL = (float)1.0/60;
static float const PROGRESS_VIEW_MAX_BEFORE_LOADED = (float)0.95;
static float const PROGRESS_VIEW_SUPPOSED_FINISH = (float)2.0;

@interface BrowserViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonGoBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonGoForward;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonReload;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonShare;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonTabs;

@end

@implementation BrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [_webView loadRequest:request];
    [self renderButtons];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma AddressBar

- (IBAction)cancel:(id)sender{
    [_textField resignFirstResponder];

}

- (IBAction)gotoUrl:(id)sender{
    NSLog(@"gotoUrl");
    NSString *url = nil;
    if([[_textField text] hasPrefix:@"http://"] || [[_textField text] hasPrefix:@"https://"]){
        url = [_textField text];
    }else{
        url = [NSString stringWithFormat:@"http://%@", [_textField text]];
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [_textField resignFirstResponder];
}

- (IBAction)startEditing:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_textField selectAll:nil];
    });
}

- (IBAction)endEditing:(id)sender{
    [_textField setText: [[[_webView request]URL] absoluteString]];
}

#pragma UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad");
    if(![_textField isFirstResponder]){
        [_textField setText: [[[_webView request]URL] absoluteString]];
    }
    [_progressBar setHidden:NO];
    [_progressBar setProgress:0.0 animated:NO];
    [NSTimer scheduledTimerWithTimeInterval:PROGRESS_VIEW_INTERVAL repeats:YES block:^(NSTimer *timer){
        if (_progressBar.progress < PROGRESS_VIEW_MAX_BEFORE_LOADED){
            [_progressBar setProgress: [_progressBar progress] + (PROGRESS_VIEW_MAX_BEFORE_LOADED/PROGRESS_VIEW_SUPPOSED_FINISH * PROGRESS_VIEW_INTERVAL) animated:YES];
        }
    }];
    [self renderButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
    if(![_textField isFirstResponder]){
        [_textField setText: [[[_webView request]URL] absoluteString]];
    }
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [_progressBar setHidden:YES];
    }];
    [CATransaction setAnimationDuration:0.5];
    [_progressBar setProgress:1.0 animated:YES];
    [CATransaction commit];
}

#pragma UITab

- (IBAction)goBack:(id)sender{
    if ([_webView canGoBack]){
        [_webView goBack];
        [self renderButtons];
    }
}

- (IBAction)goForward:(id)sender{
    if([_webView canGoForward]){
        [_webView goForward];
        [self renderButtons];
    }
}

- (IBAction)reload:(id)sender{
    [_webView reload];
}

- (IBAction)share:(id)sender{
    NSArray * activityItems = @[_webView.request.URL];
    NSArray * applicationActivities = nil;
    NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeMessage];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)tabs:(id)sender{
    
}

- (void)renderButtons{
//    [_buttonGoBack setEnabled:NO];
//    [_buttonGoForward setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [_buttonGoBack setEnabled:[_webView canGoBack]];
        [_buttonGoForward setEnabled:[_webView canGoForward]];
    });
}

@end
