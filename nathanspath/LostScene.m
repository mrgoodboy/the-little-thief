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

@implementation LostScene

- (void)didMoveToView:(SKView *)view {
  
  SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"nathan-caught"];
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -1;
  [self addChild:bg];
  
  
  //high score stuff
  NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
  if (!highScore || self.level - 1 > highScore) {
    [[NSUserDefaults standardUserDefaults] setInteger:self.level - 1 forKey:@"HighScore"];
    highScore = self.level - 1;
  }
    
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
    SKNode *levelReached = [SKNode node];
    SKLabelNode *a = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    a.fontSize = 40.0;
    a.fontColor = [LittleThiefConfig yellow];
    SKLabelNode *b = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    b.fontSize = 40.0;
    b.fontColor = [LittleThiefConfig yellow];
    NSString *st1 = [NSString stringWithFormat:@"level reached: %ld", (long)self.level];
    NSString *st2 = [NSString stringWithFormat:@"highest reached: %lu", (long)highScore];;
    b.position = CGPointMake(b.position.x, b.position.y - a.frame.size.height - 50);
    a.text = st1;
    b.text = st2;
    [levelReached addChild:a];
    [levelReached addChild:b];
    levelReached.position = CGPointMake(self.size.width/2, self.size.height*3/4);
    levelReached.alpha = 0;
    [self addChild:levelReached];
    [levelReached runAction:[SKAction fadeInWithDuration:0.3]];
  }];
  
  
  
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  IntroScene *introScene = [[IntroScene alloc] initWithSize:self.size];
  [self.view presentScene:introScene transition:[SKTransition fadeWithDuration:1.0]];
  
  
}


@end
