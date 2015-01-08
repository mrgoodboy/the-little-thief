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
#import "LittleThiefConfig.h"
#import "FBHelper.h"
@interface WonScene()
@property BOOL limitReached;
@property BOOL fbIn;
@property (nonatomic, strong) SKSpriteNode *fbShareNode;
@end

@implementation WonScene



- (void)didMoveToView:(SKView *)view {
  self.fbIn = YES; //block only when unlock
  if ([self checkLimits]) {
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    if (!highScore || self.nextLevel - 1 > highScore) {
      [[NSUserDefaults standardUserDefaults] setInteger:self.nextLevel forKey:@"HighScore"];
      highScore = self.nextLevel - 1;
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
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
    self.fbIn = NO;
    self.fbShareNode = [SKSpriteNode spriteNodeWithImageNamed:@"fb-share"];
    self.fbShareNode.anchorPoint = CGPointMake(0.5, 0);
    self.fbShareNode.position = CGPointMake(self.size.width/2, - self.fbShareNode.frame.size
                                            .height - MARGIN);
    [self addChild:self.fbShareNode];
    SKAction *fbEnter = [SKAction moveToY:MARGIN duration:0.5];
    
    self.backgroundColor = [LittleThiefConfig darkBlue];
    SKLabelNode *congr = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    congr.fontSize = 50;
    congr.fontColor = [LittleThiefConfig yellow];
    congr.text = @"Congratulations Boss!";
    congr.position = CGPointMake(self.size.width/2, self.size.height*8/9);
    [self addChild:congr];
    
    
    SKLabelNode *body1 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    body1.fontSize = 30;
    body1.fontColor = [LittleThiefConfig yellow];
    body1.text = @"You finished all available levels.";
    body1.position = CGPointMake(self.size.width/2, self.size.height*7/9);
    [self addChild:body1];
    
    SKLabelNode *review1 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review1.fontSize = 30;
    review1.fontColor = [LittleThiefConfig yellow];
    review1.text = @"If you liked The Little Thief,";
    review1.position = CGPointMake(self.size.width/2, self.size.height*5/9);
    [self addChild:review1];
    
    SKLabelNode *review2 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review2.fontSize = 30;
    review2.fontColor = [LittleThiefConfig yellow];
    review2.text = @"please consider rating or reviewing";
    review2.position = CGPointMake(self.size.width/2, self.size.height*4/9);
    [self addChild:review2];
    
    SKLabelNode *review0 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review0.fontSize = 30;
    review0.fontColor = [LittleThiefConfig yellow];
    review0.text = @"my game on the App Store.";
    review0.position = CGPointMake(self.size.width/2, self.size.height*3/9);
    [self addChild:review0];
    
    SKLabelNode *body2 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    body2.fontSize = 30;
    body2.fontColor = [LittleThiefConfig yellow];
    body2.text = @"Stay tuned for the next update!";
    body2.position = CGPointMake(self.size.width/2, self.size.height*2/9);
    [self addChild:body2];
    
    SKLabelNode *sign = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    sign.fontSize = 30;
    sign.fontColor = [LittleThiefConfig yellow];
    sign.text = @"Minh Tri Pham";
    sign.position = CGPointMake(self.size.width/2, self.size.height*1/9);
    [self addChild:sign];
    
    [self.fbShareNode runAction:fbEnter completion:^{
      self.fbIn = YES;
    }];
    
    return YES;
  }
  return NO;
}

- (void)normalLvlUp {
  SKAction *winSound = [SKAction playSoundFileNamed:@"win1.wav" waitForCompletion:NO];
  
  SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-won"];
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -1;
  [self addChild:bg];
  
  SKLabelNode *playAgainText = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  playAgainText.fontSize = 40.0;
  playAgainText.text = [NSString stringWithFormat:@"Nice! +%ld seconds", (long)self.bonusSeconds];
  playAgainText.fontColor = [LittleThiefConfig yellow];
  playAgainText.position = CGPointMake(-self.size.width, self.size.height*2/3);
  [self addChild:playAgainText];
  SKAction *wait1 = [SKAction waitForDuration:0.1];
  SKAction *moveIn1 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.3];
  SKAction *wait2 = [SKAction waitForDuration:1.5];
  SKAction *moveOut = [SKAction moveTo:CGPointMake(self.size.width * 2, self.size.height*2/3) duration:0.3];
  SKAction *seq1 = [SKAction sequence:@[wait1, winSound, moveIn1, wait2, moveOut]];
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
  self.fbIn = NO;
  SKAction *unlockSound = [SKAction playSoundFileNamed:@"win2.wav" waitForCompletion:NO];
  NSArray *towns = [LittleThiefConfig getEpisodes];
  NSString *nextTown = [towns objectAtIndex:(self.nextLevel-1)/5];
  SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-unlocked"];
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -1;
  [self addChild:bg];
  
  self.fbShareNode = [SKSpriteNode spriteNodeWithImageNamed:@"fb-share"];
  self.fbShareNode.anchorPoint = CGPointMake(0.5, 0);
  self.fbShareNode.position = CGPointMake(self.size.width/2, - self.fbShareNode.frame.size
                                          .height - MARGIN);
  [self addChild:self.fbShareNode];
  SKAction *fbEnter = [SKAction moveToY:MARGIN duration:0.5];
  
  SKLabelNode *playAgainText = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  playAgainText.fontSize = 32.0;
  playAgainText.text = [NSString stringWithFormat:@"Yay, you unlocked a new land"];
  playAgainText.fontColor = [LittleThiefConfig yellow];
  playAgainText.position = CGPointMake(-self.size.width, self.size.height*2/3);
  [self addChild:playAgainText];
  SKAction *wait1 = [SKAction waitForDuration:0.1];
  SKAction *moveIn1 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.3];
  SKAction *wait2 = [SKAction waitForDuration:2.0];
  SKAction *moveOut = [SKAction moveTo:CGPointMake(self.size.width * 2, self.size.height*2/3) duration:0.3];
  SKAction *seq1 = [SKAction sequence:@[wait1, unlockSound, moveIn1, wait2, moveOut]];
  [playAgainText runAction:seq1 completion:^{
    [self.fbShareNode runAction:fbEnter completion:^{
      self.fbIn = YES;
    }];
    playAgainText.position = CGPointMake(-self.size.width, self.size.height*2/3);
    playAgainText.text = [NSString stringWithFormat:@"Tap to rob houses in %@", nextTown];
    SKAction *wait3 = [SKAction waitForDuration:0.1];
    SKAction *moveIn2 = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height*2/3) duration:0.2];
    SKAction *seq2 = [SKAction sequence:@[wait3, moveIn2]];
    [playAgainText runAction:seq2];
  }];
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    if (self.fbIn == NO)
      return;
    CGPoint location = [touch locationInNode:self];
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    if (!highScore || self.nextLevel - 1 > highScore) {
      [[NSUserDefaults standardUserDefaults] setInteger:self.nextLevel forKey:@"HighScore"];
      highScore = self.nextLevel - 1;
    }
    
    if (self.limitReached) {
      if (location.y < MARGIN + self.fbShareNode.size.height) {
        FBHelper *fb = [[FBHelper alloc] init];
        [fb bragHighScore:self.nextLevel];
        return;
      }
      IntroScene *introScene = [[IntroScene alloc] initWithSize:self.size];
      [self.view presentScene:introScene transition:[SKTransition fadeWithDuration:1.0]];
      return;
    }
    
    
    if (location.y < MARGIN + self.fbShareNode.size.height) {
      FBHelper *fb = [[FBHelper alloc] init];
      [fb bragUnlocked:self.nextLevel];
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

}


@end
