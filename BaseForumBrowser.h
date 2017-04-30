//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "vBulletinForumEngine.h"
#import "ForumConfig.h"
#import "ForumConfigDelegate.h"

@class AFHTTPSessionManager;
@class ForumHtmlParser;

@interface BaseForumBrowser : NSObject

@property(nonatomic, strong) id<ForumConfigDelegate> configDelegate;

@property(nonatomic, strong) NSString *phoneName;
@property(nonatomic, strong) id<ForumParserDelegate> htmlParser;
@property(nonatomic, strong) AFHTTPSessionManager *browser;

@end