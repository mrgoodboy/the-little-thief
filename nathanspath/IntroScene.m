//
//  IntroScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/27/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "IntroScene.h"
#import "GameScene.h"
@interface IntroScene ()
@property (nonatomic, strong) SKSpriteNode *bg;
@end
@implementation IntroScene
-(void)didMoveToView:(SKView *)view {
  self.bg = [SKSpriteNode spriteNodeWithImageNamed:@"intro-screen"];
  self.bg.position = CGPointMake(self.bg.size.width/2, self.bg.size.height/2);
  [self addChild:self.bg];
  
  
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint location = [touch locationInNode:self];
    if (location.x >= self.bg.size.width/2 && location.y < self.bg.size.height/2) {\
      GameScene *gameScene= [[GameScene alloc] initWithSize:self.size];
      gameScene.level = 1;
      [self.view presentScene:gameScene transition:[SKTransition fadeWithDuration:1.5]];
    }
    
  }
  
}
@end
