//
//  FirstLayer.m
//  candypang
//
//  Created by 경영 임 on 12. 10. 25..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//
#import "FirstLayer.h"
#import "BoardLayer.h"
#import "AppDelegate.h"
#import "SVHTTPRequest.h"
#import "SimpleAudioEngine.h"

@implementation FirstLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	FirstLayer *layer = [FirstLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}



-(id) init
{
	if( (self=[super init])) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        CCSprite *bg = [CCSprite spriteWithFile:@"cp_bg.png"];
        bg.anchorPoint = CGPointZero;
        [bg setPosition:CGPointZero];
        [self addChild:bg];
        
        CCSprite* txtTitle = [CCSprite spriteWithFile:@"cp_title.png"];
        [txtTitle setPosition:ccp(160,345)];
        [self addChild:txtTitle];
        
        labelLog = [CCLabelTTF labelWithString:@"Initiation" fontName:@"Arial" fontSize:12];
        [labelLog setColor:ccc3(50,20,20)];
        [labelLog setPosition:ccp(160,10)];
        [self addChild:labelLog z:100];

//        CCSprite* charPinata = [CCSprite spriteWithFile:@"cp_char_pinata_1.png"];
//        [charPinata setPosition:ccp(160,245)];
//        [charPinata runAction:[CCRepeatForever actionWithAction:
//                          [CCSequence actions:
//                           [CCMoveTo actionWithDuration:1.0f position:ccp(160,235)],
//                           [CCMoveTo actionWithDuration:2.0f position:ccp(160,245)]
//                           , nil]]
//         ];
//        [self addChild:charPinata];
        
        CCMenuItem* menuFaceBook = [CCMenuItemImage itemFromNormalImage:@"cp_btn_facebook_n.png" selectedImage:@"cp_btn_facebook_h.png" target:self selector:@selector(tryFBlogin)];
        [menuFaceBook setPosition:ccp(size.width/2.0f,140)];
        
        CCMenuItem* menuCacao = [CCMenuItemImage itemFromNormalImage:@"cp_btn_cacao_n.png" selectedImage:@"cp_btn_cacao_h.png" target:self selector:@selector(tryFBlogin)];
        [menuCacao setPosition:ccp(size.width/2.0f,95)];
        
        CCMenuItem* menuOffline = [CCMenuItemImage itemFromNormalImage:@"cp_btn_offline_n.png" selectedImage:@"cp_btn_offline_h.png" target:self selector:@selector(tryFBlogin)];
        [menuOffline setPosition:ccp(size.width/2.0f,50)];
        
        btnsMenu = [CCMenu menuWithItems:menuFaceBook,menuCacao,menuOffline, nil];
        btnsMenu.position = CGPointZero;
        [self addChild:btnsMenu];
        [btnsMenu setVisible:NO];
    }
	return self;
}

-(void) onEnterTransitionDidFinish
{
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"snd_bgm_1.mp3" loop:YES];
    self.isTouchEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate loadTokenfromPlist];
    if( [appDelegate strToken] == NULL )
    {
        [labelLog setString:@"Welcome POP the Marble"];
        [btnsMenu setVisible:YES];
    }
    else
    {
        [self trytoGetName];
    }
}
-(void) onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) replaceToBoardLayer
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionSlideInR transitionWithDuration:0.2f scene:[BoardLayer scene]]];
}

-(void) fetchFriendInfo
{
    NSLog(@"Try fetching Friend info");
    if( ![FBSession activeSession].isOpen ) return;
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (!error && result)
         {
             AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
             appDelegate.friendData = [[NSArray alloc] initWithArray:[result objectForKey:@"data"]];
             [self loadingFriendInfoAndPhoto];
         }
         else
         {
             [self fetchFriendInfo];
         }
     }];
}


-(void) loadingFriendInfoAndPhoto
{
    nloadedfriend = 0;
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for(int i=0;i<[[appDelegate friendData] count];i++)
    {
        NSDictionary *friendData = [[appDelegate friendData] objectAtIndex:i];
        NSString *friendId = [friendData objectForKey:@"id"];
        NSString *friendName = [friendData objectForKey:@"name"];
        // Create a texture from the user's profile picture
        //https://graph.facebook.com/me/friends?access_token=[oauth_token]&fields=name,id,picture
        NSString *urlImg = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", friendId];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filename = [NSString stringWithFormat:@"%@.jpg",friendId];
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        //If file exist in documents folder use that one
        if([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            nloadedfriend++;
            [labelLog setString:[NSString stringWithFormat:@"%.2f loading",nloadedfriend/[[appDelegate friendData] count]*100.f]];
            if( nloadedfriend>=[[appDelegate friendData] count])
            {
                [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.2f scene:[BoardLayer scene]]];
            }
        }
        else
        {
            [SVHTTPRequest GET:urlImg
                    parameters:nil
                    saveToPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",friendId]]
                      progress:^(float progress) {
    //                      progressLabel.text = [NSString stringWithFormat:@"Downloading (%.0f%%)", progress*100];
                      }
                    completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                        // process file
                        [labelLog setString:[NSString stringWithFormat:@"%.2f loading",nloadedfriend/[[appDelegate friendData] count]*100.f]];
                        nloadedfriend++;
                        if( nloadedfriend>=[[appDelegate friendData] count])
                        {
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.2f scene:[BoardLayer scene]]];
                        }
                    }];
        }

    }
}

-(void) trytoGetName
{
    [btnsMenu setVisible:NO];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [labelLog setString:@"Loading User Info from server"];
    [SVHTTPRequest POST:[NSString stringWithFormat:@"%@/getname.json",_address] parameters:[NSDictionary dictionaryWithObject:[appDelegate strToken] forKey:@"auth_token"] completion:^(id response,NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if( [response objectForKey:@"username"] == NULL )
         {
             [labelLog setString:@"Connect failed."];
             [btnsMenu setVisible:YES];
         }
         else
         {  //Success get name
             [appDelegate saveTokenfromPlist];
             [labelLog setString:[NSString stringWithFormat:@"%@",[response objectForKey:@"username"]]];
             appDelegate.strName = [response objectForKey:@"username"];
             [appDelegate openSessionWithAllowLoginUI:NO];
         }
     }];
}

-(void) tryFBlogin
{
    [btnsMenu setVisible:NO];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (![FBSession activeSession].isOpen) {
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
    else
    {
        [[FBSession activeSession] close];
        [appDelegate openSessionWithAllowLoginUI:YES];
//        [SVHTTPRequest POST:[NSString stringWithFormat:@"%@/mfb_signin.json",_address] parameters:[NSDictionary dictionaryWithObject:[FBSession activeSession].accessToken forKey:@"ftoken"] completion:^(id response,NSHTTPURLResponse *urlResponse, NSError *error)
//        {
//            if( [response valueForKey:@"auth_token" ] == NULL )
//            {
//                [labelLog setString:@"Connect fail with Facebook"];
//                [btnsMenu setVisible:YES];
//            }
//            else
//            {
//                [appDelegate setStrToken:[response valueForKey:@"auth_token"]];
//                [self trytoGetName];
//            }
//        }];
    }
}

- (void)sessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen)
    {
        [SVHTTPRequest POST:[NSString stringWithFormat:@"%@/mfb_signin.json",_address] parameters:[NSDictionary dictionaryWithObject:[FBSession activeSession].accessToken forKey:@"ftoken"] completion:^(id response,NSHTTPURLResponse *urlResponse, NSError *error)
         {
             NSLog(@"%d",[error code]);
             if( [response valueForKey:@"auth_token" ] == NULL )
             {
                 [labelLog setString:@"Can't loading UserInfo from cpserver"];
                 [btnsMenu setVisible:YES];
             }
             else
             {
                 [self fetchFriendInfo];
                 AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                 [appDelegate setStrToken:[response valueForKey:@"auth_token"]];
                 [appDelegate saveTokenfromPlist];
             }
         }];
    } else {
        [btnsMenu setVisible:YES];
    }
}


@end
