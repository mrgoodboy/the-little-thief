//
//  WonScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/25/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "WonScene.h"
#import "GameScene.h"
@interface WonScene()

@property (nonatomic, strong) SKSpriteNode *playAgainButton;

@end

@implementation WonScene


-(void)didMoveToView:(SKView *)view {
  self.playAgainButton = [[SKSpriteNode alloc] initWithColor:[SKColor redColor]
                                                        size:CGSizeMake((self.size.width/3), 50)];
  
  self.playAgainButton.position = CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild:self.playAgainButton];
  
  SKLabelNode *playAgainText = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
  playAgainText.text = @"Next Level";
  playAgainText.color = [SKColor whiteColor];
//  playAgainText.position = CGPointMake(self.playAgainButton.size.width/2, self.playAgainButton.size.height/2);
  [self.playAgainButton addChild:playAgainText];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint location = [touch locationInNode:self];
    if ([self.playAgainButton containsPoint:location]) {
      GameScene *newGame = [[GameScene alloc] initWithSize:self.size];
      newGame.level = self.nextLevel;
      [self.view presentScene:newGame transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
    }
  }
}


@end
