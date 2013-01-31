//
//  GameLayer.h
//  candypang
//
//  Created by 경영 임 on 12. 9. 16..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface GameLayer : CCLayer {
 
    NSMutableArray *gems;
    NSMutableArray *table;
    NSMutableArray *visit;
    NSMutableArray *removedlist;
    NSMutableArray *bombedlist;
    NSMutableArray *effectExploserlist;

    CCLabelTTF* labelScore;
    CCLabelTTF* labelTime;
    CCLabelTTF* labelCombo;
    CCLabelTTF* labelComboEffect;

    CCSprite* bg;
    CCSprite* bg_warn_time;
    CCSprite* bg_blaze_time;
    CCSprite* bg_combo;
    CCSprite* gaugeTime;
    CCSprite* bgComboEffect;
    CCSprite* barCombo;
    CCSprite* barBomb;
    CCSprite* barBombUP;
    
    CCSprite* OptionBG;
    CCMenu* OptionMenu;
    
    CCAnimation *aniComboBG;
    ccTime tBlazeTime;
    ccTime tTimer;
    ccTime tCombo;
    int nPhase;
    int nScore;
    int nCombo;
    int nBomb;
    int nPhaseTimeEffect;
    int nStatusWarnTimeBG;
    int nComboEffect;
    int nBombType;
    
    bool bPause;
    bool bEndGame;
    bool bDoBomb;
    
    ALuint sndTimeTick;
}
-(void) initGems;
+(CCScene *) scene;

@end
