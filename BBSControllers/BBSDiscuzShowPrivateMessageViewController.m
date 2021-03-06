//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSDiscuzShowPrivateMessageViewController.h"

#import "MJRefresh.h"
#import "BBSUserProfileTableViewController.h"

#import "BBSWebViewController.h"
#import "UIStoryboard+Forum.h"
#import "AppDelegate.h"
#import "BBSLocalApi.h"

#import "AssertReader.h"
#import "NSUserDefaults+Setting.h"

@interface BBSDiscuzShowPrivateMessageViewController () <WKNavigationDelegate, UIScrollViewDelegate, TranslateDataDelegate> {

    BBSPrivateMessage *transPrivateMessage;

    UIStoryboardSegue *selectSegue;

    int mType;  //0 收件箱  1发件箱
}

@end

@implementation BBSDiscuzShowPrivateMessageViewController


- (void)transBundle:(TranslateData *)bundle {
    transPrivateMessage = [bundle getObjectValue:@"TransPrivateMessage"];
    mType = [bundle getIntValue:@"TransPrivateMessageType"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataList = [NSMutableArray array];

    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.navigationDelegate = self;

    [self.webView setOpaque:NO];

    // scrollView
    self.webView.scrollView.delegate = self;

    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        // 0 群发公共消息 1 普通收件 2 发给别人的消息

        int type = 1;

        if (mType == 0) {
            type = 1;
            if ([transPrivateMessage.pmAuthorId isEqualToString:@"-1"]) {
                type = 0;
            }
        } else {
            type = 2;
        }

        [self.forumApi showPrivateMessageContentWithId:[transPrivateMessage.pmAuthorId intValue] withType:type handler:^(BOOL isSuccess, id message) {

            BBSPrivateMessagePage *page = message;
            [self.dataList removeAllObjects];

            [self.dataList addObjectsFromArray:page.viewMessages];

            NSMutableString *content = [NSMutableString string];
            for (BBSPrivateMessageDetail *viewMessage in self.dataList) {

                NSString *postInfo = [NSString stringWithFormat:[AssertReader html_content_template_message], viewMessage.pmUserInfo.userID, viewMessage.pmUserInfo.userAvatar, viewMessage.pmUserInfo.userName, viewMessage.pmTime, viewMessage.pmContent];
                [content appendString:postInfo];
            }

            int fontSize = [[NSUserDefaults standardUserDefaults] fontSize];
            NSString *fontSizeStr = [NSString stringWithFormat:@"%d", fontSize];

            NSString *html = [NSString stringWithFormat:[AssertReader html_content_template_all_post_floors],
                    fontSizeStr, fontSizeStr, fontSizeStr,
                    @"", content, [AssertReader js_click_fast_lib], [AssertReader js_click_event_handler]];

            BBSLocalApi *localeForumApi = [[BBSLocalApi alloc] init];
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:localeForumApi.currentForumBaseUrl]];

            [self.webView.scrollView.mj_header endRefreshing];
        }];
    }];

    [self.webView.scrollView.mj_header beginRefreshing];
}

- (void)showUserProfile:(NSIndexPath *)indexPath {

}

- (NSDictionary *)dictionaryFromQuery:(NSString *)query usingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString *key = [kvPair[0]
                    stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString *value = [kvPair[1]
                    stringByReplacingPercentEscapesUsingEncoding:encoding];
            pairs[key] = value;
        }
    }

    return [NSDictionary dictionaryWithDictionary:pairs];
}


#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURLRequest *request = navigationAction.request;

    if (navigationAction.navigationType == WKNavigationTypeLinkActivated && ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"])) {

        NSString *path = request.URL.path;
        if ([path rangeOfString:@"showthread.php"].location != NSNotFound) {
            // 显示帖子
            NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

            NSString *t = [query valueForKey:@"t"];


            UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

            BBSWebViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowThreadDetail"];
            TranslateData *bundle = [[TranslateData alloc] init];
            if (t) {
                [bundle putIntValue:[t intValue] forKey:@"threadID"];
            } else {
                NSString *p = [query valueForKey:@"p"];
                [bundle putIntValue:[p intValue] forKey:@"pId"];
            }


            [self transBundle:bundle forController:showThreadController];
            [self.navigationController pushViewController:showThreadController animated:YES];

            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else {
            [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }

    if ([request.URL.scheme isEqualToString:@"avatar"]) {
        NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

        NSString *userid = [query valueForKey:@"userid"];


        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        BBSUserProfileTableViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowUserProfile"];

        TranslateData *bundle = [[TranslateData alloc] init];
        [bundle putIntValue:[userid intValue] forKey:@"UserId"];

        [self transBundle:bundle forController:showThreadController];

        [self.navigationController pushViewController:showThreadController animated:YES];

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)replyPM:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"CreatePM"];

    TranslateData *bundle = [[TranslateData alloc] init];
    BBSPrivateMessage *message = [[BBSPrivateMessage alloc] init];
    message.forumhash = transPrivateMessage.forumhash;
    message.pmAuthorId = transPrivateMessage.pmAuthorId;
    message.pmAuthor = transPrivateMessage.pmAuthor;
    message.pmTitle = transPrivateMessage.pmTitle;

    for (int i = (int) (self.dataList.count - 1); i >= 0; i--) {
        BBSPrivateMessageDetail *viewMessage = self.dataList[(NSUInteger) i];
        if ([viewMessage.pmUserInfo.userID isEqualToString:transPrivateMessage.pmAuthorId]) {
            message.pmID = viewMessage.pmID;
            break;
        }
    }

    [bundle putObjectValue:message forKey:@"toReplyMessage"];
    [bundle putIntValue:1 forKey:@"isReply"];

    [self presentViewController:(id) controller withBundle:bundle forRootController:YES animated:YES completion:^{

    }];

}

@end
