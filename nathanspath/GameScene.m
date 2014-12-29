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
#import "NathanSpriteNode.h"
#include "stdlib.h"

@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *playground;
@property (nonatomic, strong) NSMutableArray *vertices; //names of vertices
@property (nonatomic, strong) NSMutableDictionary *edges; //names of edges
@property (nonatomic, strong) NSMutableArray *visitedVertices; //names of vertices
@property (nonatomic, strong) SKSpriteNode *undoButton;
@property (nonatomic, strong) SKSpriteNode *repositionButton;
@property (nonatomic, strong) SKLabelNode *timerLabel;
@property (nonatomic, strong) NathanSpriteNode *nathan;

@property (nonatomic, strong) SKSpriteNode *pauseButton;
@property (nonatomic, strong) SKSpriteNode *pauseBg;
@property (nonatomic, strong) SKSpriteNode *backButton;
@property (nonatomic, strong) SKLabelNode *settingsButton;
@property (nonatomic, strong) SKLabelNode *instructionsButton;

@property NSInteger direction; //0 up 1 down 2 right 3 left
@property NSTimeInterval startTime;
@property NSInteger timeLeft;
@property BOOL inGame;

@property (nonatomic, strong) SKTextureAtlas *runningNathanAtlas;


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

-(void)didMoveToView:(SKView *)view {
  /* Setup your scene here */
  
  [self setBackground];
  [self addUndoButton];
  [self addRepositionButton];
  [self addPauseButton];
  [self addLevelLabel];
  [self addTimerLabel];
  
  self.playground = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(self.size.width - MARGIN*2, self.size.height - MARGIN*5 - self.undoButton.size.height)];
  self.playground.position = CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild:self.playground];
  [self addNathan];
  
  [self generateGraph:self.level + 3];
  [self positionVertices];
  [self drawEdges];
  
}
-(void)addLevelLabel {
  SKLabelNode *levelLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  levelLabel.fontSize = 42.0;
  levelLabel.text = [NSString stringWithFormat:@"level %ld", self.level];
  levelLabel.color = [SKColor whiteColor];
  levelLabel.position = CGPointMake(2.5*MARGIN, self.size.height - 2.5*MARGIN);
  [self addChild:levelLabel];
  
}

-(void)addTimerLabel {
  
  self.timerLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.timerLabel.fontSize = 42.0;
  self.timerLabel.color = [SKColor whiteColor];
  self.timerLabel.position = CGPointMake(self.size.width - 1.5*MARGIN, self.size.height - 2.5*MARGIN);
  
  [self addChild:self.timerLabel];
}

-(void)addNathan {
  self.nathan = [[NathanSpriteNode alloc] init];
  self.nathan.alpha = 0.0;
  [self.playground addChild:self.nathan];
}

-(void)addUndoButton {
  self.undoButton = [SKSpriteNode spriteNodeWithImageNamed:@"undo-button"];
  self.undoButton.anchorPoint = CGPointZero;
  self.undoButton.position = CGPointMake(MARGIN, MARGIN);
  
  [self addChild:self.undoButton];
}

-(void)addPauseButton {
  self.pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause-button"];
  self.pauseButton.anchorPoint = CGPointMake(1, 0);
  self.pauseButton.position = CGPointMake(self.size.width - MARGIN, MARGIN + 5);
  
  
  [self addChild:self.pauseButton];
}

-(void)addRepositionButton {
  self.repositionButton = [SKSpriteNode spriteNodeWithImageNamed:@"shuffle-button"];
  self.repositionButton.anchorPoint = CGPointMake(0.5, 0);
  self.repositionButton.position = CGPointMake(self.size.width/2, MARGIN);
  [self addChild:self.repositionButton];
}

-(void)setBackground {
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
    bg = [SKSpriteNode spriteNodeWithImageNamed:@"dusty-orange"];
  }
  
  bg.position = CGPointMake(self.size.width/2, self.size.height/2);
  bg.zPosition = -10.0;
  [self addChild:bg];
  
}

#pragma mark Graph Creation

#define SPREAD_FACTOR 50
#define HOUSE_SIZE 50
#define MARGIN_SIZE 30

-(CGPoint)positionForSquare:(NSInteger)square forRows:(NSInteger)rows forCols:(NSInteger)cols {
  NSInteger row = (square + cols - 1) / cols;
  CGFloat yPos = (row - 1) * (HOUSE_SIZE+MARGIN_SIZE) + HOUSE_SIZE/2 - self.playground.size.height/2;
  NSInteger col = square - (cols * (row - 1));
  
  CGFloat xPos = (col-1) * (HOUSE_SIZE+MARGIN_SIZE) + HOUSE_SIZE/2 - self.playground.size.width/2;
  return CGPointMake(xPos, yPos);
}

-(void)positionVertices {
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

-(void)generateGraph:(NSInteger)numOfVertices {
  
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
  
  NSInteger numOfNoiseEdges = numOfVertices / 2;
  
  for (int i = 0; i < numOfNoiseEdges; i++) {
    SKSpriteNode *originVertex = self.vertices[i];
    NSMutableArray *adjacent = [self.edges objectForKey:originVertex];
    
    while (1) {
      SKSpriteNode *newAdjacent = self.vertices[arc4random() % numOfVertices];
      if (![adjacent containsObject:newAdjacent]) {
        [adjacent addObject:newAdjacent];
        [[self.edges objectForKey:newAdjacent] addObject:originVertex];
        break;
      }
    }
  }
  [self.visitedVertices addObject:self.vertices[0]];
  
  
}

-(void)drawEdges {
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
#define UNDO_PENALTY 3.0
#define REDRAW_PENALTY 2.0


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
  self.startTime -= UNDO_PENALTY;
  NSString *newVertexName = [self.visitedVertices objectAtIndex:[self.visitedVertices count] - 2];
  SKSpriteNode *newVertex = [self vertexWithName:newVertexName];
  
  
  self.nathan.position = newVertex.position;
  [self.visitedVertices removeLastObject];
  
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
  self.startTime -= REDRAW_PENALTY;
  
  SKNode *edge;
  while ((edge = [self.playground childNodeWithName:@"edge"]))
    [edge removeFromParent];
  [self positionVertices];
  [self drawEdges];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint touchPoint;
    
    if (self.inGame)
      touchPoint = [touch locationInNode:self];
    else
      touchPoint = [touch locationInNode:self.pauseBg];
    
    if ([self.undoButton containsPoint:touchPoint]) {
      [self undoMove];
      return;
    } else if ([self.repositionButton containsPoint:touchPoint]) {
      [self repositionVertices];
      return;
    } else if ([self.pauseButton containsPoint:touchPoint]) {
      [self pauseGame];
      return;
    } else if ([self.backButton containsPoint:touchPoint]) {
      [self resumeGame];
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

-(void)checkWin {
  if ([self.visitedVertices count] == [self.vertices count] + 1) {
    self.inGame = NO;
    WonScene *wonScene = [[WonScene alloc] initWithSize:self.size];
    wonScene.nextLevel = self.level + 1;
    [self.view presentScene:wonScene transition:[SKTransition fadeWithDuration:1.0]];
  }
  
}
-(void)lostGame {
  self.inGame = NO;
  LostScene *lostScene = [[LostScene alloc] initWithSize:self.size];
  lostScene.level = self.level;
  [self.view presentScene:lostScene transition:[SKTransition fadeWithDuration:1.0]];
}

-(void)pauseGame {
  self.inGame = NO;
  self.pauseBg = [SKSpriteNode spriteNodeWithImageNamed:@"transition-screen"];
  self.pauseBg.zPosition = 10;
  self.pauseBg.position = CGPointMake(self.size.width/2, self.size.height/2);
  [self addChild:self.pauseBg];
  
  self.backButton = [SKSpriteNode spriteNodeWithImageNamed:@"back-button"];
  self.backButton.anchorPoint = CGPointMake(0.0, 1.0);
  self.backButton.position = CGPointMake(-self.pauseBg.size.width/2 + MARGIN, self.pauseBg.size.height/2 - MARGIN);
  [self.pauseBg addChild:self.backButton];
  
  self.instructionsButton = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.instructionsButton.fontColor = [SKColor whiteColor];
  self.instructionsButton.fontSize = 40.0;
  self.instructionsButton.text = @"Instructions";
  
  self.settingsButton = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  self.settingsButton.fontColor = [SKColor whiteColor];
  self.settingsButton.fontSize = 40.0;
  self.settingsButton.text = @"Settings";
  
  self.instructionsButton.position = CGPointMake(0, 2*MARGIN);
  self.settingsButton.position = CGPointMake(0, -2*MARGIN);
  
  [self.pauseBg addChild:self.instructionsButton];
  [self.pauseBg addChild:self.settingsButton];
  

}

-(void)resumeGame {
  [self.pauseBg runAction:[SKAction fadeOutWithDuration:0.3] completion:^{
    [self.pauseBg removeAllChildren];
    [self.pauseBg removeFromParent];
    self.inGame = YES;
  }];
}

-(void)emitFlashWithMessage:(NSString *)message {
  SKLabelNode *messageLabel = [SKLabelNode labelNodeWithFontNamed:@"SueEllenFrancisco"];
  messageLabel.fontSize = 40;
  messageLabel.fontColor = [SKColor yellowColor];
  messageLabel.position = CGPointMake(self.size.width/2, self.size.height/2);
  messageLabel.text = message;
  [self addChild:messageLabel];
  
  [messageLabel runAction:[SKAction fadeOutWithDuration:0.5]];
}



#define GAME_DURATION 41

-(void)update:(CFTimeInterval)currentTime {
  if (!self.startTime) {
    self.startTime = currentTime;
    self.inGame = YES;
  }

  
  if (self.inGame) {
    int countDownInt = (int)(currentTime - self.startTime);
    if (countDownInt < GAME_DURATION) {
      self.timeLeft = GAME_DURATION - countDownInt;
      self.timerLabel.text = [NSString stringWithFormat:@"%ld", (long)self.timeLeft];
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


-(NSArray *)getTexturesFromDirection:(CGPoint)offset {
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


@end
