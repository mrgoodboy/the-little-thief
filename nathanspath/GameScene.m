//
//  GameScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/23/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "GameScene.h"
#import "WonScene.h"
#import "LostScene.h"
#import "IntroScene.h"
#include "stdlib.h"
#import "InstructionsScene.h"
#import "LittleThiefConfig.h"
#import "SKStackView.h"



@interface GameScene ()

@end
@implementation GameScene

#pragma mark Lazy Instantiation

-(NSMutableArray *)vertices {
  
  if (!_vertices) {
    _vertices = [[NSMutableArray alloc] init];
  }
  return _vertices;
}

-(NSMutableArray *)visitedVertices {
  if (!_visitedVertices) {
    _visitedVertices = [[NSMutableArray alloc] init];
  }
  return _visitedVertices;
}

-(NSMutableDictionary *)edges {
  if (!_edges) {
    _edges = [[NSMutableDictionary alloc] init];
  }
  return _edges;
}

-(SKTextureAtlas *)runningNathanAtlas {
  if (!_runningNathanAtlas) {
    _runningNathanAtlas = [SKTextureAtlas atlasNamed:@"runningNathan.atlas"];
  }
  return _runningNathanAtlas;
}


#pragma mark Setup

- (void)didMoveToView:(SKView *)view {
  [self mySetDeviceSuffix];
  
  if (self.onlyInstructions) {
    if (self.inInstructions) {
      [self backToIntro];
      return;
    }
    
    self.inGame = NO;
    [self viewInstructions];
    return;
  }
  
  if (self.inInstructions) {
    self.inInstructions = NO;
    return;
  }
  
  [self setBackground];
  [self addUndoButton];
  [self addRepositionButton];
  [self addPauseButton];
  [self addLevelLabel];
  [self addTimerLabel];
  self.gameDuration = [self getGameDuration];
  
  if (self.level > 5)
    [self startBgMusic];
  [self prepareRunningMusic];
  [self prepareClockTicker];
  
  self.playground = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(self.size.width - MARGIN*2, self.size.height - MARGIN*5 - self.undoButton.size.height)];
  self.playground.position = CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild:self.playground];
  [self addNathan];
  
  NSInteger numOfVertices = (NSInteger)ceil(self.level/2.0) + 3;
  if (numOfVertices > 14)
    numOfVertices = 14;
  [self generateGraph:numOfVertices];
  [self positionVertices];
  [self drawEdges];
  
  self.inGame = YES;
}

- (void)willMoveFromView:(SKView *)view {
  [self doVolumeFade];
}

- (void)startBgMusic {
  NSString *path = [NSString stringWithFormat:@"%@/bg-music.mp3", [[NSBundle mainBundle] resourcePath]];
  self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
  self.player.numberOfLoops = -1;
  [self.player prepareToPlay];
  [self.player play];
}

- (void)prepareRunningMusic {
  NSString *runPath = [NSString stringWithFormat:@"%@/running.wav", [[NSBundle mainBundle] resourcePath]];
  self.runPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:runPath] error:nil];
  [self.runPlayer prepareToPlay];
  self.runPlayer.numberOfLoops = -1;
}

- (void)prepareClockTicker {
  NSString *path = [NSString stringWithFormat:@"%@/clock-ticking.wav", [[NSBundle mainBundle] resourcePath]];
  self.clockPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil];
  [self.clockPlayer prepareToPlay];
}


- (void)addLevelLabel {
  SKLabelNode *levelLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  levelLabel.fontSize = 42.0;
  levelLabel.text = [NSString stringWithFormat:@"lvl %ld", (long)self.level];
  levelLabel.color = [SKColor whiteColor];
  levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
  levelLabel.position = CGPointMake(MARGIN, self.size.height - MARGIN);
  [self addChild:levelLabel];
  
}

- (void)addTimerLabel {
  
  self.timerLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.timerLabel.text = [NSString stringWithFormat:@"%d", 999];
  self.timerLabel.fontSize = 42.0;
  self.timerLabel.color = [SKColor whiteColor];
  self.timerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
  self.timerLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
  self.timerLabel.position = CGPointMake(self.size.width - MARGIN, self.size.height - MARGIN);
  
  [self addChild:self.timerLabel];
}

- (void)addNathan {
  self.nathan = [SKSpriteNode spriteNodeWithImageNamed:@"undo-button"];
  self.nathan.alpha = 0.0;
  [self.playground addChild:self.nathan];
}

- (void)addUndoButton {
  self.undoButton = [SKSpriteNode spriteNodeWithImageNamed:@"undo-button"];
  self.undoButton.anchorPoint = CGPointZero;
  self.undoButton.position = CGPointMake(MARGIN, MARGIN);
  
  [self addChild:self.undoButton];
}

- (void)addPauseButton {
  self.pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause-button"];
  self.pauseButton.anchorPoint = CGPointMake(1, 0);
  self.pauseButton.position = CGPointMake(self.size.width - MARGIN, MARGIN + 5);
  
  
  [self addChild:self.pauseButton];
}

- (void)addRepositionButton {
  self.repositionButton = [SKSpriteNode spriteNodeWithImageNamed:@"shuffle-button"];
  self.repositionButton.anchorPoint = CGPointMake(0.5, 0);
  self.repositionButton.position = CGPointMake(self.size.width/2, MARGIN);
  [self addChild:self.repositionButton];
}

- (void)setBackground {
  SKSpriteNode *bg;
  if (self.level == 0) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-green"];
  } else if (self.level < 6) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-blue"];
  } else if (self.level < 11) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-purple"];
  } else if (self.level < 16) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-yellow"];
  } else if (self.level < 21) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-grey"];
  } else if (self.level < 26) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-orange"];
  } else if (self.level < 31){
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-red"];
  } else {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-black"];
  }
  
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -10.0;
  [self addChild:bg];
  
}

- (void)mySetDeviceSuffix {
  CGFloat deviceHeight = self.size.height;
  if (deviceHeight <= 480) {
    self.deviceSuffix = @"-4";
    self.sizeChangeLevel = 12;
  } else if (deviceHeight <= 568) {
    self.deviceSuffix = @"-5";
    self.sizeChangeLevel = 13;
  } else if (deviceHeight <= 667) {
    self.deviceSuffix = @"-6";
    self.sizeChangeLevel = 14;
  } else {
    self.deviceSuffix = @"";
    self.sizeChangeLevel = 15;
  }
}

#pragma mark Graph Creation

#define HOUSE_SIZE 50.0
#define HOUSE_MARGIN_SIZE 30.0


- (CGPoint)positionForSquare:(NSInteger)square forRows:(NSInteger)rows forCols:(NSInteger)cols {
  CGFloat houseSize = self.level < self.sizeChangeLevel ? HOUSE_SIZE : HOUSE_SIZE*4/5;
  NSInteger row = (square + cols - 1) / cols;
  CGFloat yPos = (row - 1) * (houseSize+HOUSE_MARGIN_SIZE) + houseSize/2 - self.playground.size.height/2;
  NSInteger col = square - (cols * (row - 1));
  
  CGFloat xPos = (col-1) * (houseSize+HOUSE_MARGIN_SIZE) + houseSize/2 - self.playground.size.width/2;
  return CGPointMake(xPos, yPos);
}

- (void)positionVertices {
  //grid generation
  CGFloat houseSize = self.level < self.sizeChangeLevel ? HOUSE_SIZE : HOUSE_SIZE*4/5;
  
  NSInteger cols = self.playground.size.width/(houseSize+HOUSE_MARGIN_SIZE);
  NSInteger rows = self.playground.size.height/(houseSize+HOUSE_MARGIN_SIZE);
  NSInteger squares = cols * rows;
  NSMutableArray *takenSquares= [[NSMutableArray alloc] initWithCapacity:squares];
  for (int i = 0; i < squares; i++) {
    takenSquares[i] = [NSNumber numberWithBool:NO];
  }
  for (NSString *vertexName in self.vertices) {
    SKSpriteNode *vertex = [self vertexWithName:vertexName];
    
    //positioning
    NSInteger square;
    while (1) {
      square = (arc4random() % squares) + 1;
      if (takenSquares[square - 1] == [NSNumber numberWithBool:NO]) {
        takenSquares[square - 1] = [NSNumber numberWithBool:YES];
        break;
      }
    }
    CGPoint position = [self positionForSquare:square forRows:rows forCols:cols];
    CGPoint noise = CGPointMake([self randomFloatBetween:-HOUSE_MARGIN_SIZE/2 and:HOUSE_MARGIN_SIZE/2],
                                [self randomFloatBetween:-HOUSE_MARGIN_SIZE/2 and:HOUSE_MARGIN_SIZE/2]);
    position.x += noise.x;
    position.y += noise.y;
    
    //adjust to best use space
    CGFloat leftVerticalSpace = self.playground.size.height - rows * houseSize - (rows-1) * HOUSE_MARGIN_SIZE;
    position.y += leftVerticalSpace/2;
    
    CGFloat leftHorizontalSpace = self.playground.size.width - cols * houseSize - (cols-1) * HOUSE_MARGIN_SIZE;
    position.x += leftHorizontalSpace/2;
    
    //prevent touching buttons, usually doesn't happen
    CGFloat badBottomOffset = position.y - vertex.size.height/2 + self.playground.size.height/2;
    if (badBottomOffset < 0) {
      position.y -= badBottomOffset;
    }
    
    CGFloat badTopOffset = position.y + vertex.size.height/2 - self.playground.size.height/2;
    if (badTopOffset > 0) {
      position.y -= badTopOffset;
      
    }

    vertex.position = position;
    
    SKSpriteNode *curPos = [self vertexWithName:[self.visitedVertices lastObject]];
    self.nathan.position = curPos.position;
  }
}

- (void)generateGraph:(NSInteger)numOfVertices {
  
  for (int i = 0; i < numOfVertices; i++) {
    SKSpriteNode *vertex;
    
    if (i == 0) {
      SKTexture *houseTexture = [SKTexture textureWithImageNamed:[self houseWithAppendix:@"house-h"]];
      vertex = [SKSpriteNode spriteNodeWithTexture:houseTexture];
    } else {
      SKTexture *houseTexture = [SKTexture textureWithImageNamed:[self houseWithAppendix:@"house-u"]];
      vertex = [SKSpriteNode spriteNodeWithTexture:houseTexture];
    }
    vertex.name = [NSString stringWithFormat:@"%d", i];
    
    [self.playground addChild:vertex];
    [self.vertices addObject:vertex.name];
    
    //cycle creation
    if (i > 0) {
      SKSpriteNode *previousVertex = self.vertices[i - 1];
      [self.edges setObject:[NSMutableArray arrayWithArray:@[previousVertex]] forKey:vertex.name];
      [[self.edges objectForKey:previousVertex] addObject:vertex.name];
      
    } else {
      [self.edges setObject:[[NSMutableArray alloc] init] forKey:vertex.name];
    }
  }
  [[self.edges objectForKey:self.vertices[0]] addObject:self.vertices[numOfVertices - 1]];
  [[self.edges objectForKey:self.vertices[numOfVertices - 1]] addObject:self.vertices[0]];
  
  //noise edges
  
  NSInteger numOfNoiseEdges = numOfVertices / 3;
  for (int i = 0; i < numOfNoiseEdges; i++) {
    NSString *originVertex = self.vertices[i];
    NSMutableArray *adjacent = [self.edges objectForKey:originVertex];
    while (1) {
      NSString *newAdjacent = self.vertices[arc4random() % numOfVertices];
      if (![adjacent containsObject:newAdjacent] && ![originVertex isEqualToString:newAdjacent]) {
        [adjacent addObject:newAdjacent];
        [[self.edges objectForKey:newAdjacent] addObject:originVertex];
        break;
      }
      //max connection
      if ([adjacent count] >= [self.vertices count] - 1)
        break;
    }
  }
  [self.visitedVertices addObject:self.vertices[0]];
  
  
}

- (void)drawEdges {
  NSMutableDictionary *added = [[NSMutableDictionary alloc] init];
  for (NSString *vertexName in self.edges) {
    
    SKSpriteNode *vertex = [self vertexWithName:vertexName];
    CGPoint originPoint = vertex.position;
    for (NSString *adjacentName in [self.edges objectForKey:vertexName]) {
      if ([added objectForKey:adjacentName] && [[added objectForKey:adjacentName] containsObject:vertexName])
        continue;
      SKSpriteNode *adjacent = [self vertexWithName:adjacentName];
      CGPoint destinationPoint = adjacent.position;
      SKShapeNode *edge = [SKShapeNode node];
      edge.name = @"edge";
      CGMutablePathRef pathToDraw = CGPathCreateMutable();
      CGPathMoveToPoint(pathToDraw, NULL, originPoint.x, originPoint.y);
      CGPathAddLineToPoint(pathToDraw, NULL, destinationPoint.x, destinationPoint.y);
      edge.path = pathToDraw;
      edge.zPosition = -9;
      if (self.level > 30)
        [edge setStrokeColor:[SKColor lightGrayColor]];
      else
        [edge setStrokeColor:[SKColor blackColor]];
      [self.playground addChild:edge];
      
      if ([added objectForKey:vertexName]) {
        [[added objectForKey:vertexName] addObject:adjacentName];
      } else {
        [added setObject:[NSMutableArray arrayWithArray:@[adjacentName]] forKey:vertexName];
      }
      
    }
  }
}


#pragma mark Interaction

#define POINTS_PER_SEC 250.0
#define FADE_OUT_DURATION 0.1
#define FADE_IN_DURATION 0.3
#define UNDO_PENALTY 2.0
#define REDRAW_PENALTY 1.0


- (void)visitVertex:(NSString *)vertexName {
  SKSpriteNode *currentVertex = [self vertexWithName:[self.visitedVertices lastObject]];
  SKSpriteNode *vertex = [self vertexWithName:vertexName];
  CGPoint targetPoint = vertex.position;
  CGPoint currentPosition = currentVertex.position;
  CGPoint offset = CGPointMake(targetPoint.x - currentPosition.x, targetPoint.y - currentPosition.y);
  CGFloat length = sqrtf(offset.x * offset.x + offset.y * offset.y);
  CGFloat duration = length / POINTS_PER_SEC;
  
  //texture change 1
  NSString *lastVertexName = [self.visitedVertices lastObject];
  SKTexture *visitedHouse = [SKTexture textureWithImageNamed:[self houseWithAppendix:@"house-v"]];
  [self changeTextureOfVertex:lastVertexName toTexture:visitedHouse];
  
  [self.visitedVertices addObject:vertexName];
  
  NSArray *textures = [self getTexturesFromDirection:offset];
  SKAction *runAction = [SKAction repeatActionForever:
                         [SKAction animateWithTextures:textures
                                          timePerFrame:0.1f resize:NO restore:YES]];
  if (self.direction == 1) {
    self.nathan.zPosition = -1;
  }
  [self.directionHistory addObject:[NSNumber numberWithLong:self.direction]];
  
  
  [self.runPlayer play];
  [self.nathan runAction:runAction withKey:@"runAction"];
  SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:FADE_IN_DURATION];
  SKAction *moveAction = [SKAction moveTo:targetPoint duration:duration];
  SKAction *leaveGroup = [SKAction group:@[fadeIn, moveAction]];
  SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:FADE_OUT_DURATION];
  SKAction *sequence = [SKAction sequence :@[leaveGroup, fadeOut]];
  [self.nathan runAction:sequence completion:^{
    [self.runPlayer stop];
    SKAction *door = [SKAction playSoundFileNamed:@"door-open.wav" waitForCompletion:NO];
    [self.nathan runAction:door];
    
    [self checkWin];
    SKTexture *currentHouse = [SKTexture textureWithImageNamed:[self houseWithAppendix:@"house-c"]];
    [self changeTextureOfVertex:vertexName toTexture:currentHouse];
    self.nathan.zPosition = 0;
  }];
}

- (void)undoMove {
  NSString *lastVertexName = [self.visitedVertices lastObject];
  if (lastVertexName == [self.visitedVertices firstObject]) {
    [self emitFlashWithMessage:@"no moves to undo"];
    [self playErrorSound];
    return;
  }
  if ([self nathanIsMoving]) {
    [self emitFlashWithMessage:@"thief must not move"];
    [self playErrorSound];
    return;
  }
  
  SKAction *undoSound = [SKAction playSoundFileNamed:@"undo-move.wav" waitForCompletion:NO];
  [self.nathan runAction:undoSound];
  [self emitFlashWithMessage:[NSString stringWithFormat:@"-%d", (int)UNDO_PENALTY]];

  
  self.startTime -= UNDO_PENALTY;
  
  NSString *newVertexName = [self.visitedVertices objectAtIndex:[self.visitedVertices count] - 2];
  SKSpriteNode *newVertex = [self vertexWithName:newVertexName];
  
  SKSpriteNode *currentVertex = [self vertexWithName:[self.visitedVertices lastObject]];
  CGPoint targetPoint = newVertex.position;
  CGPoint currentPosition = currentVertex.position;
  CGPoint offset = CGPointMake(targetPoint.x - currentPosition.x, targetPoint.y - currentPosition.y);
  CGFloat length = sqrtf(offset.x * offset.x + offset.y * offset.y);
  CGFloat duration = length / POINTS_PER_SEC/ 4;
  
  NSInteger lastDirection = [[self.directionHistory lastObject] integerValue];
  if (lastDirection == 0)
    self.direction = 1;
  else if (lastDirection == 1)
    self.direction = 2;
  else if (lastDirection == 3)
    self.direction = 4;
  else
    self.direction = 3;
  
  NSArray *textures = [self getTexturesFromDirection:offset];

  SKAction *runAction = [SKAction repeatActionForever:
                         [SKAction animateWithTextures:textures
                                          timePerFrame:0.1f resize:NO restore:YES]];
  
  [self.nathan runAction:runAction withKey:@"runAction"];
  SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:FADE_IN_DURATION];
  SKAction *moveAction = [SKAction moveTo:targetPoint duration:duration];
  SKAction *leaveGroup = [SKAction group:@[fadeIn, moveAction]];
  SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:FADE_OUT_DURATION];
  SKAction *sequence = [SKAction sequence :@[leaveGroup, fadeOut]];
  [self.nathan runAction:sequence completion:^{

    self.nathan.position = newVertex.position;
  }];
  
  [self.visitedVertices removeLastObject];
  [self.directionHistory removeLastObject];
  
  SKTexture *unvisitedHouse = [SKTexture textureWithImageNamed:[self houseWithAppendix:@"house-u"]];
  SKTexture *currentHouse = [SKTexture textureWithImageNamed:[self houseWithAppendix:@"house-c"]];
  [self changeTextureOfVertex:lastVertexName toTexture:unvisitedHouse];
  [self changeTextureOfVertex:newVertexName toTexture:currentHouse];
}

- (void)repositionVertices {
  if ([self nathanIsMoving]) {
    [self emitFlashWithMessage:@"thief must not move"];
    [self playErrorSound];
    return;
  }
  [self playButtonSound];
  
  self.startTime -= REDRAW_PENALTY;
  [self emitFlashWithMessage:[NSString stringWithFormat:@"-%d", (int)REDRAW_PENALTY]];
  
  SKNode *edge;
  while ((edge = [self.playground childNodeWithName:@"edge"]))
    [edge removeFromParent];
  [self positionVertices];
  [self drawEdges];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint touchPoint;
    if (!self.inGame) {
      touchPoint = [touch locationInNode:self.pauseBg];
      if ([self.instructionsButton containsPoint:touchPoint]) {
        [self viewInstructions];
        [self playButtonSound];
        return;
      } else if ([self.backButton containsPoint:touchPoint]) {
        [self resumeGame];
        [self playButtonSound];
        return;
      } else if ([self.quitButton containsPoint:touchPoint]) {
        [self backToIntro];
        [self playButtonSound];
        return;
      }
    
    } else {
      
//      WonScene *wonScene = [[WonScene alloc] initWithSize:self.size];
//      wonScene.nextLevel = self.level + 1;
//      [self.view presentScene:wonScene transition:[SKTransition fadeWithDuration:FADE_OUT_DURATION]];

      
      touchPoint = [touch locationInNode:self];
      if ([self.undoButton containsPoint:touchPoint]) {
        [self undoMove];

        return;
      } else if ([self.repositionButton containsPoint:touchPoint]) {
        [self repositionVertices];
        return;
      } else if ([self.pauseButton containsPoint:touchPoint]) {
        [self pauseGame];
        return;
      }
      
     
      NSString *currentVertexName = [self.visitedVertices lastObject];
      SKSpriteNode *currentVertex = [self vertexWithName:currentVertexName];
      for (NSString *vertexName in self.vertices) {
        SKSpriteNode *vertex = [self vertexWithName:vertexName];
        touchPoint = [touch locationInNode:self.playground];
        
        if ([vertex containsPoint:touchPoint] && [currentVertex containsPoint:self.nathan.position] && ![self nathanIsMoving]) {
          if ([[self.edges objectForKey:currentVertexName] containsObject:vertexName]) {
            if (![self.visitedVertices containsObject:vertexName] ||
                ([self.visitedVertices count] == [self.vertices count] && vertexName == self.visitedVertices[0])) {
              [self visitVertex:vertexName];
              break;
              
            } else {
              [self playErrorSound];
              if (vertexName == self.visitedVertices[0]) {
                [self emitFlashWithMessage:@"rob all houses first"];
              } else {
                [self emitFlashWithMessage:@"already visited"];
              }
            }
          } else {
            [self playErrorSound];
            if (currentVertex == vertex)
              [self emitFlashWithMessage:@"rob another house"];
            else
              [self emitFlashWithMessage:@"no path"];
            
          }
        } else {
        }
      }
    }
  }
}

#define SCENE_TRANSITION_DURATION 1.0

- (void)checkWin {
  if ([self.visitedVertices count] == [self.vertices count] + 1) {
    self.inGame = NO;
    [self doVolumeFade];
    WonScene *wonScene = [[WonScene alloc] initWithSize:self.size];
    wonScene.nextLevel = self.level + 1;
    CGFloat bonusFactor = [LittleThiefConfig getBonusFactor:self.level + 1];
    if (self.level > 20)
      bonusFactor = 0;
    wonScene.bonusSeconds = self.timeLeft*bonusFactor;
    NSLog(@"bonus seconds: %lu, bonus factor: %f", wonScene.bonusSeconds, bonusFactor);
    [self.view presentScene:wonScene transition:[SKTransition fadeWithDuration:SCENE_TRANSITION_DURATION]];
  }
  
}

- (void)lostGame {
  self.inGame = NO;
  LostScene *lostScene = [[LostScene alloc] initWithSize:self.size];
  lostScene.level = self.level;
  [self doVolumeFade];
  [self.view presentScene:lostScene transition:[SKTransition fadeWithDuration:SCENE_TRANSITION_DURATION]];
}

- (void)pauseGame {
  [self playButtonSound];
  self.inGame = NO;
  self.pauseBg = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"transition-screen%@", self.deviceSuffix]];
  self.pauseBg.zPosition = 5;
  self.pauseBg.position = CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild:self.pauseBg];
  
  CGFloat deviceHeight = self.size.height;
  CGFloat deviceWidth = self.size.width;
  
  self.backButton = [SKSpriteNode spriteNodeWithImageNamed:@"back-button"];
  self.backButton.anchorPoint = CGPointMake(0.0, 1.0);
  self.backButton.position = CGPointMake(-deviceWidth/2 + MARGIN, deviceHeight/2 - MARGIN);
  self.backButton.zPosition = 6;
  [self.pauseBg addChild:self.backButton];
  
  self.quitButton = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.quitButton.fontColor = [SKColor whiteColor];
  self.quitButton.fontSize = 40.0;
  self.quitButton.text = @"Quit Game";
  self.quitButton.position = CGPointMake(0, -35);
  self.quitButton.zPosition = 6;
  [self.pauseBg addChild:self.quitButton];
  
  self.instructionsButton = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.instructionsButton.fontColor = [SKColor whiteColor];
  self.instructionsButton.fontSize = 40.0;
  self.instructionsButton.text = @"Instructions";
  self.instructionsButton.position = CGPointMake(0, 35);
  self.instructionsButton.zPosition = 6;
  [self.pauseBg addChild:self.instructionsButton];
  NSString *hs = [[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"];
  if (hs) {
    SKLabelNode *highScore = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
    highScore.fontColor = [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
    highScore.fontSize = 30.0;
    highScore.text = [NSString stringWithFormat:@"High score: lvl %@", hs];
    highScore.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    highScore.position = CGPointMake(0, self.pauseBg.size.height/2 - MARGIN -10);
    highScore.zPosition = 6;
    [self.pauseBg addChild:highScore];
  }

  

}

- (void)resumeGame {
  [self.pauseBg runAction:[SKAction fadeOutWithDuration:0.3] completion:^{
    [self.pauseBg removeAllChildren];
    [self.pauseBg removeFromParent];
    self.inGame = YES;
  }];
}




- (void)viewInstructions {
  InstructionsScene *scene = [[InstructionsScene alloc] initWithSize:self.size];
  scene.level = 0;
  SKStackView *view = (SKStackView *)self.view;
  [view pushScene:self];
  self.inInstructions = YES;
  [view presentScene:scene transition:[SKTransition fadeWithDuration:0.5]];
}

- (NSInteger)getGameDuration {
  if (self.level <= 20) {
    return ceil(self.level/5.0) * GAME_DURATION * DURATION_INCREASE_FACTOR;
  } else {
    return 175 - ((self.level - 21) * 10);
  }
}


- (void)update:(CFTimeInterval)currentTime {
  if (!self.startTime) {
    self.startTime = currentTime;
    if (self.bonusSeconds)
      self.startTime += self.bonusSeconds;
  }

  if (self.inGame) {
    
    int countDownInt = (int)(currentTime - self.startTime);
    if (countDownInt < self.gameDuration) {
      self.timeLeft = self.gameDuration - countDownInt;
      if (self.timeLeft <= 10 && self.clockPlayer.isPlaying == NO) {
        [self.clockPlayer play];
        self.timerLabel.fontColor = [LittleThiefConfig red];
      }
      self.timerLabel.text = [NSString stringWithFormat:@"%ld", (long)self.timeLeft];
      self.bonusSeconds = self.timeLeft;
    } else {
      [self lostGame];
    }
  } else {
    self.startTime = currentTime - self.gameDuration + self.timeLeft;
  }
}

#pragma mark Helpers

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
  float diff = bigNumber - smallNumber;
  return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (SKSpriteNode *)vertexWithName:(NSString *)vertexName {
  return (SKSpriteNode *)[self.playground childNodeWithName:vertexName];
}

- (void)changeTextureOfVertex:(NSString *)vertexName toTexture:(SKTexture *)texture {
  if (![vertexName isEqualToString:[self.visitedVertices firstObject]]) {
    NSLog(@"changing texture of %@", vertexName);
    SKSpriteNode *vertex = [self vertexWithName:vertexName];
    [vertex setTexture:texture];
  }
}

- (bool)nathanIsMoving {
  return self.nathan.alpha > 0;
}


- (NSArray *)getTexturesFromDirection:(CGPoint)offset {
  if (offset.x >= 0 && offset.y >= 0) {
    if (offset.x > offset.y) {
      self.direction = 2;
      return @[[self.runningNathanAtlas textureNamed:@"right1"], [self.runningNathanAtlas textureNamed:@"right2"]];
    } else {
      self.direction = 0;
      return @[[self.runningNathanAtlas textureNamed:@"up1"], [self.runningNathanAtlas textureNamed:@"up2"]];
    }
  } else if (offset.x >=0 && offset.y < 0) {
    if (offset.x > -offset.y) {
      self.direction = 2;
      return @[[self.runningNathanAtlas textureNamed:@"right1"], [self.runningNathanAtlas textureNamed:@"right2"]];
      
    } else {
      self.direction = 1;
      return @[[self.runningNathanAtlas textureNamed:@"down1"], [self.runningNathanAtlas textureNamed:@"down2"]];
    }
  } else if (offset.x < 0 && offset.y >= 0) {
    if (-offset.x > offset.y) {
      self.direction = 3;
      return @[[self.runningNathanAtlas textureNamed:@"left1"], [self.runningNathanAtlas textureNamed:@"left2"]];
    } else {
      self.direction = 0;
      return @[[self.runningNathanAtlas textureNamed:@"up1"], [self.runningNathanAtlas textureNamed:@"up2"]];
    }
  } else {
    if (-offset.x > -offset.y) {
      self.direction = 3;
      return @[[self.runningNathanAtlas textureNamed:@"left1"], [self.runningNathanAtlas textureNamed:@"left2"]];
    } else {
      self.direction = 1;
      return @[[self.runningNathanAtlas textureNamed:@"down1"], [self.runningNathanAtlas textureNamed:@"down2"]];
    }
  }
}

- (void)emitFlashWithMessage:(NSString *)message {
  [self emitFlashWithMessage:message forDuration:0.5];
}

- (void)emitFlashWithMessage:(NSString *)message forDuration:(CGFloat)duration {
  SKLabelNode *messageLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  messageLabel.fontSize = 40;
  messageLabel.zPosition = 20;
  messageLabel.fontColor = [LittleThiefConfig yellow];
  messageLabel.position = CGPointMake(self.size.width/2, self.size.height/2);
  messageLabel.text = message;
  [self addChild:messageLabel];
  [messageLabel runAction:[SKAction fadeOutWithDuration:duration]];
}

- (void)backToIntro {
  [self doVolumeFade];
  IntroScene *introScene = [[IntroScene alloc] initWithSize:self.size];
  [self.view presentScene:introScene transition:[SKTransition fadeWithDuration:SCENE_TRANSITION_DURATION]];
}

- (NSString *)houseWithAppendix:(NSString *)house {
  if (self.level < self.sizeChangeLevel)
    return house;
  else
    return [NSString stringWithFormat:@"%@%@", house, @"-small"];
}

- (void)doVolumeFade
{
  [self.runPlayer stop];
  [self.clockPlayer stop];
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

- (void)playErrorSound {
  SKAction *errorSound = [SKAction playSoundFileNamed:@"error.wav" waitForCompletion:NO];
  [self runAction:errorSound];
}



@end
