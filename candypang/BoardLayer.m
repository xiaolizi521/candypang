//
//  BoardLayer.m
//  candypang
//
//  Created by 경영 임 on 12. 10. 9..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "BoardLayer.h"
#import "FirstLayer.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"
#import "SVHTTPRequest.h"
#import "AsyncImageView.h"

@implementation BoardLayer


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BoardLayer *layer = [BoardLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        
        fetchedData = nil;
        CGSize size = [[CCDirector sharedDirector] winSize];
        bg = [CCSprite spriteWithFile:@"cp_bg.png"];
        bg.anchorPoint = CGPointZero;
        [bg setPosition:CGPointZero];
        [self addChild:bg];
        
        CCSprite* boardBg = [CCSprite spriteWithFile:@"cp_board_bg.png"];
        [boardBg setPosition:ccp(160,240)];
        [self addChild:boardBg];
        
        CCMenuItem *starMenuItem = [CCMenuItemImage itemFromNormalImage:@"cp_btn_ready_n.png" selectedImage:@"cp_btn_ready_h.png"
                                    target:self selector:@selector(goStart)];
        [starMenuItem setPosition:ccp(235,40)];
        
        CCMenuItem *change = [CCMenuItemImage itemFromNormalImage:@"cp_btn_ready_n.png" selectedImage:@"cp_btn_ready_h.png"
                                                                 target:self selector:@selector(changeSkin)];
        [change setPosition:ccp(size.width/2.0f,20)];
        
        CCMenuItem *fb_logout = [CCMenuItemImage itemFromNormalImage:@"cp_btn_logout_n.png" selectedImage:@"cp_btn_logout_h.png" target:self selector:@selector(logout)];
        [fb_logout setPosition:ccp(80,40)];
        
        CCMenuItem *menuAddCoin = [CCMenuItemImage itemFromNormalImage:@"cp_btn_add_coin_n.png" selectedImage:@"cp_btn_add_coin_h.png" target:self selector:@selector(logout)];
        [menuAddCoin setPosition:ccp(126,451)];

        CCMenuItem *menuAddHeart = [CCMenuItemImage itemFromNormalImage:@"cp_btn_add_heart_n.png" selectedImage:@"cp_btn_add_heart_h.png" target:self selector:@selector(logout)];
        [menuAddHeart setPosition:ccp(285,353)];
        
        CCLabelTTF *labelCoin = [CCLabelTTF labelWithString:@"1234aa" fontName:@"Times" fontSize:16];
        [labelCoin setColor:ccc3(255,210,0)];
        [labelCoin setPosition:ccp(100,400)];
        [self addChild:labelCoin];

        CCLabelTTF *labelHeartTime = [CCLabelTTF labelWithString:@"3:20" fontName:@"Times" fontSize:14];
        [labelHeartTime setColor:ccc3(33,85,126)];
        [labelHeartTime setPosition:ccp(260,352)];
        [self addChild:labelHeartTime];
        
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem,fb_logout,menuAddCoin,menuAddHeart//,change
                            , nil];
        starMenu.position = CGPointZero;
        [self addChild:starMenu];
        
        layerList = [ScrollLayer node];
        [self addChild:layerList];
        
        self.isTouchEnabled = YES;
        tTime = 0;
        [self scheduleUpdate];
        scrollActive = NO;

        if( [FBSession activeSession].isOpen )
        {
            [[FBRequest requestForMe]
             startWithCompletionHandler:
             ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
             {
                 // Did everything come back okay with no errors?
                 if (!error && result)
                 {
                     // If so we can extract out the player's Facebook ID and first name
                     int m_uPlayerFBID = [result.id longLongValue];
                     
                     NSString *m_nsstrUserName = [[NSString alloc] initWithString:result.first_name];
                     NSLog(@"%d %@",m_uPlayerFBID, m_nsstrUserName);
                     
                     // Create a texture from the user's profile picture
                     //https://graph.facebook.com/me/friends?access_token=[oauth_token]&fields=name,id,picture
                     NSString *urlImg = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",result.id];
                     [SVHTTPRequest GET:urlImg parameters:nil completion:^(id response,NSHTTPURLResponse *urlResponse, NSError *error)
                      {
                          if( !error)
                          {
                              UIImage *image = [UIImage imageWithData:response];
//                              CCTexture2D *tex = [[CCTexture2D alloc] initWithImage:image];
//                              CCSprite *sprite = [CCSprite spriteWithTexture:tex rect:CGRectMake(0, 0, 100, 100)];
//                              sprite.position = ccp(160,240);
//                              [sprite setScale:100.0f/[sprite boundingBox].size.width];
//                              [self addChild:sprite];
                          }
                      }];
                 }
             }];
        }
	}
    if( ![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] )
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"snd_bgm_1.mp3" loop:YES];
    [self loadingFriendInfoAndPhoto];
	return self;
}


-(void) logout
{
    AppDelegate* pAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pAppDelegate setStrToken:NULL];
    [pAppDelegate saveTokenfromPlist];
    
    if( [FBSession activeSession].isOpen )
    {
        [pAppDelegate closeSession];
    }
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionSlideInL transitionWithDuration:0.2f scene:
     [FirstLayer scene]]];
}

-(void) goStart
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"snd_pang_1.wav"];
    [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
}

-(void) changeSkin
{
    AppDelegate* pAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pAppDelegate.nSkin = 1-pAppDelegate.nSkin;
    
    if( pAppDelegate.nSkin == 0)
    {
        CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"cp_bg.png"];
        [bg setTexture: tex];
    }
    else if( pAppDelegate.nSkin == 1)
    {
        CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"cp_bg_dark.png"];
        [bg setTexture: tex];
    }
}

-(void) loadingFriendInfoAndPhoto
{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for(int i=0;i<[[appDelegate friendData] count];i++)
    {
        NSDictionary *friendData = [[appDelegate friendData] objectAtIndex:i];
        NSString *friendId = [friendData objectForKey:@"id"];
        NSString *friendName = [friendData objectForKey:@"name"];

        CCSprite* cellbg = [CCSprite spriteWithFile:@"cp_board_cell_bg.png"];
        [cellbg setPosition:ccp(155,i*55)];
        [layerList addChild:cellbg];

        NSString *fn = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",friendId]];
        CCSprite *sprite = [CCSprite spriteWithFile:fn rect:CGRectMake(0, 0, 100, 100)];
        
        if( [[CCDirector sharedDirector] enableRetinaDisplay:YES] ) [sprite setScale:2.0f*0.65f]; else [sprite setScale:0.65f];
        sprite.position = ccp(105,i*55-17);
        [layerList addChild:sprite z:1];
        CCLabelTTF* labelName = [CCLabelTTF labelWithString:friendName dimensions:CGSizeMake(100, 20) alignment:UITextAlignmentLeft fontName:@"Times" fontSize:13];
        [labelName setColor:ccc3(6,62,114)];
        [labelName setPosition:ccp(167,i*55+9)];
        [layerList addChild:labelName z:1];
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint a = [t locationInView:[t view]];
    CGPoint b = [[CCDirector sharedDirector] convertToUI:a];
    touchedPoint = b;
    tBeginTouch = tTime;
    scrollActive = NO;
    scrollV = 0.0f;
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint a = [t locationInView:[t view]];
    CGPoint b = [[CCDirector sharedDirector] convertToUI:a];
    [layerList setPosition:ccp(layerList.position.x, layerList.position.y+b.y-touchedPoint.y)];
    ccTime nT = tTime;
    float v = (nT!=tBeginTouch)?(b.y-touchedPoint.y)/(nT-tBeginTouch):0;
    scrollV = v;
    scrollActive = NO;
    touchedPoint = b;
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint a = [t locationInView:[t view]];
    CGPoint b = [[CCDirector sharedDirector] convertToUI:a];
    
    ccTime nT = tTime;
    if( nT!=tBeginTouch && (b.y-touchedPoint.y!=0) && NO ) {
        float v = (b.y-touchedPoint.y)/(nT-tBeginTouch);
        scrollV = v;
    }
    scrollActive = YES;
    touchedPoint = b;
}

-(void)update:(ccTime)dt {
    tTime +=dt;
    if( scrollActive )
    {
        [layerList setPosition:ccp(layerList.position.x, layerList.position.y+scrollV*dt)];
        scrollV = scrollV-scrollV*0.7f*dt;
        if( scrollV>-32.01f && scrollV<32.01f) scrollActive = NO;
    }
}
@end
