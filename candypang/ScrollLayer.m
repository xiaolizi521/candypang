//
//  ScrollLayer.m
//  candypang
//
//  Created by 경영 임 on 12. 12. 5..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "ScrollLayer.h"


@implementation ScrollLayer
-(id) init
{
	if( (self=[super init])) {
    }
    return self;
}

- (void) visit
{
    if (!self.visible) {
        return;
    }
    glEnable(GL_SCISSOR_TEST);
    if( [[CCDirector sharedDirector] enableRetinaDisplay:YES] )
        glScissor(24*2, 110*2, 261*2, 215*2);
    else
        glScissor(24, 110, 261, 215);
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}
@end
