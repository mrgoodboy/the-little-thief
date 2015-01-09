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
#import <GameKit/GameKit.h>


@interface WonScene()
@property BOOL limitReached;
@property BOOL fbIn;
@property (nonatomic, strong) SKSpriteNode *fbShareNode;
@property (nonatomic, strong) NSString *leaderboardIdentifier;
@end

@implementation WonScene

//reporting nextLevel unless reached last level

- (void)didMoveToView:(SKView *)view {
  self.fbIn = YES; //block only when unlock
  if ([self checkLimits]) {
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    if (!highScore || self.nextLevel - 1 > highScore) {
      highScore = self.nextLevel - 1;
      [[NSUserDefaults standardUserDefaults] setInteger:highScore forKey:@"HighScore"];
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
  
  if (self.nextLevel > 35) {
    self.limitReached = YES;
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
    congr.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    congr.position = CGPointMake(self.size.width/2, self.size.height - MARGIN - 5);
    congr.alpha = 0;
    [self addChild:congr];
    [congr runAction:[SKAction fadeInWithDuration:1.0] completion:^{
    
    
    }];
    
    SKLabelNode *body1 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    body1.fontSize = 30;
    body1.fontColor = [LittleThiefConfig yellow];
    body1.text = @"You finished all available levels.";
    body1.position = CGPointMake(self.size.width/2, self.size.height*9/12);
    [self addChild:body1];
    
    SKLabelNode *review1 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review1.fontSize = 30;
    review1.fontColor = [LittleThiefConfig yellow];
    review1.text = @"If you liked The Little Thief,";
    review1.position = CGPointMake(self.size.width/2, self.size.height*7/12);
    [self addChild:review1];
    
    SKLabelNode *review2 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review2.fontSize = 30;
    review2.fontColor = [LittleThiefConfig yellow];
    review2.text = @"please consider rating or reviewing";
    review2.position = CGPointMake(self.size.width/2, self.size.height*6/12);
    [self addChild:review2];
    
    SKLabelNode *review0 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    review0.fontSize = 30;
    review0.fontColor = [LittleThiefConfig yellow];
    review0.text = @"my game on the App Store.";
    review0.position = CGPointMake(self.size.width/2, self.size.height*5/12);
    [self addChild:review0];
    
    SKLabelNode *body2 = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    body2.fontSize = 30;
    body2.fontColor = [LittleThiefConfig yellow];
    body2.text = @"Stay tuned for the next update!";
    body2.position = CGPointMake(self.size.width/2, self.size.height*4/12);
    [self addChild:body2];
    
    SKLabelNode *sign = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    sign.fontSize = 30;
    sign.fontColor = [LittleThiefConfig yellow];
    sign.text = @"Minh Tri Pham";
    sign.position = CGPointMake(self.size.width/2, self.size.height*2/12);
    [self addChild:sign];
    
    [self.fbShareNode runAction:fbEnter completion:^{
      self.fbIn = YES;
      [self prepareReportScore];
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
  if (self.bonusSeconds)
    playAgainText.text = [NSString stringWithFormat:@"Nice! +%ld seconds", (long)self.bonusSeconds];
  else
    playAgainText.text = @"Congrats!!";
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
  SKSpriteNode *bg;
  if (self.size.height > 480)
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-unlocked"];
  else
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-unlocked-4"];
  
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
    
    if (self.limitReached) {
      if (location.y < MARGIN + self.fbShareNode.size.height) {
        FBHelper *fb = [[FBHelper alloc] init];
        [fb bragHighScore:self.nextLevel - 1];
        return;
      }
      IntroScene *introScene = [[IntroScene alloc] initWithSize:self.size];
      [self.view presentScene:introScene transition:[SKTransition fadeWithDuration:1.0]];
      return;
    }
    
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    if (!highScore || self.nextLevel > highScore) {
      highScore = self.nextLevel;
      [[NSUserDefaults standardUserDefaults] setInteger:self.nextLevel forKey:@"HighScore"];
    }
    
    
    if (location.y < MARGIN + self.fbShareNode.size.height) {
      FBHelper *fb = [[FBHelper alloc] init];
      [fb bragUnlocked:self.nextLevel];
      return;
    }
    
    
    GameScene *newGame = [[GameScene alloc] initWithSize:self.size];
    newGame.level = self.nextLevel;
    if ((self.nextLevel - 1) % 5 == 0)
      newGame.bonusSeconds = 0;
    else
      newGame.bonusSeconds = self.bonusSeconds;
    [self.view presentScene:newGame transition:[SKTransition fadeWithDuration:1.0]];
    
  }

}

#pragma mark Game Center

- (void)prepareReportScore {
  GKLocalPlayer *player = [GKLocalPlayer localPlayer];
  if (player.isAuthenticated) {
    NSLog(@"authenticated");
    [player loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
      if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
      } else {
        self.leaderboardIdentifier = leaderboardIdentifier;
        [self reportScore];
      }
    }];
  }
}

//limit reached
- (void)reportScore {
  GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:self.leaderboardIdentifier];
  score.value = self.nextLevel - 1;
  [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
    if (error != nil) {
      NSLog(@"%@", [error localizedDescription]);
    } else {
      NSLog(@"reported score: %lld", score.value);
    }
  }];
  
}

@end
