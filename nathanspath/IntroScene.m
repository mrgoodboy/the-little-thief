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
@property (nonatomic, strong) UISwipeGestureRecognizer *gestureRecognizer;
@end
@implementation IntroScene
-(void)didMoveToView:(SKView *)view {
  [self setBackground];
  
  self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  self.gestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
  [self.view addGestureRecognizer:self.gestureRecognizer];
  
}

-(void)setBackground {
  CGFloat deviceHeight = self.size.height;
  if (deviceHeight <= 480) {
    self.nathan = [SKSpriteNode spriteNodeWithImageNamed:@"intro-nathan5"];
    self.arrow = [SKSpriteNode spriteNodeWithImageNamed:@"intro-swipe-arrow5"];
    self.bg = [SKSpriteNode spriteNodeWithImageNamed:@"intro-screen4"];
  } else if (deviceHeight <= 568) {
    self.nathan = [SKSpriteNode spriteNodeWithImageNamed:@"intro-nathan5"];
    self.arrow = [SKSpriteNode spriteNodeWithImageNamed:@"intro-swipe-arrow5"];
    self.bg = [SKSpriteNode spriteNodeWithImageNamed:@"intro-screen5"];
  } else {
    self.nathan = [SKSpriteNode spriteNodeWithImageNamed:@"intro-nathan"];
    self.arrow = [SKSpriteNode spriteNodeWithImageNamed:@"intro-swipe-arrow"];
    self.bg = [SKSpriteNode spriteNodeWithImageNamed:@"intro-screen"];
  }
  
  self.bg.position = CGPointMake(self.bg.size.width/2, self.bg.size.height/2);
  [self addChild:self.bg];
  
  self.nathan.zPosition = 1;
  self.nathan.anchorPoint = CGPointMake(0, 0.5);
  self.nathan.position = CGPointMake(20, self.size.height*7/24);
  [self addChild:self.nathan];
  
  
  self.arrow.anchorPoint = CGPointMake(1.0, 0.5);
  self.arrow.position = CGPointMake(self.size.width - 20, self.size.height*7/24);
  [self addChild:self.arrow];
  
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
        [self.view removeGestureRecognizer:self.gestureRecognizer];
        GameScene *gameScene= [[GameScene alloc] initWithSize:self.size];
        gameScene.level = 1;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithDuration:1.5]];
      }];

    }
    

}

@end
