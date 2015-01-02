//
//  GameScene.h
//  nathanspath
//

//  Copyright (c) 2014 pmt. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

#define TLT_YELLOW [SKColor colorWithRed:255.0 green:241.0 blue:1.0 alpha:1.0];

@property NSInteger level;
@property NSInteger bonusSeconds;
@property BOOL onlyInstructions;

@end
