//
//  IntroScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/27/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "IntroScene.h"
#import "GameScene.h"
#import "AVFoundation/AVFoundation.h"
#import "LittleThiefConfig.h"

@interface IntroScene ()
@property (nonatomic, strong) SKSpriteNode *bg;
@property (nonatomic, strong) SKSpriteNode *nathan;
@property (nonatomic, strong) SKSpriteNode *arrow;
@property (nonatomic, strong) UISwipeGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) SKLabelNode *instructions;
@property (nonatomic, strong) NSArray *towns;
@property NSInteger selectedTownIndex;
@property SKLabelNode *townLabel;
@property (nonatomic, strong) SKSpriteNode *previousTown;
@property (nonatomic, strong) SKSpriteNode *nextTown;
@property (nonatomic, strong) AVAudioPlayer *player;
@end
@implementation IntroScene


- (void)didMoveToView:(SKView *)view {
  
  
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
  {
    [self setTowns];
    [self setBackground];
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    self.gestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.gestureRecognizer];
    
    [self startBgMusic];
    
  }
  else
  {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.backgroundColor = [SKColor blackColor];
    SKLabelNode *instrLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    instrLabel.fontSize = 42.0;
    instrLabel.text = @"Instructions";
    instrLabel.color = [SKColor whiteColor];
    instrLabel.position = CGPointMake(self.size.width/2, self.size.height/2);
    instrLabel.alpha = 0;
    [self addChild:instrLabel];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.3];
    SKAction *wait = [SKAction waitForDuration:1.7];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.3];
    SKAction *sequence = [SKAction sequence :@[fadeIn, wait, fadeOut]];
    
    [instrLabel runAction:sequence completion:^{
      [self viewInstructions];
    }];
  }
}

#pragma mark Setup

- (void)startBgMusic {
  NSString *path = [NSString stringWithFormat:@"%@/intro-music.wav", [[NSBundle mainBundle] resourcePath]];
  self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
  self.player.numberOfLoops = -1;
  [self.player prepareToPlay];
  [self.player play];
  
}

- (void)setTowns {
  NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
  NSMutableArray *tempTowns = [[NSMutableArray alloc] initWithArray:@[@"Greentown"]];
  if (highScore) {
    if (highScore > 5)
      [tempTowns addObject:@"Bluetown"];
    if (highScore > 10)
      [tempTowns addObject:@"Yellowtown"];
    if (highScore > 15)
      [tempTowns addObject:@"Greytown"];
    if (highScore > 20)
      [tempTowns addObject:@"Orangetown"];
    if (highScore > 25)
      [tempTowns addObject:@"Redtown"];
  }
  self.towns = tempTowns;
  self.selectedTownIndex = [self.towns count] - 1;
}

#define UNAVAILABLE_ALPHA 0.3

- (void)setBackground {
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
  self.arrow.position = CGPointMake(self.size.width - 20, self.size.height*9/24);
  [self addChild:self.arrow];
  
  self.instructions = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Light"];
  self.instructions.text = @"?";
  self.instructions.fontColor = [LittleThiefConfig yellow];
  self.instructions.position = CGPointMake(self.size.width-30, 20);
  self.instructions.fontSize = 50.0;
  [self addChild:self.instructions];
  
  self.townLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.townLabel.fontColor = [LittleThiefConfig yellow];
  self.townLabel.fontSize = 32;
  self.townLabel.position = CGPointMake(self.arrow.position.x - self.arrow.size.width/2 - 10, self.arrow.position.y - self.arrow.size.height);
  self.townLabel.text = [self.towns objectAtIndex:self.selectedTownIndex];
  self.townLabel.zPosition = 1;
  [self addChild:self.townLabel];
  
  self.previousTown = [SKSpriteNode spriteNodeWithImageNamed:@"previous-town"];
  self.previousTown.position = CGPointMake(self.townLabel.position.x - self.townLabel.frame.size.width/2-30, self.townLabel.position.y + 10);
  [self addChild:self.previousTown];
  
  self.nextTown = [SKSpriteNode spriteNodeWithImageNamed:@"next-town"];
  self.nextTown.position = CGPointMake(self.townLabel.position.x + self.townLabel.frame.size.width/2+30, self.townLabel.position.y + 10);
  [self addChild:self.nextTown];
  
  if (self.selectedTownIndex == 0)
    self.previousTown.alpha = UNAVAILABLE_ALPHA;
  if (self.selectedTownIndex == [self.towns count] - 1)
    self.nextTown.alpha = UNAVAILABLE_ALPHA;
}

- (void)viewInstructions {
  [self doVolumeFade];
  [self playButtonSound];
  GameScene *gameScene = [[GameScene alloc] initWithSize:self.size];
  gameScene.onlyInstructions = YES;
  [self.view presentScene:gameScene transition:[SKTransition fadeWithDuration:1.0]];
}

#pragma mark Interactions

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint position = [touch locationInNode:self];
    if ([self.instructions containsPoint:position]) {
      [self viewInstructions];
      return;
    }
    
    
    if ([self.previousTown containsPoint:position]) {
      if (self.selectedTownIndex == 0)
        return;
      self.selectedTownIndex--;
      if (self.selectedTownIndex == 0)
        self.previousTown.alpha = UNAVAILABLE_ALPHA;
      if (self.selectedTownIndex < [self.towns count] - 1)
        self.nextTown.alpha = 1;
      [self playButtonSound];
    }
    
    if ([self.nextTown containsPoint:position]) {
      if (self.selectedTownIndex == [self.towns count] - 1)
        return;
      self.selectedTownIndex++;
      if (self.selectedTownIndex == [self.towns count] - 1)
        self.nextTown.alpha = UNAVAILABLE_ALPHA;
      if (self.selectedTownIndex > 0)
        self.previousTown.alpha = 1;
      [self playButtonSound];
    }
    
    self.townLabel.text = [self.towns objectAtIndex:self.selectedTownIndex];
    
    
    
  }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender
{
  CGPoint touchLocation = [sender locationInView:sender.view];
  touchLocation = [self convertPointFromView:touchLocation];
  
  if (touchLocation.y < self.size.height/2) {
    [self doVolumeFade];
    SKAction *swooshSound = [SKAction playSoundFileNamed:@"swoosh.wav" waitForCompletion:NO];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.2];
    SKAction *runAction = [SKAction moveBy:CGVectorMake(self.size.width, 0) duration:0.3];
    runAction.timingMode = SKActionTimingEaseIn;
    [self.arrow runAction:fadeOut];
    [self.previousTown runAction:fadeOut];
    [self.nextTown runAction:fadeOut];
    [self.townLabel runAction:fadeOut];
    [self.nathan runAction:swooshSound];
    [self.nathan runAction:runAction completion:^{
      [self.view removeGestureRecognizer:self.gestureRecognizer];
      GameScene *gameScene= [[GameScene alloc] initWithSize:self.size];
      gameScene.level = (self.selectedTownIndex * 5) + 1;
      //        gameScene.level = 42;
      gameScene.onlyInstructions = NO;
      [self.view presentScene:gameScene transition:[SKTransition fadeWithDuration:1.5]];
    }];
    
  }
}

#pragma mark Helpers

-(void)doVolumeFade
{
  if (self.player.volume > 0.1) {
    self.player.volume = self.player.volume - 0.1;
    [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
  } else {
    // Stop and get the sound ready for playing again
    [self.player stop];
    self.player.currentTime = 0;
    [self.player prepareToPlay];
    self.player.volume = 1.0;
  }
}

- (void)playButtonSound {
  SKAction *buttonSound = [SKAction playSoundFileNamed:@"button-click.wav" waitForCompletion:NO];
  [self runAction:buttonSound];
}


@end
