//
//  GameLayer.m
//  candypang
//
//  Created by 경영 임 on 12. 9. 16..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "BoardLayer.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"

#define _pinh 45.0f
#define _pinw 45.0f
#define _fadh 52.0f
#define _fadw 25.0f

#define _OVER_TIME

#define _eff_gem_max 5
#define _eff_bomb_max 7
#define _num_gems 6
#define _gem_type 1

@interface effectExploser : CCSprite{
}
@property int nPhase,nType;
@property ccTime tTime;
@end
@implementation effectExploser
-(void) updateTime : (ccTime)dT
{
    self.tTime+=dT;
    if( self.tTime*20>self.nPhase )
    {
        self.nPhase = self.tTime*20;
        if( self.nType == 0 ) {
            if( self.nPhase<=_eff_gem_max )
            {
                CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"cp_eff_gem_%d.png",self.nPhase]];
                [self setTexture:tex];
            }
        }
        else {
            if( self.nPhase<=_eff_bomb_max )
            {
                CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"cp_eff_bomb_%d.png",self.nPhase]];
                [self setTexture:tex];
            }
        }
    }
}
@synthesize tTime,nPhase,nType;
@end


@interface Gem : CCSprite{
}
-(void) ChangeGemColor : (int)color;
@property int nColor,nDown,nAllDown,nRemoved,nEffType;
@end
@implementation Gem
-(void) ChangeGemColor : (int)color
{
    CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"cp_gem%d%d.png",_gem_type,color]];
    [self setTexture:tex];
    self.nColor = color;
}
-(void) ChangeGemBomb : (int)type
{
    [self setContentSize:CGSizeMake(48, 46)];    
    CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"cp_bomb_%d.png",type]];
    [self setTexture:tex];
    [self setTextureRect:CGRectMake(0,0,48,46)];
    self.nColor = -1 * type;
}
@synthesize nColor,nDown,nAllDown,nRemoved,nEffType;
@end


@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];

	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}

-(int) getBombCount
{
    if( nBombType ==1 ) return 7;
    if( nBombType ==2 ) return 6;
    return 5;
}

-(void) resetBombType
{
     nBombType = 3; if( rand()%100>50 ) { nBombType =2; if (rand()%100>70) nBombType = 1; }   
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
        nCombo = 1; tCombo = 2.0f;
        bPause = false;
        bEndGame = false;
        bDoBomb = false;
        [self resetBombType];
        gems = [[NSMutableArray alloc] init];
        table = [[NSMutableArray alloc] initWithCapacity:8*7];
        visit = [[NSMutableArray alloc] initWithCapacity:8*7];
        removedlist = [[NSMutableArray alloc] initWithCapacity:8*7];
        bombedlist = [[NSMutableArray alloc] initWithCapacity:8*7];
        effectExploserlist = [[NSMutableArray alloc] init];
        for(int i=0;i<[table count];i++) [table addObject:[NSNumber numberWithInt:-1]];

        CGSize size = [[CCDirector sharedDirector] winSize];
        AppDelegate* pAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if( pAppDelegate.nSkin == 0 )
        {
            bg = [CCSprite spriteWithFile:@"cp_bg_layer.png"];
        }
        else{
            bg = [CCSprite spriteWithFile:@"cp_bg_dark.png"];
        }
        bg.anchorPoint = CGPointZero;
        [bg setPosition:CGPointZero];
        [self addChild:bg];
        
        bg_warn_time = [CCSprite spriteWithFile:@"cp_bg_layer_dark.png"];
        bg_warn_time.anchorPoint = CGPointZero;
        [bg_warn_time setPosition:CGPointZero];
        [self addChild:bg_warn_time];
        [bg_warn_time setVisible:NO];
        [bg_warn_time setOpacity:0];
        
        CCMenuItem *starMenuItem = [CCMenuItemImage
                                    itemFromNormalImage:@"cp_btn_pause.png" selectedImage:@"cp_btn_pause_dim.png"
                                    target:self selector:@selector(onPause)];
        [starMenuItem setPosition:ccp(size.width-25,size.height-25)];
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
        starMenu.position = CGPointZero;
        [self addChild:starMenu];

        labelScore = [[CCLabelAtlas labelWithString:@"0" charMapFile:@"cp_num_score.png" itemWidth:24 itemHeight:33 startCharMap:'0'] retain];
		labelScore.position =  ccp( 260,455 );
        labelScore.anchorPoint = ccp(1.0f,0.5f);
		[self addChild: labelScore z:10];
        
        labelCombo = [[CCLabelAtlas labelWithString:@"0" charMapFile:@"cp_num_combo.png" itemWidth:36 itemHeight:42 startCharMap:'0'] retain];
		labelCombo.position =  ccp( 320,439 );
        labelCombo.anchorPoint = ccp(1.0f,1.0f);
		[self addChild: labelCombo];
        [labelCombo setVisible:NO];

        labelComboEffect = [[CCLabelAtlas labelWithString:@"0" charMapFile:@"cp_num_combo.png" itemWidth:36 itemHeight:42 startCharMap:'0'] retain];
        labelComboEffect.anchorPoint = ccp(1.0f,0.0f);
		[self addChild: labelComboEffect z:3];
        [labelComboEffect setVisible:NO];
        
        bgComboEffect = [CCSprite spriteWithFile:@"cp_text_combo.png"];
        bgComboEffect.anchorPoint = ccp(0.0f,0.0f);
        [bgComboEffect setVisible:NO];
        [self addChild:bgComboEffect z:3];
        [labelComboEffect setScale:1.5f];
        [bgComboEffect setScale:1.5f];
        
        labelTime = [[CCLabelAtlas labelWithString:@"60" charMapFile:@"cp_num_time.png" itemWidth:14 itemHeight:18 startCharMap:'0'] retain];
        labelTime.anchorPoint = ccp(0.5f,0.0f);
		labelTime.position =  ccp( size.width/2.0f,0 );
		[self addChild: labelTime z:2];
        
        barBomb=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"cp_bar_bomb.png"] rect:CGRectMake(0,0,96,16)];
        barBomb.anchorPoint = ccp(0,0.5);
        [barBomb setPosition:ccp(43+6,415)];
        [barBomb setTextureRect: CGRectMake(96-6,0,6,16)];
        [self addChild:barBomb z:1];
        
        CCSprite *barBombBG = [CCSprite spriteWithFile:@"cp_bar_bomb_bg.png"];
        barBombBG.anchorPoint = ccp(0,0.5f);
        [barBombBG setPosition:ccp(3,417)];
        [self addChild:barBombBG];
        barBombUP = [CCSprite spriteWithFile:[NSString stringWithFormat:@"cp_bar_bomb_up%d.png",nBombType]];
        barBombUP.anchorPoint = ccp(0.5,0.5f);
        [barBombUP setPosition:ccp(22,417)];
        [self addChild:barBombUP];
        
        CCSprite* barBombB=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"cp_bar_bomb.png"] rect:CGRectMake(0,0,96,16)];
        barBombB.anchorPoint = ccp(0.0,0.5);
        [barBombB setPosition:ccp(-6,8)];
        [barBombB setTextureRect: CGRectMake(0,0,6,16)];
        [barBomb addChild:barBombB];
        [barBomb setVisible:NO];
        
        barCombo=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"cp_bar_combo.png"] rect:CGRectMake(0,0, 320,3)];
        barCombo.anchorPoint = ccp(0,0.5);
        [barCombo setPosition:ccp(0,397)];
        [barCombo setTextureRect: CGRectMake(0,0,0,0)];
        [self addChild:barCombo];
//        CCSprite *barComboBG = [CCSprite spriteWithFile:@"cp_bar_combo_bg.png"];
//        barComboBG.anchorPoint = ccp(0,0.5f);
//        [barComboBG setPosition:ccp(2,400)];
//        [self addChild:barComboBG];

        // to create the gauge with zero power
        gaugeTime=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"cp_bar_time.png"] rect:CGRectMake(0,0, 320,21)];
        gaugeTime.anchorPoint = ccp(0,0.5);
        [gaugeTime setPosition:ccp(0,10)];
        [gaugeTime setTextureRect: CGRectMake(0,0,320,21)];
        [self addChild:gaugeTime z:1];
//        
//        CCSprite* gaugeBG = [CCSprite spriteWithFile:@"cp_bar_time_bg.png"];
//        gaugeBG.anchorPoint = ccp(0,0.5);
//        [gaugeBG setPosition:ccp(0,9)];
//        [self addChild:gaugeBG];

#ifdef _OVER_TIME
        bg_blaze_time = [CCSprite spriteWithFile:@"cp_over_fire.png"];
        bg_blaze_time.anchorPoint = CGPointZero;
        [bg_blaze_time setPosition:CGPointZero];
        [bg_blaze_time setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA,GL_ONE}];
        [bg_blaze_time setOpacity:0];
        [self addChild:bg_blaze_time z:102];
#endif
        
        bg_combo = [CCSprite spriteWithFile:@"cp_combo_bg_1.png"];
        bg_combo.anchorPoint = CGPointZero;
        [bg_combo setPosition:CGPointZero];
        [bg_combo setVisible:NO];
        [self addChild:bg_combo z:101];
        nComboEffect = -1;
        
        [self scheduleUpdate];
        tTimer = 0;
        nPhase = 0;
        nBomb = 0;
        nPhaseTimeEffect = 0;
        nStatusWarnTimeBG = 0;
        tBlazeTime = 0.0f;
        
        OptionBG = [CCSprite spriteWithFile:@"cp_bg_dark.png"];
        OptionBG.anchorPoint = CGPointZero;
        [OptionBG setOpacity:0];
        [OptionBG setVisible:NO];
        [OptionBG setPosition:CGPointZero];
        [self addChild:OptionBG z:255];
        
        CCMenuItem *optItem1 = [CCMenuItemImage
                                    itemFromNormalImage:@"cp_text_start.png" selectedImage:@"cp_text_start.png"
                                    target:self selector:@selector(onResume)];
        [optItem1 setPosition:ccp(160,100)];
        [optItem1 setScale:0.5f];
        OptionMenu = [CCMenu menuWithItems:optItem1, nil];
        OptionMenu.anchorPoint = ccp(0,0);
        OptionMenu.position = ccp(0,-480);
        [OptionBG addChild:OptionMenu];
        
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	}
	return self;
}

-(void) onPause
{
    if( !bPause )
    {
        [OptionBG runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:0.3f],nil]];
        [OptionMenu runAction:[CCMoveTo actionWithDuration:0.3f position:ccp(0,0)]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"snd_pause.wav"];
    }
    bPause = YES;
}

-(void) onResume
{
    if( bPause )
    {
        [OptionBG runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.1f],[CCHide action],nil]];
        [OptionMenu runAction:[CCMoveTo actionWithDuration:0.1f position:ccp(0,-480)]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"snd_pause.wav"];        
    }
    bPause = NO;
}

-(void) setEffectExplosion:(CGPoint)pos nEffType:(int)nType
{
    effectExploser* a;
    if( nType == 0 )
        a = [effectExploser spriteWithFile:@"cp_eff_gem_0.png"];
    else
        a = [effectExploser spriteWithFile:@"cp_eff_bomb_0.png"];
    [a setPosition:pos];
    a.nPhase = 0;
    a.nType = nType;
    [effectExploserlist addObject:a];
    [self addChild:a z:100];
}

- (void) releaseSelf:(id)sender data:(id)ro {
	[self removeChild:ro cleanup:YES];
}

- (void) endTimeOverEffect { nPhaseTimeEffect = 0; }
- (void) endWarnTimeBG { nStatusWarnTimeBG = 0; }
- (void) resetComboEffect
{
    [bg_combo stopAllActions];
    nComboEffect = -1;
    [bg_combo setVisible:NO];
}
- (void) showComboEffect
{
    nComboEffect++;
    if( nComboEffect>=0 )
    {
        [bg_combo setVisible:YES];
        CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"cp_combo_bg_%d.png",nComboEffect%2+1]];
        [bg_combo setTexture: tex];
        [bg_combo stopAllActions];
        [bg_combo runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.1f],[CCCallFunc actionWithTarget:self selector:@selector(showComboEffect)],nil]];
    }
    else
    {
        [self resetComboEffect];
    }
}

-(void) ChangeCombo:(int)newCombo;
{
    nCombo = newCombo;
    if( nCombo<=1) { [labelCombo setVisible:NO]; return; } else [labelCombo setVisible:YES];
    [labelCombo setString:[NSString stringWithFormat:@":%d",nCombo]];
    if( nCombo>=2 )
    {
        int sndCombo = newCombo-1; if(sndCombo>8) sndCombo = 8;
        if( tBlazeTime<=0.0f && (sndCombo==8||sndCombo==16) )
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"snd_fire.wav"];
            tBlazeTime = 5.0f;
        }
        [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"snd_harp0%d.wav",sndCombo]];
//        [labelComboEffect setString:[NSString stringWithFormat:@":%d",nCombo]];
//        [labelComboEffect setPosition:ccp(140,280)];
//        [labelComboEffect runAction:[CCSequence actions:[CCSpawn actions:[CCFadeOut actionWithDuration:1.5f],[CCMoveTo actionWithDuration:0.3f position:ccp(140, 280)], nil], nil]];
//        [labelComboEffect setVisible:YES];
//        
//        [bgComboEffect setPosition:ccp(140,280)];
//        [bgComboEffect runAction:[CCSequence actions:[CCSpawn actions:[CCFadeOut actionWithDuration:1.5f],[CCMoveTo actionWithDuration:0.3f position:ccp(140, 280)], nil], nil]];
//        [bgComboEffect setVisible:YES];
    }
    if( nCombo>5)
    {
        [self showComboEffect];
//        [bg_combo runAction:[CCRepeat actionWithAction:[CCAnimate actionWithAnimation:aniComboBG] times:4]];
    }
}
-(void) effectUpdate:(ccTime)dt
{
    for(int i=0;i<[effectExploserlist count];i++)
    {
        effectExploser* a = (effectExploser*)[effectExploserlist objectAtIndex:i];
        [a updateTime:dt];
        
        if( (a.nType == 0  && a.nPhase>_eff_gem_max) || a.nPhase>_eff_bomb_max )
        {
            [effectExploserlist removeObject:a];
            [self removeChild:a cleanup:YES];
        }
    }
}

-(void)update:(ccTime)dt {
    [self effectUpdate:dt];
    
    if( !bPause && !bDoBomb) { tTimer +=  dt; tCombo +=dt; }
    if( nPhase ==0 && tTimer>1.0)
    {
        CCSprite *ready = [CCSprite spriteWithFile:@"cp_text_ready.png"];
        [ready setPosition:ccp(165,200)];
        [self addChild:ready];
        [ready runAction:[CCSequence actions:
                              [CCDelayTime actionWithDuration:1.0f],
                              [CCFadeOut actionWithDuration:0.5f],
                              [CCCallFuncND actionWithTarget:self selector:@selector(releaseSelf:data:) data:ready],
                              nil]];
        nPhase++; tTimer = 0;
        [[SimpleAudioEngine sharedEngine] playEffect:@"snd_wait.wav"];
    }
    else if ( nPhase ==1 && tTimer>0.8f)
    {
        [self initGems];

        nPhase++; tTimer = 0;
    }
    else if ( nPhase ==2 && tTimer>0.5f)
    {
        self.isTouchEnabled = YES;
        CCSprite *ready = [CCSprite spriteWithFile:@"cp_text_start.png"];
        [ready setPosition:ccp(165,200)];
        [self addChild:ready];
        [ready runAction:[CCSequence actions:
                          [CCDelayTime actionWithDuration:0.5f],
                          [CCFadeOut actionWithDuration:1.0f],
                          [CCCallFuncND actionWithTarget:self selector:@selector(releaseSelf:data:) data:ready],
                          nil]];
        nPhase++; tTimer = 0; tCombo = 2.0f; [self ChangeCombo:1];
    }
    else if ( nPhase == 4 && tTimer>=0.5f)
    {
        for(int i=0;i<7;i++)
        {
            for(int j=0;j<8;j++)
            {
                Gem *org = (Gem*)[gems objectAtIndex:j+i*8];
                [org runAction:[CCSequence actions:[CCDelayTime actionWithDuration:i*0.00+(7-j)*0.15f],[CCTintTo actionWithDuration:0.05f red:128 green:128 blue:128],nil]];
//                [org runAction:[CCSequence actions:[CCDelayTime actionWithDuration:i*0.03+(7-j)*0.21f],[CCFlipY actionWithFlipY:YES],[CCFadeOut actionWithDuration:1.5f],nil]];
            }
        }
        CCSprite *timeOver = [CCSprite spriteWithFile:@"cp_text_timeup.png"];
        [timeOver setPosition:ccp(160,240)];
        [timeOver setOpacity:0];
        [self addChild:timeOver];
        [timeOver runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f],[CCFadeIn actionWithDuration:1.5f],[CCDelayTime actionWithDuration:2.0f],
                             [CCCallFuncND actionWithTarget:self selector:@selector(releaseSelf:data:) data:timeOver]
                             , nil]];
        nPhase++;
    }
    else if ( nPhase == 5 && tTimer>=4.5f)
    {
        nPhase++;
        [[CCDirector sharedDirector] replaceScene:[BoardLayer scene]];
    }
    
    if ( nPhase == 3 && tTimer>=60.0f )
    {
        nPhase++; tTimer = 0.0f;
        bEndGame = YES;
        //EndGame
        tBlazeTime = 0.0f;
        [bg_blaze_time stopAllActions];
        [[SimpleAudioEngine sharedEngine] playEffect:@"snd_gameover.wav"];
    }
    if ( nPhase == 3 && tTimer>=0.0f )
    {
        [gaugeTime setTextureRect: CGRectMake(0,0,320*(60.0-tTimer)/60.f,21)];
        [labelTime setString:[NSString stringWithFormat:@"%d",(int)(60.9-tTimer)]];
    }
    
#ifdef _OVER_TIME
    if ( tBlazeTime>0.0f) tBlazeTime -= dt;
    if ( nPhase == 3 && tBlazeTime>0.0f ) [bg setOpacity:128]; else [bg setOpacity:255];
    if ( nPhaseTimeEffect ==0 && nPhase == 3 && tBlazeTime>0.f )
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"snd_comb.wav"];
        float fRate = 0.5f;
        nPhaseTimeEffect = 1;
        [bg_blaze_time setVisible:YES];
        [bg_blaze_time runAction:[CCSequence actions:[CCFadeIn actionWithDuration:fRate],[CCFadeOut actionWithDuration:fRate],[CCCallFunc actionWithTarget:self selector:@selector(endTimeOverEffect)], nil]];
    }
#endif

    if ( nStatusWarnTimeBG ==0 && nPhase == 3 && tTimer>50.f )
    {
        float fRate = 0.0f;
        if( tTimer>=50.0 ) fRate = 0.5f;
        if( tTimer>=55.0 ) fRate = 0.2f;
        nStatusWarnTimeBG = 1;
        [[SimpleAudioEngine sharedEngine] stopEffect:sndTimeTick];
        sndTimeTick = [[SimpleAudioEngine sharedEngine] playEffect:@"snd_time.wav"];
//        [[SimpleAudioEngine sharedEngine] playEffect:@"snd_xylophone.wav"];
        [bg_warn_time runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:fRate],[CCFadeOut actionWithDuration:fRate],[CCCallFunc actionWithTarget:self selector:@selector(endWarnTimeBG)], nil]];
    }
    
    if( tCombo>1.5f) { [self ChangeCombo:1]; [self resetComboEffect]; }
    
    float fRat = 0.0f; if( nCombo>1 && tCombo<1.5f) fRat = (1.5f-tCombo)/1.5f;
    if( nPhase>=1 ) [barCombo setTextureRect:CGRectMake(0,0,320*fRat,3)];
}

-(Gem*) initGem:(int)nColor
{
    Gem *g = [Gem spriteWithFile:[NSString stringWithFormat:@"cp_gem%d%d.png",_gem_type,nColor]];
    g.nColor = nColor;
    g.nDown = 0;
    g.nAllDown = 0;
    g.nRemoved = 0;
    g.nEffType = 0;
    [self addChild:g];
    return g;
}

-(void) initGems
{
    for(int i=0;i<7;i++)
    {
        for(int j=0;j<8;j++)
        {
            Gem *g = [self initGem:rand()%_num_gems+1];
            [gems addObject:g];
            [g setPosition:CGPointMake(i*_pinw+_fadw, j*_pinh+_fadh+500)];
            [g runAction:
             [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:0.4f+0.05f*j+0.01f*i position:ccp(i*_pinw+_fadw,j*_pinh+_fadh)] ]
             ];
        }
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [gems removeAllObjects];
    [gems dealloc]; gems = nil;
    [visit removeAllObjects];
    [visit dealloc]; visit = nil;
    [removedlist removeAllObjects];
    [removedlist dealloc]; removedlist = nil;
    [bombedlist removeAllObjects];
    [bombedlist dealloc]; bombedlist = nil;
    [effectExploserlist removeAllObjects];
    [effectExploserlist dealloc]; effectExploserlist = nil;
	[super dealloc];
}

-(int) checkGem:(int)color x:(int)x y:(int)y
{
    if( x<0 ) return 0;   if( x>6 ) return 0;
    if( y<0 ) return 0;   if( y>7 ) return 0;
    if( [[visit objectAtIndex:x*8+y] intValue]==1 ) return 0;
    if( ((Gem*)[gems objectAtIndex:x*8+y]).nColor != color) return 0;
    [visit replaceObjectAtIndex:x*8+y withObject:[NSNumber numberWithInt:1]];
    [removedlist addObject:[NSNumber numberWithInt:x*8+y]];
    int a1 = [self checkGem:color x:x-1 y:y];
    int a2 = [self checkGem:color x:x+1 y:y];
    int a3 = [self checkGem:color x:x y:y-1];
    int a4 = [self checkGem:color x:x y:y+1];
    return a1+a2+a3+a4+1;
}

-(void) changeGemColor:(int)color x:(int)x y:(int)y
{
    if( x>0 ) [((Gem*)[gems objectAtIndex:y+(x-1)*8]) ChangeGemColor:color];
    if( y>0 ) [((Gem*)[gems objectAtIndex:y-1+x*8]) ChangeGemColor:color];
    if( x<6 ) [((Gem*)[gems objectAtIndex:y+(x+1)*8]) ChangeGemColor:color];
    if( y<7 ) [((Gem*)[gems objectAtIndex:y+1+x*8]) ChangeGemColor:color];
}

-(void) addScore:(int)nGems
{
    nScore +=nGems*nCombo*(rand()%_num_gems+1);
    [labelScore setString:[NSString stringWithFormat:@"%d",nScore]];
    
    nBomb++;
    [barBomb setTextureRect:CGRectMake(90-96*(nBomb%[self getBombCount])/([self getBombCount]+1),0,96,16)];
    if( nBomb>=[self getBombCount] ){
        nBomb = 0;
        int x=rand()%7;
        int y=rand()%8;
        [barBomb setTextureRect:CGRectMake(6,0,96-6,16)];
        [barBomb runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f],[CCHide action],nil]];
        CCSprite* aniBomb = [CCSprite spriteWithFile:[NSString stringWithFormat:@"cp_bar_bomb_up%d.png",nBombType]];
        [aniBomb setPosition:ccp(22,417)];
        [self addChild:aniBomb z:10];
        [aniBomb runAction:[CCSequence actions:[CCSpawn actions:[CCScaleTo actionWithDuration:0.3f scale:2.0f],nil],[CCFadeOut actionWithDuration:0.1f],nil]];
        
        Gem *kk = [gems objectAtIndex:x*8+y];
        [kk ChangeGemBomb:nBombType];
        [self resetBombType];
        CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"cp_bar_bomb_up%d.png",nBombType]];
        [barBombUP setTexture:tex];
    }
    else{
        [barBomb stopAllActions];
        [barBomb setVisible:YES];
    }
}

-(void) allCheck
{
    [visit removeAllObjects];
    for(int i=0;i<8*7;i++) [visit addObject:[NSNumber numberWithInt:0]];
    
    int nMinTrigger = 1;//rand()%2+1;
    int nTrigger = 0;
    for(int i=0;i<7;i++)
    {
        for(int j=0;j<8;j++)
        {
            if( [[visit objectAtIndex:i*7+j] intValue]!=1 )
            {
                Gem *org = (Gem*)[gems objectAtIndex:j+i*8];
                int Cnt = [self checkGem:org.nColor x:i y:j];
                if ( Cnt >=3 )//|| org.nColor<0 )
                {
                    nTrigger++;
                }
            }
        }
    }
    for(int k=0;k<nMinTrigger-nTrigger;k++)
    {
        int y = (int)(0);
        int x= rand()%7;
        Gem *kk = [gems objectAtIndex:x*8+y];
        if( kk.nColor>0 && kk.nColor>0 )
            [self changeGemColor:kk.nColor x:x y:y];
    }
}

-(void) AddRemoveList:(int)x y:(int)y
{
    [self AddRemoveList:x y:y nType:1];
}

-(void) AddRemoveList:(int)x y:(int)y nType:(int)nType
{
    if( x>=0 && x<=6 && y>=0 && y<=7 )
    {
        Gem* kk = (Gem*)[gems objectAtIndex:x*8+y];
        if( kk.nRemoved==0 )
        {
            if( kk.nColor<0 )
                [bombedlist addObject:kk];
            else
                [removedlist addObject:[NSNumber numberWithInt:x*8+y]];
            kk.nRemoved = 1;
            kk.nEffType = nType;
        }
    }
}

-(void) doBomb:(Gem*)org x:(int)x y:(int)y
{
    int nColor = org.nColor;
    if( org.nColor>=0 ) return;
    org.nColor = 1;
    if( nColor == -3 )
    {
        [self AddRemoveList:x-1 y:y-1];
        [self AddRemoveList:x-1 y:y];
        [self AddRemoveList:x-1 y:y+1];
        [self AddRemoveList:x+1 y:y-1];
        [self AddRemoveList:x+1 y:y];
        [self AddRemoveList:x+1 y:y+1];
        [self AddRemoveList:x y:y-1];
        [self AddRemoveList:x y:y];
        [self AddRemoveList:x y:y+1];
    }
    else if ( nColor == -2 )
    {
        for(int i=0;i<7;i++) [self AddRemoveList:i y:y];
    }
    else if( nColor == -1)
    {
        [self AddRemoveList:x-1 y:y-1];
        [self AddRemoveList:x-1 y:y+1];
        [self AddRemoveList:x+1 y:y-1];
        [self AddRemoveList:x+1 y:y+1];
        for(int i=0;i<8;i++) [self AddRemoveList:x y:i];
        for(int i=0;i<7;i++) if( x!=i ) [self AddRemoveList:i y:y];
    }
}

-(void) CascadeGems:(float)fDelay
{
    for(int i=0;i<[removedlist count];i++)
    {
        int nIdx =[[removedlist objectAtIndex:i] intValue];
        Gem *kk = [gems objectAtIndex:nIdx];
//        [kk runAction:[CCSequence actions:
//                       [CCSpawn actions:[CCFadeOut actionWithDuration:0.2f], [CCScaleTo actionWithDuration:0.2f scale:1.2f],[CCRotateBy actionWithDuration:0.2f angle:3600], nil],
//                       [CCCallFuncND actionWithTarget:self selector:@selector(releaseSelf:data:) data:kk], nil]];
        [kk runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.02f],
                       [CCCallFuncND actionWithTarget:self selector:@selector(releaseSelf:data:) data:kk], nil]];
        int x = (int)(nIdx/8); int y = nIdx%8;
        //        if( kk.nColor<0 ) [self doBomb:kk x:x y:y];
        [self setEffectExplosion:ccp(x*_pinw+_fadw,y*_pinh+_fadh) nEffType:kk.nEffType];
        for(int j=y+1;j<8;j++)
        {
            ((Gem*)[gems objectAtIndex:x*8+j]).nDown++;
        }
        for(int j=0;j<8;j++)
        {
            ((Gem*)[gems objectAtIndex:x*8+j]).nAllDown++;
        }
    }
    
    for(int i=0;i<7;i++)
    {
        int nDown = ((Gem*)[gems objectAtIndex:i*8]).nAllDown;
        for(int j=0;j<8;j++)
        {
            Gem *g = [gems objectAtIndex:j+i*8];
            if( g.nDown>0 )
            {
                [gems replaceObjectAtIndex:(j-g.nDown)+i*8 withObject:g];
                [g runAction:[CCSequence actions:[CCDelayTime actionWithDuration:fDelay],
                 [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:0.2f position:ccp(i*_pinw+_fadw,(j-g.nDown)*_pinh+_fadh)]],nil]];
                g.nDown = 0;
            }
            g.nAllDown = 0;
        }
        for(int j=0;j<nDown;j++)
        {
            Gem* newGem = [self initGem:rand()%_num_gems+1];
            [gems replaceObjectAtIndex:(7-j)+i*8 withObject:newGem];
            [newGem setPosition:ccp(i*_pinw+_fadw,(9+(nDown-j))*_pinh+_fadh)];
            [newGem runAction:[CCSequence actions:[CCDelayTime actionWithDuration:fDelay],
             [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:0.2f position:ccp(i*_pinw+_fadw,(7-j)*_pinh+_fadh)] ],nil]];
        }
    }
}

-(void) expandRemoveList
{
    int nCountList = [removedlist count];
    for(int i=0;i<nCountList;i++)
    {
        int nIdx =[[removedlist objectAtIndex:i] intValue];
        int x = (int)(nIdx/8); int y = nIdx%8;
        [self AddRemoveList:x-1 y:y-1 nType:0];
        [self AddRemoveList:x-1 y:y  nType:0];
        [self AddRemoveList:x-1 y:y+1  nType:0];
        [self AddRemoveList:x y:y-1  nType:0];
        [self AddRemoveList:x y:y+1  nType:0];
        [self AddRemoveList:x+1 y:y-1  nType:0];
        [self AddRemoveList:x+1 y:y  nType:0];
        [self AddRemoveList:x+1 y:y+1  nType:0];
    }
}

-(void) nextBomb
{
    bDoBomb = NO;
    NSMutableArray *bList = [[NSMutableArray alloc] initWithArray:bombedlist];
    [bombedlist removeAllObjects];
    [removedlist removeAllObjects];
    if( [bList count]>0 )
    {
        for(int i=0;i<[bList count];i++)
        {
            Gem* org = [bList objectAtIndex:i];
            org.nRemoved = 0;
            int nIdx = [gems indexOfObject:org];
            [self doBomb:org x:nIdx/8 y:nIdx%8];
        }
        [[SimpleAudioEngine sharedEngine] playEffect:@"snd_pang_2.wav"];
        if( tCombo<1.5f) [self ChangeCombo:nCombo+1];
        tCombo = 0.0f;
        if(tBlazeTime>0.0f) [self expandRemoveList];
        int Cnt = [removedlist count];
        [self addScore:Cnt];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2f],[CCCallFunc actionWithTarget:self selector:@selector(nextBomb)],nil]];
        [self CascadeGems:0.1f];
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( bPause )  return;
    if( bEndGame ) return;
    if( bDoBomb ) return;
    UITouch *t = [touches anyObject];
    CGPoint a = [t locationInView:[t view]];
    CGPoint b = [[CCDirector sharedDirector] convertToUI:a];
    
    int x = (int)((b.x-_fadw+_pinw/2.0f)/_pinw);
    int y = (int)((b.y-_fadh+_pinh/2.0f)/_pinh);

    if( (x>=0 && x<=6) && ( y>=0 && y<=7) )
    {
        Gem *org = (Gem*)[gems objectAtIndex:y+x*8];
        // click the bomb gem
        if( org.nColor<0 )
        {
            bDoBomb = YES;
            [bombedlist removeAllObjects];
            [removedlist removeAllObjects];
            [self doBomb:org x:x y:y];

            [[SimpleAudioEngine sharedEngine] playEffect:@"snd_pang_2.wav"];
            if( tCombo<1.5f) [self ChangeCombo:nCombo+1];
            tCombo = 0.0f;
            if(tBlazeTime>0.0f) [self expandRemoveList];
            int Cnt = [removedlist count];
            [self addScore:Cnt];
            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f],[CCCallFunc actionWithTarget:self selector:@selector(nextBomb)],nil]];
            [self CascadeGems:0.1f];
        }
        // click the normal gem
        else
        {
            int Cnt = 0;
            [removedlist removeAllObjects];
            [visit removeAllObjects];
            for(int i=0;i<8*7;i++) [visit addObject:[NSNumber numberWithInt:0]];
            Cnt = [self checkGem:org.nColor x:x y:y];
            if( Cnt<3 )
            {
                tCombo +=0.5f;
                [[SimpleAudioEngine sharedEngine] playEffect:@"snd_pang_1.wav"];
                return;
            }
            if( tCombo<1.5f) [self ChangeCombo:nCombo+1];
            [[SimpleAudioEngine sharedEngine] playEffect:@"snd_pang_2.wav"];
            for(int i=0;i<[removedlist count];i++)
            {
                Gem *kk = [gems objectAtIndex:[[removedlist objectAtIndex:i] intValue]];
                kk.nRemoved = 1;
            }
            if(tBlazeTime>0.0f) [self expandRemoveList];
            tCombo = 0.0f;
            [self addScore:Cnt];
            if( [bombedlist count]>0)
            {
                bDoBomb = YES;
                [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f],[CCCallFunc actionWithTarget:self selector:@selector(nextBomb)],nil]];
            }
            [self CascadeGems:0.01f];
        }
    }
    [self allCheck];
}

@end
