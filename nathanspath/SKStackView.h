//
//  SKStackView.h
//  nathanspath
//
//  Created by Minh Tri Pham on 1/9/15.
//  Copyright (c) 2015 pmt. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKStackView : SKView

- (void)pushScene:(SKScene *)scene;
- (void)popSceneWithTransition:(SKTransition *)transition;
@end
