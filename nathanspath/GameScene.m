//
//  GameScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/23/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "GameScene.h"
#import "WonScene.h"
#import "NathanSpriteNode.h"
#include "stdlib.h"
@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *playground;
@property (nonatomic, strong) NSMutableArray *vertices;
@property (nonatomic, strong) NSMutableDictionary *edges;
@property (nonatomic, strong) NSMutableArray *visitedVertices;
@property (nonatomic, strong) SKSpriteNode *backButton;
@property (nonatomic, strong) NathanSpriteNode *nathan;

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

#pragma mark Setup

-(void)didMoveToView:(SKView *)view {
  /* Setup your scene here */
  self.backgroundColor = [SKColor lightGrayColor];
  self.playground = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(self.size.width - 50, self.size.height - 80)];
  self.playground.position = CGPointMake(self.size.width/2, self.size.height/2 + 20);
  [self addChild:self.playground];
  
  [self generateGraph:self.level];
  [self drawEdges];
  
  [self addNathan];
  [self addBackButton];
  
}

-(void)addNathan {
  self.nathan = [[NathanSpriteNode alloc] init];
  SKSpriteNode *home = self.vertices[0];
  self.nathan.position = home.position;
  [self.playground addChild:self.nathan];
}

-(void)addBackButton {
  self.backButton = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(self.size.width/2, 30.0)];
  self.backButton.position = CGPointMake(self.size.width/2, 20.0);
  [self addChild:self.backButton];
  
  
}

#pragma mark Graph Creation

#define SPREAD_FACTOR 50
#define HOUSE_SIZE 50
#define MARGIN_SIZE 20

-(CGPoint)positionForSquare:(NSInteger)square forRows:(NSInteger)rows forCols:(NSInteger)cols {
  NSInteger row = (square + cols - 1) / cols;
  CGFloat yPos = (row - 1) * (HOUSE_SIZE+MARGIN_SIZE) + HOUSE_SIZE/2 - self.playground.size.height/2;
  NSInteger col = square - (cols * (row - 1));

  CGFloat xPos = (col-1) * (HOUSE_SIZE+MARGIN_SIZE) + HOUSE_SIZE/2 - self.playground.size.width/2;
  return CGPointMake(xPos, yPos);
}

-(void)generateGraph:(NSInteger)numOfVertices {
  
  //grid generation
  NSInteger cols = self.playground.size.width/(HOUSE_SIZE+MARGIN_SIZE);
  NSInteger rows = self.playground.size.height/(HOUSE_SIZE+MARGIN_SIZE);
  NSInteger squares = cols * rows;
  NSMutableArray *takenSquares= [[NSMutableArray alloc] initWithCapacity:squares];
  for (int i = 0; i < squares; i++) {
    takenSquares[i] = [NSNumber numberWithBool:NO];
  }
  
  
  //cycle creation
  for (int i = 0; i < numOfVertices; i++) {
    SKSpriteNode *vertex = [SKSpriteNode spriteNodeWithImageNamed:@"home-icon"];
    
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
    
    vertex.position = position;
    [self.playground addChild:vertex];
    [self.vertices addObject:vertex];
    
    if (i > 0) {
      SKSpriteNode *previousVertex = self.vertices[i - 1];
      [self.edges setObject:[NSMutableArray arrayWithArray:@[previousVertex]] forKey:vertex];
      [[self.edges objectForKey:previousVertex] addObject:vertex];
      
    } else {
      [self.edges setObject:[[NSMutableArray alloc] init] forKey:vertex];
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
  
  for (SKSpriteNode *vertex in self.edges) {
    //    CGPoint originPoint = [self convertPoint:vertex.position fromNode:self.playground];
    CGPoint originPoint = vertex.position;
    for (SKSpriteNode *adjacent in [self.edges objectForKey:vertex]) {
      //      CGPoint destinationPoint = [self convertPoint:adjacent.position fromNode:self.playground];
      CGPoint destinationPoint = adjacent.position;
      SKShapeNode *edge = [SKShapeNode node];
      CGMutablePathRef pathToDraw = CGPathCreateMutable();
      CGPathMoveToPoint(pathToDraw, NULL, originPoint.x, originPoint.y);
      
      CGPathAddLineToPoint(pathToDraw, NULL, destinationPoint.x, destinationPoint.y);
      edge.path = pathToDraw;
      [edge setStrokeColor:[SKColor blackColor]];
      [self.playground addChild:edge];
    }
  }
}


#pragma mark Interaction

#define POINTS_PER_SEC 150.0


- (void)visitVertex:(SKSpriteNode *)vertex {
  SKSpriteNode *currentVertex = [self.visitedVertices lastObject];
  CGPoint targetPoint = vertex.position;
  CGPoint currentPosition = currentVertex.position;
  CGPoint offset = CGPointMake(targetPoint.x - currentPosition.x, targetPoint.y - currentPosition.y);
  CGFloat length = sqrtf(offset.x * offset.x + offset.y * offset.y);
  CGFloat duration = length / POINTS_PER_SEC;
  [self.visitedVertices addObject:vertex];
  
  
  SKAction *moveAction = [SKAction moveTo:targetPoint duration:duration];
  [self.nathan runAction:moveAction completion:^{
    [self checkWin];
  }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint touchPoint = [touch locationInNode:self];
    
    if ([self.backButton containsPoint:touchPoint]) {
      if ([self.visitedVertices count] > 1) {
        SKSpriteNode *lastVertex = [self.visitedVertices objectAtIndex:[self.visitedVertices count] - 2];
        self.nathan.position = lastVertex.position;
        [self.visitedVertices removeLastObject];
        return;
      }
    }
    SKSpriteNode *currentVertex = [self.visitedVertices lastObject];
    for (SKSpriteNode *vertex in self.vertices) {
      touchPoint = [touch locationInNode:self.playground];
      if ([vertex containsPoint:touchPoint] && [currentVertex containsPoint:self.nathan.position]) {
        if ([[self.edges objectForKey:currentVertex] containsObject:vertex]) {
          if (![self.visitedVertices containsObject:vertex] ||
              ([self.visitedVertices count] == [self.vertices count] && vertex == self.visitedVertices[0])) {
            
            [self visitVertex:vertex];
            break;
            
          }
        }
      }
    }
  }
}

-(void)checkWin {
  if ([self.visitedVertices count] == [self.vertices count] + 1) {
    NSLog(@"won");
    
    WonScene *wonScene = [[WonScene alloc] initWithSize:self.size];
    wonScene.nextLevel = self.level + 1;
    [self.view presentScene:wonScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
  }
  
}

-(void)update:(CFTimeInterval)currentTime {
  /* Called before each frame is rendered */
}

@end
