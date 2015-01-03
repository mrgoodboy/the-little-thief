//
//  WonScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/25/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "WonScene.h"
#import "GameScene.h"
#import "IntroScene.h"
@interface WonScene()
@property BOOL limitReached;

@end

@implementation WonScene


- (void)didMoveToView:(SKView *)view {
  if ([self checkLimits]) {
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    if (!highScore || self.nextLevel - 1 > highScore) {
      [[NSUserDefaults standardUserDefaults] setInteger:self.nextLevel forKey:@"HighScore"];
      highScore = self.nextLevel - 1;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    return;
  }
  if ((self.nextLevel - 1) % 5 == 0) {
    [self unlockTown];
    return;
  }
  [self normalLvlUp];
}

- (BOOL)checkLimits {
  CGFloat deviceHeight = self.size.height;
  self.limitReached = NO;
  if (deviceHeight <= 480) {
    if (self.nextLevel == 27)
      self.limitReached = YES;
  } else {
    if (self.nextLevel == 43)
      self.limitReached = YES;
  }
  if (self.limitReached) {
    self.backgroundColor = [SKColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:127.0/255.0 alpha:0.95];
    SKLabelNode *congr = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    congr.fontSize = 50;
    congr.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
    congr.text = @"Congratulations Boss!";
    congr.position = CGPointMake(self.size.width/2, self.size.height*8/9);
    [self addChild:congr];
    
    
    SKLabelNode *body1 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    body1.fontSize = 30;
    body1.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
    body1.text = @"You finished all available levels.";
    body1.position = CGPointMake(self.size.width/2, self.size.height*7/9);
    [self addChild:body1];
    
    SKLabelNode *review1 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review1.fontSize = 30;
    review1.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
    review1.text = @"If you liked The Little Thief,";
    review1.position = CGPointMake(self.size.width/2, self.size.height*5/9);
    [self addChild:review1];
    
    SKLabelNode *review2 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review2.fontSize = 30;
    review2.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
    review2.text = @"please consider rating or reviewing";
    review2.position = CGPointMake(self.size.width/2, self.size.height*4/9);
    [self addChild:review2];
    
    SKLabelNode *review0 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review0.fontSize = 30;
    review0.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
    review0.text = @"my game on the App Store.";
    review0.position = CGPointMake(self.size.width/2, self.size.height*3/9);
    [self addChild:review0];
    
    SKLabelNode *body2 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    body2.fontSize = 30;
    body2.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
    body2.text = @"Stay tuned for the next update!";
    body2.position = CGPointMake(self.size.width/2, self.size.height*2/9);
    [self addChild:body2];
    
    SKLabelNode *sign = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    sign.fontSize = 30;
    sign.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
    sign.text = @"Minh Tri Pham";
    sign.position = CGPointMake(self.size.width/2, self.size.height*1/9);
    [self addChild:sign];
    
    return YES;
  }
  return NO;
}

- (void)normalLvlUp {
  SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-won"];
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -1;
  [self addChild:bg];
  
  SKLabelNode *playAgainText = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  playAgainText.fontSize = 40.0;
  playAgainText.text = [NSString stringWithFormat:@"Nice! +%ld seconds", (long)self.bonusSeconds];
  playAgainText.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
  playAgainText.position = CGPointMake(-self.size.width, self.size.height*2/3);
  [self addChild:playAgainText];
  SKAction *wait1 = [SKAction waitForDuration:0.1];
  SKAction *moveIn1 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.3];
  SKAction *wait2 = [SKAction waitForDuration:1.5];
  SKAction *moveOut = [SKAction moveTo:CGPointMake(self.size.width * 2, self.size.height*2/3) duration:0.3];
  SKAction *seq1 = [SKAction sequence:@[wait1, moveIn1, wait2, moveOut]];
  [playAgainText runAction:seq1 completion:^{
    playAgainText.position = CGPointMake(-self.size.width, self.size.height*2/3);
    playAgainText.text = [NSString stringWithFormat:@"Tap to play level %ld", (long)self.nextLevel];
    SKAction *wait3 = [SKAction waitForDuration:0.1];
    SKAction *moveIn2 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.2];
    SKAction *seq2 = [SKAction sequence:@[wait3, moveIn2]];
    [playAgainText runAction:seq2];
  }];
}

- (void)unlockTown {
  NSArray *towns = @[@"Greentown", @"Bluetown", @"Yellowtown", @"Greytown", @"Orangetown", @"Redtown"];
  NSString *nextTown = [towns objectAtIndex:(self.nextLevel-1)/5];
  
  SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-unlocked"];
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -1;
  [self addChild:bg];
  
  SKLabelNode *playAgainText = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  playAgainText.fontSize = 32.0;
  playAgainText.text = [NSString stringWithFormat:@"Yay, you unlocked a new town"];
  playAgainText.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
  playAgainText.position = CGPointMake(-self.size.width, self.size.height*2/3);
  [self addChild:playAgainText];
  SKAction *wait1 = [SKAction waitForDuration:0.1];
  SKAction *moveIn1 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.3];
  SKAction *wait2 = [SKAction waitForDuration:2.0];
  SKAction *moveOut = [SKAction moveTo:CGPointMake(self.size.width * 2, self.size.height*2/3) duration:0.3];
  SKAction *seq1 = [SKAction sequence:@[wait1, moveIn1, wait2, moveOut]];
  [playAgainText runAction:seq1 completion:^{
    playAgainText.position = CGPointMake(-self.size.width, self.size.height*2/3);
    playAgainText.text = [NSString stringWithFormat:@"Tap to rob houses in %@", nextTown];
    SKAction *wait3 = [SKAction waitForDuration:0.1];
    SKAction *moveIn2 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.2];
    SKAction *seq2 = [SKAction sequence:@[wait3, moveIn2]];
    [playAgainText runAction:seq2];
  }];
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
  if (!highScore || self.nextLevel - 1 > highScore) {
    [[NSUserDefaults standardUserDefaults] setInteger:self.nextLevel forKey:@"HighScore"];
    highScore = self.nextLevel - 1;
  }
  
  if (self.limitReached) {
    IntroScene *introScene = [[IntroScene alloc] initWithSize:self.size];
    [self.view presentScene:introScene transition:[SKTransition fadeWithDuration:1.0]];
    return;
  }
  
  GameScene *newGame = [[GameScene alloc] initWithSize:self.size];
  newGame.level = self.nextLevel;
  if (self.nextLevel <= 26 && (self.nextLevel - 1) % 5 == 0)
    newGame.bonusSeconds = 0;
  else
    newGame.bonusSeconds = self.bonusSeconds;
  [self.view presentScene:newGame transition:[SKTransition fadeWithDuration:1.0]];
}


@end
