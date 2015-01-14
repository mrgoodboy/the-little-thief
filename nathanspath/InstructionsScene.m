//
//  InstructionsScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 1/9/15.
//  Copyright (c) 2015 pmt. All rights reserved.
//

#import "InstructionsScene.h"
#import "SKStackView.h"
#import "LittleThiefConfig.h"

@interface InstructionsScene ()

@property NSInteger stage;
@property (nonatomic, strong) SKNode *mainLabel;
@property (nonatomic, strong) SKLabelNode *aLabel;
@property (nonatomic, strong) SKLabelNode *bLabel;
@property (nonatomic, strong) SKSpriteNode *pointerNode;
@property (nonatomic, strong) SKSpriteNode *crossNode;
@property (nonatomic, strong) SKSpriteNode *nextNode;
@property BOOL readyForNext;
@end
@implementation InstructionsScene

- (void)didMoveToView:(SKView *)view {
  
  [self mySetDeviceSuffix];
  [self setBackground];
  [self prepareRunningMusic];
  
  self.playground = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(self.size.width - MARGIN*2, self.size.height - MARGIN*5 - self.undoButton.size.height)];
  self.playground.position = CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild:self.playground];
  [self addNathan];
  
  [self addLabels];
  
  [self generateGraph:3];
  [self positionVertices];
  SKSpriteNode *curPos = [self vertexWithName:[self.visitedVertices lastObject]];
  self.nathan.position = curPos.position;
  
  [self drawEdges];
  
  [self setup];
  self.readyForNext = YES;
  
}

- (void)checkWin {
  //must be overridden like this
}



#pragma mark Instructions

#define FADE_DURATION 0.2
#define WAIT_DURATION 1.0

- (void)instr1 {
  self.stage = 1;
  [self.nextNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION]];
  [self fadeInWithText:@"Rob houses by tapping" andText:@"on them" withWait:NO completion:^{
    self.pointerNode.position = [self vertexWithName:@"1"].position;
    [self.pointerNode runAction:[self getFadeLoop] withKey:@"fadeLoop"];
    
  }];
  
}

- (void)instr2 {
  self.stage = 2;
  [self.pointerNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION] withKey:@"fadeLoop"];
  
  [self fadeInWithText:@"Go rob the next house!" andText:@"" withWait:YES completion:^{
    [self.pointerNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION]];
    
  }];
}

- (void)instr3 {
  self.stage = 3;
  
  [self fadeInWithText:@"Visited houses will have the" andText:@"door open, never go back!" withWait:YES completion:^{
    [self.nextNode runAction:[SKAction fadeInWithDuration:FADE_DURATION]];
    SKSpriteNode *v1 = [self vertexWithName:@"1"];
    self.crossNode.position = v1.position;
    [self.crossNode runAction:[SKAction fadeInWithDuration:FADE_DURATION]];
    
  }];
}

- (void)instr4 {
  self.stage = 4;
  [self.nextNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION]];
  [self.crossNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION]];
  [self fadeInWithText:@"When you robbed all houses," andText:@"go back home" withWait:NO completion:^{
    SKSpriteNode *v0 = [self vertexWithName:@"0"];
    self.pointerNode.position = v0.position;
    self.pointerNode.alpha = 0;
    [self.pointerNode runAction:[self getFadeLoop] withKey:@"fadeLoop"];
    
  }];
}

- (void)instr5 {
  self.stage = 5;
  
  [self.pointerNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION] withKey:@"fadeLoop"];
  
  [self fadeInWithText:@"Yay, you rock!" andText:@"" withWait:YES completion:^{
    [self.nextNode runAction:[SKAction fadeInWithDuration:FADE_DURATION]];
    self.pointerNode.alpha = 0;
  }];
}

- (void)instr6 {
  self.stage = 6;
  [self fadeInWithText:@"During the real game," andText:@"the clock is always ticking" withWait:NO completion:^{
    [self addTimerLabel];
    self.timerLabel.text = @"41";
  }];
  
}

- (void)instr7 {
  self.stage = 7;
  [self fadeInWithText:@"Finish fast to get bonus time" andText:@"" withWait:NO completion:^{
  }];
}


- (void)instr8 {
  self.stage = 8;
  [self.nextNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION]];
  [self fadeInWithText:@"When you mess up," andText:@"you can use the undo button" withWait:NO completion:^{
    [self addUndoButton];
    [self.pointerNode removeFromParent];
    self.pointerNode = [SKSpriteNode spriteNodeWithImageNamed:@"point-down"];
    self.pointerNode.alpha = 0;
    [self.playground addChild:self.pointerNode];
    self.pointerNode.anchorPoint = CGPointMake(0, 0);
    self.pointerNode.zPosition = FINGER_ZPOS;
    self.pointerNode.position = CGPointMake(self.undoButton.position.x - self.size.width/2, self.undoButton.position.y - self.size.height/2 + 10);
    [self.pointerNode runAction:[self getFadeLoop] withKey:@"fadeLoop"];
    
  }];
}

- (void)instr9 {
  self.stage = 9;
  
  self.timerLabel.text = @"39";
  [self.pointerNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION] withKey:@"fadeLoop"];
  [self fadeInWithText:@"But this costs -2 seconds," andText:@"so use it sparingly" withWait:YES completion:^{
    [self.nextNode runAction:[SKAction fadeInWithDuration:FADE_DURATION]];
  }];
}

- (void)instr10 {
  self.stage = 10;
  self.pointerNode.alpha = 0;
  
  [self fadeInWithText:@"Often, it is impossible to see" andText:@"the paths clearly" withWait:NO completion:^{
    [self makeHouseMess];
  }];
}

- (void)instr11 {
  self.stage = 11;
  [self.nextNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION]];
  [self fadeInWithText:@"Use the reposition button to see" andText:@"everything clearly again" withWait:NO completion:^{
    [self addRepositionButton];
    self.pointerNode.anchorPoint = CGPointMake(0.5, 0);
    self.pointerNode.position = CGPointMake(self.repositionButton.position.x - self.size.width/2 - 10, self.repositionButton.position.y - self.size.height/2 + 10);
    [self.pointerNode runAction:[self getFadeLoop] withKey:@"fadeLoop"];
  }];
}

- (void)instr12 {
  self.stage = 12;
  
  [self.pointerNode runAction:[SKAction fadeOutWithDuration:FADE_DURATION] withKey:@"fadeLoop"];
  self.timerLabel.text = @"38";
  [self fadeInWithText:@"Nice!" andText:@"This costs -1 seconds" withWait:YES completion:^{
    [self.nextNode runAction:[SKAction fadeInWithDuration:FADE_DURATION]];
  }];
  
}

- (void)instr13 {
  self.pointerNode.alpha = 0;
  self.nextNode.alpha = 0;
  self.stage = 13;
  self.timerLabel.text = @"38";
  [self fadeInWithText:@"You can view the instructions again" andText:@"whenever  you pause the game" withWait:NO completion:^{
    [self addPauseButton];
    self.pointerNode.anchorPoint = CGPointMake(0.7, 0);
    self.pointerNode.position = CGPointMake(self.pauseButton.position.x - self.size.width/2 - 10, self.pauseButton.position.y - self.size.height/2 + 10);
    [self.pointerNode runAction:[self getFadeLoop] withKey:@"fadeLoop"];
    
  }];
  
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!self.readyForNext)
    return;
  
  for (UITouch *touch in touches) {
    CGPoint location = [touch locationInNode:self.playground];
    if (self.stage == 0) {
      [self instr1];
    } else if (self.stage == 1) {
      SKSpriteNode *v1 = [self vertexWithName:@"1"];
      if ([v1 containsPoint:location]) {
        [self visitVertex:@"1"];
        [self instr2];
      }
    } else if (self.stage == 2) {
      SKSpriteNode *v2 = [self vertexWithName:@"2"];
      if ([v2 containsPoint:location]) {
        [self visitVertex:@"2"];
        [self instr3];
      }
    } else if (self.stage == 3) {
      [self instr4];
    } else if (self.stage == 4) {
      SKSpriteNode *v0 = [self vertexWithName:@"0"];
      if ([v0 containsPoint:location]) {
        [self visitVertex:@"0"];
        [self instr5];
      }
    } else if (self.stage == 5) {
      [self instr6];
    } else if (self.stage == 6) {
      [self instr7];
    } else if (self.stage == 7) {
      [self instr8];
    } else if (self.stage == 8) {
      location = [touch locationInNode:self];
      if ([self.undoButton containsPoint:location]) {
        [self undoMove];
        [self instr9];
      }
    } else if (self.stage == 9) {
      [self instr10];
      
    } else if (self.stage == 10) {
      [self instr11];
      
    } else if (self.stage == 11) {
      location = [touch locationInNode:self];
      if ([self.repositionButton containsPoint:location]) {
        [self playButtonSound];
        [self positionVertices];
        [self drawEdges];
        [self instr12];
        
      }
    } else if (self.stage == 12) {
      [self instr13];
      
    } else if (self.stage == 13) {
      SKSpriteNode *enjoy = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"12%@", self.deviceSuffix]];
      enjoy.zPosition = PAUSE_BG_ZPOS;
      enjoy.alpha = 0;
      self.pointerNode.alpha = 0;
      [self.playground addChild:enjoy];
      [enjoy runAction:[SKAction fadeInWithDuration:0.7] completion:^{
        self.stage = 14;
      }];
    } else {
      SKStackView *view = (SKStackView *)self.view;
      [view popSceneWithTransition:[SKTransition fadeWithDuration:1.0]];
    }
  }
}


#pragma mark Helpers



- (void)addLabels {
  self.mainLabel = [SKNode node];
  self.aLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.aLabel.fontSize = 32.0;
  self.aLabel.fontColor = [LittleThiefConfig yellow];
  self.bLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.bLabel.fontSize = 32.0;
  self.bLabel.fontColor = [LittleThiefConfig yellow];
  self.bLabel.position = CGPointMake(self.bLabel.position.x, self.bLabel.position.y - self.aLabel.frame.size.height - 50);
  NSString *st1 = [NSString stringWithFormat:@"Help the Little Thief find a"];
  NSString *st2 = [NSString stringWithFormat:@"path to rob all houses"];
  self.aLabel.text = st1;
  self.bLabel.text = st2;
  [self.mainLabel addChild:self.aLabel];
  [self.mainLabel addChild:self.bLabel];
  self.mainLabel.position = CGPointMake(0, self.size.height*3/10);
  
  [self.playground addChild:self.mainLabel];
  
}

- (void)positionVertices {
  
  SKShapeNode *edge;
  while ((edge = (SKShapeNode *)[self.playground childNodeWithName:@"edge"])) {
    [edge removeFromParent];
  }
  
  SKSpriteNode *v0 = [self vertexWithName:@"0"];
  SKSpriteNode *v1 = [self vertexWithName:@"1"];
  SKSpriteNode *v2 = [self vertexWithName:@"2"];
  v0.zPosition = HOUSE_ZPOS;
  v1.zPosition = HOUSE_ZPOS;
  v2.zPosition = HOUSE_ZPOS;

  
  v0.position = CGPointMake(-30, self.size.height*(-2.5/10)-20);
  v1.position = CGPointMake(100, -20);
  v2.position = CGPointMake(-100, self.size.height*1/10 - 20);
  
}

- (void)makeHouseMess {
  SKSpriteNode *v0 = [self vertexWithName:@"0"];
  SKSpriteNode *v1 = [self vertexWithName:@"1"];
  SKSpriteNode *v2 = [self vertexWithName:@"2"];
  
  v0.position = CGPointMake(-90, 50);
  v1.position = CGPointMake(0, 0);
  v2.position = CGPointMake(90, -59);
  
  [self drawEdges];
  SKSpriteNode *curPos = [self vertexWithName:[self.visitedVertices lastObject]];
  self.nathan.position = curPos.position;
  
}

- (void)setup {
  self.pointerNode = [SKSpriteNode spriteNodeWithImageNamed:@"point-up"];
  self.pointerNode.alpha = 0;
  self.pointerNode.anchorPoint = CGPointMake(0.2, 1);
  self.pointerNode.zPosition = FINGER_ZPOS;
  [self.playground addChild:self.pointerNode];
  
  self.crossNode = [SKSpriteNode spriteNodeWithImageNamed:@"cross-forbid"];
  self.crossNode.zPosition = FINGER_ZPOS;
  self.crossNode.alpha = 0;
  [self.playground addChild:self.crossNode];
  
  self.nextNode = [SKSpriteNode spriteNodeWithImageNamed:@"next-button"];
  self.nextNode.alpha = 1;
  self.nextNode.anchorPoint = CGPointMake(1, 0);
  self.nextNode.position = CGPointMake(self.size.width/2-MARGIN, -self.size.height/2+MARGIN);
  [self.playground addChild:self.nextNode];
  
  if (self.size.height > 480) {
    SKLabelNode *instructions = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    instructions.text = @"Instructions";
    instructions.fontSize = 28;
    instructions.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    instructions.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    instructions.position = CGPointMake(-self.size.width/2+MARGIN, self.size.height/2-MARGIN);
    [self.playground addChild:instructions];
  }
}


- (void)fadeInWithText:(NSString *)text1 andText:(NSString *)text2 withWait:(BOOL)wait completion:(void (^)(void))callbackBlock {
  self.readyForNext = NO;
  CGFloat waitDuration = WAIT_DURATION;
  
  SKAction *fadeOut = [SKAction fadeOutWithDuration:FADE_DURATION];
  if (wait)
    fadeOut = [SKAction sequence:@[[SKAction waitForDuration:waitDuration], [SKAction fadeOutWithDuration:FADE_DURATION]]];
  
  SKAction *fadeIn = [SKAction fadeInWithDuration:FADE_DURATION];
  [self.mainLabel runAction:fadeOut completion:^{
    self.aLabel.text = text1;
    self.bLabel.text = text2;
    [self.mainLabel runAction:fadeIn completion:^{
      callbackBlock();
      self.readyForNext = YES;
    }];
  }];
}

- (SKAction *)getFadeLoop {
  SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
  SKAction *wait = [SKAction waitForDuration:0.5];
  SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5];
  SKAction *sequence = [SKAction sequence:@[fadeIn, wait,fadeOut, fadeIn, wait, fadeOut, fadeIn]];
  return sequence;
}



@end
