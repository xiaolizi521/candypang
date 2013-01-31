//
//  SplashLayer.m
//  candypang
//
//  Created by 경영 임 on 12. 11. 7..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "SplashLayer.h"
#import "FirstLayer.h"
#import "SimpleAudioEngine.h"


@implementation SplashLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	SplashLayer *layer = [SplashLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}



-(id) init
{
	if( (self=[super init])) {
        
        CCSprite *bg = [CCSprite spriteWithFile:@"cp_splash_bg.png"];
        [bg setPosition:ccp(160,240)];
        [self addChild:bg];

        for(int i=0;i<15;i++)
        {
            CCSprite *star1 = [CCSprite spriteWithFile:@"cp_splash_star.png"];
            [star1 setPosition:ccp(50+i*15,290)];
            [star1 setOpacity:0];
            [star1 setScale:0.5f];
            [star1 runAction:
             [CCSequence actions:
              [CCDelayTime actionWithDuration:i*0.05f],
             [CCSpawn actions:[CCFadeIn actionWithDuration:rand()%20/10],
              [CCRotateTo actionWithDuration:2.0f angle:((rand()%2)*2-1)*360*2],nil],
              [CCFadeOut actionWithDuration:0.2f],nil]
             ];
            [self addChild:star1];
        }
        for(int i=0;i<15;i++)
        {
            CCSprite *star1 = [CCSprite spriteWithFile:@"cp_splash_star.png"];
            [star1 setPosition:ccp(50+i*15,220)];
            [star1 setScale:0.5f];
            [star1 setOpacity:0];
            [star1 runAction:
             [CCSequence actions:
              [CCDelayTime actionWithDuration:i*0.05f],
              [CCSpawn actions:[CCFadeIn actionWithDuration:rand()%20/10],[CCRotateTo actionWithDuration:2.0f angle:((rand()%2)*2-1)*360*2],nil],
              [CCFadeOut actionWithDuration:0.2f],nil]
             ];
            [self addChild:star1];            
        }
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3.0f],[CCCallFunc actionWithTarget:self selector:@selector(replaceToBoardLayer)], nil]];
    
        self.isTouchEnabled = NO;
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"snd_splash.wav" loop:NO];
	}
	return self;
}

-(void) replaceToBoardLayer
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:[FirstLayer scene] withColor:ccc3(0,0,0)]
     ];
}



@end
