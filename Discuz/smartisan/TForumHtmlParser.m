//
//  TForumHtmlParser.m
//  Forum
//
//  Created by 迪远 王 on 2018/4/29.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import <IGHTMLQuery/IGHTMLDocument.h>
#import "ForumParserDelegate.h"
#import "TForumHtmlParser.h"
#import "IGXMLNode+Children.h"
#import "NSString+Extensions.h"
#import "THotTHotThreadPage.h"
#import "THotData.h"
#import "THotPage.h"
#import "THotList.h"
#import "CommonUtils.h"
#import "IGHTMLDocument+QueryNode.h"

@implementation TForumHtmlParser
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    return nil;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNodeSet *threadNodeSet = [[document queryNodeWithXPath:@"//*[@id=\"moderate\"]/div"] childAt:0].children;

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    for (IGXMLNode * threadNode in threadNodeSet) {
        Thread *thread = [[Thread alloc] init];

        // 1. ID
        NSString *tID = [threadNode.html stringWithRegular:@"(?<=tid=)\\d+"];
        thread.threadID = tID;

        // 2. 标题
        // 分类
        IGXMLNode *categoryNode = [[[[threadNode childAt:1] childAt:0] childAt:0] childAt:0];
        // 标题的节点
        IGXMLNode *titleNode  = [[[[threadNode childAt:1] childAt:0] childAt:0] childAt:1];
        NSString *title = [categoryNode.text.trim stringByAppendingString:titleNode.text.trim];
        thread.threadTitle = title;

        NSLog(@"p_title \t%@", title);

        //3 是否是置顶帖子
        BOOL isTop = [threadNode.html containsString:@"<span class=\"icon icon-arrow-3\">"];
        thread.isTopThread = isTop;

        //4 是否是精华帖子
        BOOL isGoodness = [threadNode.html containsString:@"<span title=\"精华  1\" class=\"icon icon-finepick\">"];
        thread.isGoodNess = isGoodness;

        //5 是否包含图片
        BOOL isContainsImage = [threadNode.html containsString:@"<span title=\"图片附件\" class=\"icon icon-img\">"];
        thread.isContainsImage = isContainsImage;

        //6 总回帖页数
        int totalPage = 1;
        IGXMLNode *commentNode = [[threadNode childAt:2] childAt:1];
        int commentCount = [[commentNode.text trim] integerValue];
        thread.totalPostPageCount = commentCount % 10 == 0 ? commentCount / 10 : commentCount / 10 + 1;


        //7. 帖子作者
        IGXMLNode *authorNode = [[threadNode childAt:1] childAt:1];
        NSString *authorName = [[[authorNode childAt:0] text] trim];
        thread.threadAuthorName = authorName;

        //8. 作者ID
        thread.threadAuthorID = [[authorNode childAt:0].html stringWithRegular:@"(?<=uid=)\\d+"];

        //9. 回复数量
        thread.postCount = [[commentNode text] trim];

        //10. 查看数量
        IGXMLNode *viewCountNode = [[threadNode childAt:2] childAt:0];
        NSString * openCount = [[viewCountNode text] trim];
        thread.openCount = openCount;

        //11. 最后回帖时间
        IGXMLNode *lastPostTimeNode = [[threadNode childAt:1] childAt:1];
        NSString *lastPostTime = [[lastPostTimeNode childAt:0].text.trim stringWithRegular:@"\\d+-\\d+-\\d+ \\d+:\\d+"];
        thread.lastPostTime = [CommonUtils timeForShort:lastPostTime withFormat:@"yyyy-MM-dd HH:mm"];

        //12. 最后发表的人
        thread.lastPostAuthorName = authorName;

        [threadList addObject:thread];
    }

    ViewForumPage *threadListPage = [[ViewForumPage alloc] init];
    threadListPage.dataList = threadList;

    IGXMLNode *locationNode = [document queryNodeWithClassName:@"location"];
    NSString *fid = [locationNode.html stringWithRegular:@"(?<=forum-)\\d+"];
    threadListPage.forumId = [fid intValue];

    PageNumber *pageNumber = [[PageNumber alloc] init];
    IGXMLNode *pgNode = [document queryNodeWithClassName:@"pg"];
    for (IGXMLNode *node in pgNode.children) {
        if ([node.html containsString:@"<strong>"]){
            pageNumber.currentPageNumber = [[node.text trim] intValue];
            break;
        }
    }

    IGXMLNode *totalPageNode = [pgNode childAt:pgNode.childrenCount -3];
    NSString *totalPage = [totalPageNode.text.trim stringByReplacingOccurrencesOfString:@"... " withString:@""];
    pageNumber.totalPageNumber = [totalPage intValue];
    return threadListPage;
}

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html {
    return nil;
}

- (NSString *)parseErrorMessage:(NSString *)html {
    return nil;
}

- (NSString *)parseSecurityToken:(NSString *)html {
    return nil;
}

- (NSString *)parsePostHash:(NSString *)html {
    return nil;
}

- (NSString *)parserPostStartTime:(NSString *)html {
    return nil;
}

- (NSString *)parseLoginErrorMessage:(NSString *)html {
    return nil;
}

- (NSString *)parseQuote:(NSString *)html {
    return nil;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode *fourRowNode = [document queryWithCSS:@"body > div.main.forums-page.clearfix > div > div.section"][0];

    NSMutableArray<Forum *> *forums = [NSMutableArray array];
    int replaceId = 10000;
    for (IGXMLNode * child in fourRowNode.children) {

        Forum *parent = [[Forum alloc] init];
        for (int i = 0; i < child.childrenCount; ++i) {

            IGXMLNode *childNode = [child childAt:i];
            NSLog(@">>>>>>>> %@", childNode.html);

            if (i == 0){
                parent.forumName = [childNode.text trim];
                parent.forumId = replaceId ++;
                parent.forumHost = host;
                parent.parentForumId = -1;
                [forums addObject:parent];
            } else {

                for (int j = 0; j < [childNode childAt:0].childrenCount; ++j) {

                    IGXMLNode *liNode = [[childNode childAt:0] childAt:j];
                    NSLog(@">>>>>>>> %@", liNode.html);
                    IGXMLNode *nameNode = [[liNode childAt:1] childAt:0];
                    NSString *name = [nameNode.text trim];

                    NSString *forumIdStr = [nameNode.html stringWithRegular:@"(?<=fid=)\\d+"];

                    Forum *childForum = [[Forum alloc] init];
                    childForum.forumName = name;
                    childForum.forumId = [forumIdStr integerValue];
                    childForum.forumHost = host;
                    childForum.parentForumId = parent.forumId;

                    [forums addObject:childForum];
                }

            }

        }
    }

    return forums;
}

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html {
    ViewSearchForumPage *resultPage = [[ViewSearchForumPage alloc] init];

    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) kNilOptions error:nil];

    THotTHotThreadPage *hotTHotThreadPage = [THotTHotThreadPage modelObjectWithDictionary:dictionary];

    PageNumber * pageNumber = [[PageNumber alloc] init];
    pageNumber.currentPageNumber = 1;
    pageNumber.totalPageNumber = (int)hotTHotThreadPage.data.page.pageTotal;
    NSArray<THotList*> * list = hotTHotThreadPage.data.list;

    NSMutableArray<Thread *> *dataList = [NSMutableArray array];
    for (THotList * tHotList in list){
        Thread * thread = [[Thread alloc] init];
        thread.threadTitle = tHotList.subject;
        thread.threadAuthorID = tHotList.authorid;
        thread.threadAuthorName = tHotList.author;
        thread.threadID = tHotList.tid;
        thread.fromFormName = @"";
        thread.isContainsImage = tHotList.attachment != nil && ![tHotList.attachment isEqualToString:@""];
        thread.isGoodNess = NO;
        thread.isTopThread = NO;
        thread.openCount = tHotList.views;
        thread.postCount = tHotList.replies;
        thread.lastPostAuthorName = tHotList.author;
        thread.lastPostTime = [CommonUtils timeForShort:tHotList.dbdateline];
        [dataList addObject:thread];
    }

    resultPage.pageNumber = pageNumber;
    resultPage.dataList = dataList;

    return resultPage;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    
    UserProfile *userProfile = [[UserProfile alloc] init];
    userProfile.profileUserId = userId;

    IGXMLNode *info = [document queryNodeWithXPath:@"//*[@id=\"ct\"]/div/div[2]/div/div[1]/div[3]"];
    NSString * infoHtml = info.html;
    
    userProfile.profileRank = [info.html stringWithRegular:@"(?<=_blank\">)第 \\d+ 级(?=</a>)"];

    IGXMLNode *nameNode = [document queryNodeWithXPath:@"//*[@id=\"uhd\"]/div/h2"];
    userProfile.profileName = [nameNode.text trim];


    //<li><em>注册时间</em>2014-7-24 10:15</li>
    userProfile.profileRegisterDate = [infoHtml stringWithRegular:@"(?<=注册时间</em>)\\d+-\\d+-\\d+ \\d+:\\d+"];
    userProfile.profileRecentLoginDate = [infoHtml stringWithRegular:@"(?<=最后访问</em>)\\d+-\\d+-\\d+ \\d+:\\d+"];;

    NSString * replyCount = [html stringWithRegular:@"(?<=回帖数 )\\d+"];
    NSString * threadCount = [html stringWithRegular:@"(?<=主题数 )\\d+"];
    int count = [replyCount integerValue] + [threadCount integerValue];

    userProfile.profileTotalPostCount = [NSString stringWithFormat:@"%d", count];
    return userProfile;
}
@end
