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
@property (nonatomic, strong) SKSpriteNode *nathan;
@property (nonatomic, strong) SKSpriteNode *arrow;
@end
@implementation IntroScene
-(void)didMoveToView:(SKView *)view {
  self.bg = [SKSpriteNode spriteNodeWithImageNamed:@"intro-screen"];
  self.bg.position = CGPointMake(self.bg.size.width/2, self.bg.size.height/2);
  [self addChild:self.bg];
  
  self.nathan = [SKSpriteNode spriteNodeWithImageNamed:@"intro-nathan"];
  self.nathan.zPosition = 1;
  self.nathan.anchorPoint = CGPointMake(0, 0.5);
  self.nathan.position = CGPointMake(20, self.size.height/3);
  [self addChild:self.nathan];
  
  self.arrow = [SKSpriteNode spriteNodeWithImageNamed:@"intro-swipe-arrow"];
  self.arrow.anchorPoint = CGPointMake(1.0, 0.5);
  self.arrow.position = CGPointMake(self.size.width - 20, self.size.height/3);
  [self addChild:self.arrow];
  
  
  UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  recognizer.direction = UISwipeGestureRecognizerDirectionRight;
  [[self view] addGestureRecognizer:recognizer];
  
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender
{
    CGPoint touchLocation = [sender locationInView:sender.view];
    touchLocation = [self convertPointFromView:touchLocation];

    if (touchLocation.y < self.size.height/2) {
      SKAction *fadeArrow = [SKAction fadeOutWithDuration:0.2];
      SKAction *runAction = [SKAction moveBy:CGVectorMake(self.size.width, 0) duration:0.3];
      runAction.timingMode = SKActionTimingEaseIn;
      [self.arrow runAction:fadeArrow];
      [self.nathan runAction:runAction completion:^{
        GameScene *gameScene= [[GameScene alloc] initWithSize:self.size];
        gameScene.level = 1;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithDuration:1.5]];
      }];

    }
    

}

@end
