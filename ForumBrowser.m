//
//  ForumBrowser.m
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumBrowser.h"

#import <AFImageDownloader.h>
#import "ForumHtmlParser.h"
#import <iOSDeviceName/iOSDeviceName.h>

typedef void (^CallBack)(NSString *token, NSString *hash, NSString *time);


@implementation ForumBrowser {

    NSString *listMyThreadSearchId;

    NSMutableDictionary *listUserThreadRedirectUrlDictionary;

    NSString *todayNewThreadPostSearchId;

    NSString *_phoneName;

    ForumHtmlParser *_htmlParser;

    AFHTTPSessionManager *_browser;
}


- (id)init {

    if (self = [super init]) {
        _browser = [AFHTTPSessionManager manager];
        _browser.responseSerializer = [AFHTTPResponseSerializer serializer];
        _browser.responseSerializer.acceptableContentTypes = [_browser.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

        _htmlParser = [[ForumHtmlParser alloc] init];
        _phoneName = [DeviceName deviceNameDetail];
    }

    return self;
}

- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString *)code handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView {
    // 需要自己实现
}

- (LoginUser *)getLoginUser {
    // 需要自己实现
    return nil;
}

- (void)logout {
    // 需要自己实现
}

- (void)formList:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)createNewThreadWithFormId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)replyThreadWithId:(int)threadId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)seniorReplyWithThreadId:(int)threadId forFormId:(int)formId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)showPrivateContentById:(int)pmId handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)replyPrivateMessageWithId:(int)pmId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)favoriteFormsWithId:(NSString *)formId handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)unfavoriteFormsWithId:(NSString *)formId handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listFavoriteForms:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listTodayNewThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listMyAllThreadPost:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)forumDisplayWithId:(int)formId andPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)listSearchResultWithSearchid:(NSString *)searchid andPage:(int)page handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    // 需要自己实现
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    // 需要自己实现
}


@end
