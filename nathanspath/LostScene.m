//
//  LostScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/28/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "LostScene.h"
#import "IntroScene.h"
#import "LittleThiefConfig.h"
#import "GameViewController.h"

@interface LostScene ()

@property (nonatomic, strong) SKLabelNode *leaderboardLabel;
@property (nonatomic, strong) NSString *leaderboardIdentifier;

@property (nonatomic, strong) SKNode *levelReached; //big label
@property (nonatomic, strong) SKLabelNode *aLabel;
@property (nonatomic, strong) SKLabelNode *bLabel;
@property BOOL doneTextActions;
@property (nonatomic, strong) GameViewController *vc;
@end

@implementation LostScene


- (void)didMoveToView:(SKView *)view {
  self.vc = (GameViewController *)self.view.window.rootViewController;
  [self setupScene];
}

- (NSInteger)getHighScore {
  NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
  if (!highScore || self.level > highScore) {
    [[NSUserDefaults standardUserDefaults] setInteger:self.level - 1 forKey:@"HighScore"];
    highScore = self.level;
  }
  return highScore;
}

- (void)setupScene {
  SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-caught"];
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -1;
  [self addChild:bg];
  
  self.leaderboardLabel = [[SKLabelNode alloc] initWithFontNamed:@"SueEllenFrancisco"];
  self.leaderboardLabel.fontSize = 40.0;
  self.leaderboardLabel.text = [NSString stringWithFormat:@"* see best thieves *"];
  self.leaderboardLabel.fontColor = [LittleThiefConfig red];
  self.leaderboardLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  self.leaderboardLabel.position = CGPointMake(self.size.width/2, self.size.height - MARGIN);
  [self addChild:self.leaderboardLabel];
  
  
  
  //high score stuff
  NSInteger highScore = [self getHighScore];
  
  SKAction *gameOverSound = [SKAction playSoundFileNamed:@"game-over.wav" waitForCompletion:NO];
  [self runAction:gameOverSound];
  
  SKLabelNode *playAgainText = [[SKLabelNode alloc] initWithFontNamed:@"SueEllenFrancisco"];
  playAgainText.fontSize = 40.0;
  playAgainText.text = [NSString stringWithFormat:@"You were caught!"];
  playAgainText.fontColor = [LittleThiefConfig yellow];
  playAgainText.position = CGPointMake(self.size.width/2, self.size.height*3/4);
  [self addChild:playAgainText];
  SKAction *wait = [SKAction waitForDuration:1.2];
  SKAction *fadeOut = [SKAction fadeOutWithDuration:0.3];
  SKAction *seq1 = [SKAction sequence:@[wait, fadeOut]];
  [playAgainText runAction:seq1 completion:^{
    self.levelReached = [SKNode node];
    self.aLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    self.aLabel.fontSize = 40.0;
    self.aLabel.fontColor = [LittleThiefConfig yellow];
    self.bLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    self.bLabel.fontSize = 40.0;
    self.bLabel.fontColor = [LittleThiefConfig yellow];
    NSString *st1 = [NSString stringWithFormat:@"level reached: %ld", (long)self.level];
    NSString *st2 = [NSString stringWithFormat:@"highest reached: %lu", (long)highScore];;
    self.bLabel.position = CGPointMake(self.bLabel.position.x, self.bLabel.position.y - self.aLabel.frame.size.height - 50);
    self.aLabel.text = st1;
    self.bLabel.text = st2;
    [self.levelReached addChild:self.aLabel];
    [self.levelReached addChild:self.bLabel];
    self.levelReached.position = CGPointMake(self.size.width/2, self.size.height*3/4);
    self.levelReached.alpha = 0;
    [self addChild:self.levelReached];
    [self.levelReached runAction:[SKAction fadeInWithDuration:0.3] completion:^{
      self.doneTextActions = YES;
    }];
    
  }];
}

- (void)prepareLeaderboard {
  NSLog(@"preparing leaderboard");
  GKLocalPlayer *player = [GKLocalPlayer localPlayer];
  if (player.isAuthenticated) {
    NSLog(@"authenticated");
    [player loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
      if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
      } else {
        self.leaderboardIdentifier = leaderboardIdentifier;
        [self reportScore];
        [self showLeaderboard];
      }
    }];
  } else {
    [self authenticateLocalPlayer];
    [self displayLoginPrompt];
  }
}

- (void)reportScore {
  GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:self.leaderboardIdentifier];
  score.value = self.level;
  
  if (score.value > MIN_REPORT_SCORE) {
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
      if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
      } else {
        NSLog(@"reported score: %lld", score.value);
      }
    }];
  }
}

- (void)showLeaderboard {
  GKGameCenterViewController *gcViewControler = [[GKGameCenterViewController alloc] init];
  gcViewControler.gameCenterDelegate = self;
  gcViewControler.viewState = GKGameCenterViewControllerStateLeaderboards;
  gcViewControler.leaderboardIdentifier = self.leaderboardIdentifier;
  NSLog(@"showing leaderboard %@", self.leaderboardIdentifier);
  [self.vc presentViewController:gcViewControler animated:YES completion:nil];
}

- (void)displayLoginPrompt {

  [self.levelReached runAction:[SKAction fadeOutWithDuration:0.3] completion:^{
    self.aLabel.text = @"login to Game Center";
    self.bLabel.text = @"to see the best";
    
    self.aLabel.fontSize = 40.0;
    self.bLabel.fontSize = 40.0;
    [self.levelReached runAction:[SKAction fadeInWithDuration:0.1]];
    
  }];
}

- (void)authenticateLocalPlayer {
  GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
  localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
    NSLog(@"in handler");
    if (viewController != nil) {
      NSLog(@"logging in");
      [self.vc presentViewController:viewController animated:YES completion:nil];
    } else {
      if ([GKLocalPlayer localPlayer].authenticated) {
        NSLog(@"game center enabled");
        [self prepareLeaderboard];
      } else {
        NSLog(@"game center not enabled");
        
        NSLog(@"displaying prompt");
      }
    }
  };
}


#pragma mark Interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint location = [touch locationInNode:self];
    if (location.y > self.size.height - 2*MARGIN - self.leaderboardLabel.frame.size.height) {
      if (self.doneTextActions == YES)
        [self prepareLeaderboard];
      else {
        [self runAction:[SKAction waitForDuration:2.0] completion:^{
          [self prepareLeaderboard];
        }];
      }
      
      
      
    } else {
      IntroScene *introScene = [[IntroScene alloc] initWithSize:self.size];
      [self.view presentScene:introScene transition:[SKTransition fadeWithDuration:1.0]];
    }
  }
}

#pragma mark GKDelegate

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
  [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
