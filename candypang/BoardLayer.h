//
//  BoardLayer.h
//  candypang
//
//  Created by 경영 임 on 12. 10. 9..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ScrollLayer.h"

@interface BoardLayer : CCLayer {
    CCSprite* bg;
    NSMutableArray *fetchedData;
    ScrollLayer* layerList;
    
    CGPoint touchedPoint;
    ccTime tTime;
    ccTime tBeginTouch;
    float scrollV;
    bool scrollActive;
}
+(CCScene *) scene;
@end
