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
  
  SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-won"];
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -1;
  [self addChild:bg];
  
  self.playAgainButton = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor]
                                                        size:CGSizeMake((self.size.width), 100)];
  
  self.playAgainButton.position = CGPointMake(-self.size.width, self.size.height*2/3);
  [self addChild:self.playAgainButton];
  
  SKLabelNode *playAgainText = [[SKLabelNode alloc] initWithFontNamed:@"SueEllenFrancisco"];
  playAgainText.fontSize = 40.0;
  playAgainText.text = [NSString stringWithFormat:@"Nice! +%ld seconds", (long)self.bonusSeconds];
  playAgainText.fontColor = [SKColor yellowColor];
  [self.playAgainButton addChild:playAgainText];
  
  SKAction *wait1 = [SKAction waitForDuration:0.1];
  SKAction *moveIn1 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.3];
  SKAction *wait2 = [SKAction waitForDuration:1.5];
  SKAction *moveOut = [SKAction moveTo:CGPointMake(self.size.width * 2, self.size.height*2/3) duration:0.3];
  SKAction *seq1 = [SKAction sequence:@[wait1, moveIn1, wait2, moveOut]];
  [self.playAgainButton runAction:seq1 completion:^{
    self.playAgainButton.position = CGPointMake(-self.size.width, self.size.height*2/3);
    playAgainText.text = [NSString stringWithFormat:@"Tap to play level %ld", (long)self.nextLevel];
    SKAction *wait3 = [SKAction waitForDuration:0.1];
    SKAction *moveIn2 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.2];
    SKAction *seq2 = [SKAction sequence:@[wait3, moveIn2]];
    [self.playAgainButton runAction:seq2];
  }];
  
  
  
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint location = [touch locationInNode:self];
    if (location.y < self.size.height - 70) {
      GameScene *newGame = [[GameScene alloc] initWithSize:self.size];
      newGame.level = self.nextLevel;
      newGame.bonusSeconds = self.bonusSeconds;
      NSLog(@"%ld", (long)newGame.bonusSeconds);
      [self.view presentScene:newGame transition:[SKTransition fadeWithDuration:1.0]];
    }
  }
}


@end
