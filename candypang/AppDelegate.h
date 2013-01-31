//
//  AppDelegate.h
//  candypang
//
//  Created by 경영 임 on 12. 9. 16..
//  Copyright __MyCompanyName__ 2012년. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#define _address @"http://ec2-54-242-84-88.compute-1.amazonaws.com"

extern NSString *const FBSessionStateChangedNotification;

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    NSString *strToken;
    NSString *strName;
    NSArray *friendData;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, assign) int nSkin;
@property (nonatomic, retain) NSString *strToken;
@property (nonatomic, retain) NSString *strName;
@property (nonatomic, retain) NSArray *friendData;

- (BOOL) openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;
- (void) saveTokenfromPlist;
- (void) loadTokenfromPlist;
@end
