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
#import "NathanSpriteNode.h"
#include "stdlib.h"

@interface GameScene ()

@property NSString *deviceSuffix; //for instructions
@property (nonatomic, strong) NathanSpriteNode *nathan;
@property (nonatomic, strong) SKSpriteNode *playground;
@property (nonatomic, strong) NSMutableArray *vertices; //names of vertices
@property (nonatomic, strong) NSMutableDictionary *edges; //names of edges
@property (nonatomic, strong) NSMutableArray *visitedVertices; //names of vertices
@property (nonatomic, strong) SKSpriteNode *undoButton;
@property (nonatomic, strong) SKSpriteNode *repositionButton;
@property (nonatomic, strong) SKLabelNode *timerLabel;
@property (nonatomic, strong) SKSpriteNode *pauseButton;

@property (nonatomic, strong) SKSpriteNode *pauseBg;
@property (nonatomic, strong) SKSpriteNode *backButton;
@property (nonatomic, strong) SKLabelNode *quitButton;
@property (nonatomic, strong) SKLabelNode *instructionsButton;
@property (nonatomic, strong) SKSpriteNode *instructionsBg;
@property NSInteger instructionNumber;

@property NSTimeInterval startTime;
@property NSInteger timeLeft;
@property BOOL inGame;

@property NSInteger direction; //0 up 1 down 2 right 3 left nathan
@property (nonatomic, strong) NSMutableArray *directionHistory;
@property (nonatomic, strong) SKTextureAtlas *runningNathanAtlas;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightGestureRecognizer;

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

#define MARGIN 20.0

- (void)didMoveToView:(SKView *)view {
  if (self.onlyInstructions) {
    self.inGame = NO;
    [self viewInstructions];
    return;
  }
  
  [self setBackground];
  [self addUndoButton];
  [self addRepositionButton];
  [self addPauseButton];
  [self addLevelLabel];
  [self addTimerLabel];
  
  self.playground = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(self.size.width - MARGIN*2, self.size.height - MARGIN*5 - self.undoButton.size.height)];
  self.playground.position = CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild:self.playground];
  [self addNathan];
  
  NSInteger numOfVertices = (NSInteger)ceil(self.level/2.0) + 3;
  [self generateGraph:numOfVertices];
  [self positionVertices];
  [self drawEdges];
  
  self.instructionNumber = 0;
  self.inGame = YES;
}
- (void)addLevelLabel {
  SKLabelNode *levelLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  levelLabel.fontSize = 42.0;
  levelLabel.text = [NSString stringWithFormat:@"level %ld", (long)self.level];
  levelLabel.color = [SKColor whiteColor];
  levelLabel.position = CGPointMake(2.5*MARGIN, self.size.height - 2.5*MARGIN);
  [self addChild:levelLabel];
  
}

- (void)addTimerLabel {
  
  self.timerLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.timerLabel.fontSize = 42.0;
  self.timerLabel.color = [SKColor whiteColor];
  self.timerLabel.position = CGPointMake(self.size.width - 1.5*MARGIN, self.size.height - 2.5*MARGIN);
  
  [self addChild:self.timerLabel];
}

- (void)addNathan {
  self.nathan = [[NathanSpriteNode alloc] init];
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
  if (self.level < 3) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-blue"];
  } else if (self.level < 5) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-green"];
  } else if (self.level < 7) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-yellow"];
  } else if (self.level < 9) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-grey"];
  } else if (self.level < 11) {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-orange"];
  } else {
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-red"];
  }
  
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -10.0;
  [self addChild:bg];
  
}

#pragma mark Graph Creation

#define SPREAD_FACTOR 50
#define HOUSE_SIZE 50
#define MARGIN_SIZE 30

- (CGPoint)positionForSquare:(NSInteger)square forRows:(NSInteger)rows forCols:(NSInteger)cols {
  NSInteger row = (square + cols - 1) / cols;
  CGFloat yPos = (row - 1) * (HOUSE_SIZE+MARGIN_SIZE) + HOUSE_SIZE/2 - self.playground.size.height/2;
  NSInteger col = square - (cols * (row - 1));
  
  CGFloat xPos = (col-1) * (HOUSE_SIZE+MARGIN_SIZE) + HOUSE_SIZE/2 - self.playground.size.width/2;
  return CGPointMake(xPos, yPos);
}

- (void)positionVertices {
  //grid generation
  NSInteger cols = self.playground.size.width/(HOUSE_SIZE+MARGIN_SIZE);
  NSInteger rows = self.playground.size.height/(HOUSE_SIZE+MARGIN_SIZE);
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
    CGPoint noise = CGPointMake([self randomFloatBetween:-MARGIN_SIZE/2 and:MARGIN_SIZE/2],
                                [self randomFloatBetween:-MARGIN_SIZE/2 and:MARGIN_SIZE/2]);
    position.x += noise.x;
    position.y += noise.y;
    
    //adjust to best use space
    CGFloat leftVerticalSpace = self.playground.size.height - rows * HOUSE_SIZE - (rows-1) * MARGIN_SIZE;
    position.y += leftVerticalSpace/2;
    
    CGFloat leftHorizontalSpace = self.playground.size.width - cols * HOUSE_SIZE - (cols-1) * MARGIN_SIZE;
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
      SKTexture *houseTexture = [SKTexture textureWithImageNamed:@"house-h"];
      vertex = [SKSpriteNode spriteNodeWithTexture:houseTexture];
    } else {
      SKTexture *houseTexture = [SKTexture textureWithImageNamed:@"house-u"];
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
    //    CGPoint originPoint = [self convertPoint:vertex.position fromNode:self.playground];
    CGPoint originPoint = vertex.position;
    for (NSString *adjacentName in [self.edges objectForKey:vertexName]) {
      if ([added objectForKey:adjacentName] && [[added objectForKey:adjacentName] containsObject:vertexName])
        continue;
      SKSpriteNode *adjacent = [self vertexWithName:adjacentName];
      //      CGPoint destinationPoint = [self convertPoint:adjacent.position fromNode:self.playground];
      CGPoint destinationPoint = adjacent.position;
      SKShapeNode *edge = [SKShapeNode node];
      edge.name = @"edge";
      CGMutablePathRef pathToDraw = CGPathCreateMutable();
      CGPathMoveToPoint(pathToDraw, NULL, originPoint.x, originPoint.y);
      CGPathAddLineToPoint(pathToDraw, NULL, destinationPoint.x, destinationPoint.y);
      edge.path = pathToDraw;
      edge.zPosition = -9;
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
//#define REDRAW_PENALTY 1.0


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
  SKTexture *visitedHouse = [SKTexture textureWithImageNamed:@"house-v"];
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
  
  [self.nathan runAction:runAction withKey:@"runAction"];
  SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:FADE_IN_DURATION];
  SKAction *moveAction = [SKAction moveTo:targetPoint duration:duration];
  SKAction *leaveGroup = [SKAction group:@[fadeIn, moveAction]];
  SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:FADE_OUT_DURATION];
  SKAction *sequence = [SKAction sequence :@[leaveGroup, fadeOut]];
  [self.nathan runAction:sequence completion:^{
    [self checkWin];
    SKTexture *currentHouse = [SKTexture textureWithImageNamed:@"house-c"];
    [self changeTextureOfVertex:vertexName toTexture:currentHouse];
    self.nathan.zPosition = 0;
  }];
}

- (void)undoMove {
  NSString *lastVertexName = [self.visitedVertices lastObject];
  if (lastVertexName == [self.visitedVertices firstObject]) {
    [self emitFlashWithMessage:@"no moves to undo"];
    return;
  }
  if ([self nathanIsMoving]) {
    [self emitFlashWithMessage:@"thief must not move"];
    return;
  }
  
  
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
    [self emitFlashWithMessage:[NSString stringWithFormat:@"-%d", (int)UNDO_PENALTY]];

    self.nathan.position = newVertex.position;
  }];
  
  [self.visitedVertices removeLastObject];
  [self.directionHistory removeLastObject];
  
  SKTexture *unvisitedHouse = [SKTexture textureWithImageNamed:@"house-u"];
  SKTexture *currentHouse = [SKTexture textureWithImageNamed:@"house-c"];
  [self changeTextureOfVertex:lastVertexName toTexture:unvisitedHouse];
  [self changeTextureOfVertex:newVertexName toTexture:currentHouse];
}

- (void)repositionVertices {
  if ([self nathanIsMoving]) {
    [self emitFlashWithMessage:@"thief must not move"];
    return;
  }
  
//  self.startTime -= REDRAW_PENALTY;
//  [self emitFlashWithMessage:[NSString stringWithFormat:@"-%d", (int)REDRAW_PENALTY]];
  
  SKNode *edge;
  while ((edge = [self.playground childNodeWithName:@"edge"]))
    [edge removeFromParent];
  [self positionVertices];
  [self drawEdges];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    if (self.instructionNumber > 0) {
      return;
    }
    
    CGPoint touchPoint;
    if (!self.inGame) {
      touchPoint = [touch locationInNode:self.pauseBg];
      if ([self.instructionsButton containsPoint:touchPoint]) {
        [self viewInstructions];
        return;
      } else if ([self.backButton containsPoint:touchPoint]) {
        [self resumeGame];
        return;
      } else if ([self.quitButton containsPoint:touchPoint]) {
        [self backToIntro];
        return;
      }
    
    } else {
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
              if (vertexName == self.visitedVertices[0])
                [self emitFlashWithMessage:@"rob all houses first"];
              else
                [self emitFlashWithMessage:@"already visited"];
            }
          } else {
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
#define BONUS_FACTOR 0.75

- (void)checkWin {
  if ([self.visitedVertices count] == [self.vertices count] + 1) {
    self.inGame = NO;
    WonScene *wonScene = [[WonScene alloc] initWithSize:self.size];
    wonScene.nextLevel = self.level + 1;
    wonScene.bonusSeconds = self.timeLeft*BONUS_FACTOR;
    [self.view presentScene:wonScene transition:[SKTransition fadeWithDuration:SCENE_TRANSITION_DURATION]];
  }
  
}

- (void)lostGame {
  self.inGame = NO;
  LostScene *lostScene = [[LostScene alloc] initWithSize:self.size];
  lostScene.level = self.level;
  [self.view presentScene:lostScene transition:[SKTransition fadeWithDuration:SCENE_TRANSITION_DURATION]];
}

- (void)pauseGame {
  self.inGame = NO;
  self.pauseBg = [SKSpriteNode spriteNodeWithImageNamed:@"transition-screen"];
  self.pauseBg.zPosition = 10;
  self.pauseBg.position = CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild:self.pauseBg];
  
  CGFloat deviceHeight = self.size.height;
  CGFloat deviceWidth = self.size.width;
  
  self.backButton = [SKSpriteNode spriteNodeWithImageNamed:@"back-button"];
  self.backButton.anchorPoint = CGPointMake(0.0, 1.0);
  self.backButton.position = CGPointMake(-deviceWidth/2 + MARGIN, deviceHeight/2 - MARGIN);
  [self.pauseBg addChild:self.backButton];
  
  self.quitButton = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.quitButton.fontColor = [SKColor whiteColor];
  self.quitButton.fontSize = 40.0;
  self.quitButton.text = @"Quit Game";
  self.quitButton.position = CGPointMake(0, -35);  [self.pauseBg addChild:self.quitButton];
  
  self.instructionsButton = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.instructionsButton.fontColor = [SKColor whiteColor];
  self.instructionsButton.fontSize = 40.0;
  self.instructionsButton.text = @"Instructions";
  self.instructionsButton.position = CGPointMake(0, 35);
  
  [self.pauseBg addChild:self.instructionsButton];
  

}

- (void)resumeGame {
  [self.pauseBg runAction:[SKAction fadeOutWithDuration:0.3] completion:^{
    [self.pauseBg removeAllChildren];
    [self.pauseBg removeFromParent];
    self.inGame = YES;
  }];
}


- (void)viewInstructions {
  self.instructionNumber = 1;

  CGFloat deviceHeight = self.size.height;
  if (deviceHeight <= 480) {
    self.deviceSuffix = @"-4";
  } else if (deviceHeight <= 568) {
    self.deviceSuffix = @"-5";
  } else if (deviceHeight <= 667) {
    self.deviceSuffix = @"-6";
  } else {
    self.deviceSuffix = @"";
  }
  
  NSString *imgName = [NSString stringWithFormat:@"%ld%@", (long)self.instructionNumber, self.deviceSuffix];
  SKTexture *texture = [SKTexture textureWithImageNamed:imgName];
  self.instructionsBg = [SKSpriteNode spriteNodeWithTexture:texture];
  self.instructionsBg.position = CGPointMake(self.size.width/2, self.size.height/2);
  self.instructionsBg.zPosition = 15;
  [self addChild:self.instructionsBg];
  
  self.swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightInstruction:)];
  self.swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
  [self.view addGestureRecognizer:self.swipeRightGestureRecognizer];
  
  self.swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftInstruction:)];
  self.swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.view addGestureRecognizer:self.swipeLeftGestureRecognizer];
  
  [self showInstructionsLabel];
}

- (void)swipeRightInstruction:(UISwipeGestureRecognizer *)sender
{

  self.instructionNumber--;
  if (self.instructionNumber <= 0) {
    [self.view removeGestureRecognizer:self.swipeRightGestureRecognizer];
    [self.view removeGestureRecognizer:self.swipeLeftGestureRecognizer];
    
    SKLabelNode *swipeInstruction = (SKLabelNode *)[self childNodeWithName:@"swipe instruction"];
    if (swipeInstruction)
      [swipeInstruction removeFromParent];
    
    if (self.onlyInstructions) {
      [self backToIntro];
      return;
    }
    [self.instructionsBg removeFromParent];

    return;
  }
  NSString *imgName = [NSString stringWithFormat:@"%ld%@", (long)self.instructionNumber, self.deviceSuffix];
  SKTexture *texture = [SKTexture textureWithImageNamed:imgName];
  self.instructionsBg.texture = texture;
}

- (void)swipeLeftInstruction:(UISwipeGestureRecognizer *)sender
{
  
  self.instructionNumber++;
  if (self.instructionNumber >= 13) {
    [self.view removeGestureRecognizer:self.swipeLeftGestureRecognizer];
    [self.view removeGestureRecognizer:self.swipeRightGestureRecognizer];
    
    if (self.onlyInstructions) {
      [self backToIntro];
      return;
    }
    self.instructionNumber = 0;
    [self.instructionsBg removeFromParent];
    return;
  }
  NSString *imgName = [NSString stringWithFormat:@"%ld%@", (long)self.instructionNumber, self.deviceSuffix];
  SKTexture *texture = [SKTexture textureWithImageNamed:imgName];
  self.instructionsBg.texture = texture;
  
}

#define GAME_DURATION 41

- (void)update:(CFTimeInterval)currentTime {
  if (!self.startTime) {
    self.startTime = currentTime;
    if (self.bonusSeconds)
      self.startTime += self.bonusSeconds;
  }

  
  if (self.inGame) {
    int countDownInt = (int)(currentTime - self.startTime);
    if (countDownInt < GAME_DURATION) {
      self.timeLeft = GAME_DURATION - countDownInt;
      self.timerLabel.text = [NSString stringWithFormat:@"%ld", (long)self.timeLeft];
      self.bonusSeconds = self.timeLeft;
    } else {
      [self lostGame];
    }
  } else {
    self.startTime = currentTime - GAME_DURATION + self.timeLeft;
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
  if (vertexName != [self.visitedVertices firstObject]) {
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
  messageLabel.fontColor = [SKColor yellowColor];
  messageLabel.position = CGPointMake(self.size.width/2, self.size.height/2);
  messageLabel.text = message;
  [self addChild:messageLabel];
  [messageLabel runAction:[SKAction fadeOutWithDuration:duration]];
}

- (void)showInstructionsLabel {
  SKLabelNode *messageLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  messageLabel.name = @"swipe instruction";
  messageLabel.fontSize = 50;
  messageLabel.zPosition = 20;
  messageLabel.fontColor = [SKColor whiteColor];
  messageLabel.position = CGPointMake(self.size.width/2, self.size.height/5);
  messageLabel.text = @"Instructions";
  messageLabel.alpha = 0;
  
  [self addChild:messageLabel];
  SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
  SKAction *wait = [SKAction waitForDuration:2];
  SKAction *fadeOut = [SKAction fadeOutWithDuration:0.2];
  SKAction *sequence = [SKAction sequence:@[fadeIn, wait, fadeOut]];
  [messageLabel runAction:sequence completion:^{
    messageLabel.text = @"Swipe to navigate";
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
    SKAction *wait = [SKAction waitForDuration:4];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.2];
    SKAction *sequence = [SKAction sequence:@[fadeIn, wait, fadeOut]];
    [messageLabel runAction:sequence];
  }];
}

- (void)backToIntro {
  IntroScene *introScene = [[IntroScene alloc] initWithSize:self.size];
  [self.view presentScene:introScene transition:[SKTransition fadeWithDuration:SCENE_TRANSITION_DURATION]];
}

@end
