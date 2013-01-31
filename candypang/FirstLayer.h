//
//  FirstLayer.h
//  candypang
//
//  Created by 경영 임 on 12. 10. 25..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FirstLayer : CCLayer {
    NSString *_email;
    NSString *_passwd;
    
    CCMenu* btnsMenu;
//    CCMenuItem *menuFaceBook;
    
    CCLabelTTF *labelLog;
    int nloadedfriend;
}

+(CCScene *) scene;

-(void) trytoGetName;
@end
