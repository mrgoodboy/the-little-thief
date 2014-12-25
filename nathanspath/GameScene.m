//
//  GameScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/23/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "GameScene.h"
#import "NathanSpriteNode.h"
#include "stdlib.h"
@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *playground;
@property (nonatomic, strong) NSMutableArray *vertices;
@property (nonatomic, strong) NSMutableDictionary *edges;
@property (nonatomic, strong) NSMutableArray *visitedVertices;
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
  
  [self generateGraph:6];
  [self drawEdges];
  
  //home
  [self.visitedVertices addObject:self.vertices[0]];
  [self addNathan];
}

-(void)addNathan {
  self.nathan = [[NathanSpriteNode alloc] init];
  SKSpriteNode *home = self.vertices[0];
  self.nathan.position = home.position;
  [self.playground addChild:self.nathan];
}

#pragma mark Graph Creation

#define SPREAD_FACTOR 50

-(void)generateGraph:(NSInteger)numOfVertices {
  
  //cycle creation
  for (int i = 0; i < numOfVertices; i++) {
    SKSpriteNode *vertex = [SKSpriteNode spriteNodeWithImageNamed:@"home-icon"];
    CGFloat xPos = SPREAD_FACTOR * (self.playground.size.width / 2 / SPREAD_FACTOR -
                                    arc4random_uniform(self.playground.size.width / SPREAD_FACTOR));
    CGFloat yPos = SPREAD_FACTOR * (self.playground.size.height / 2 / SPREAD_FACTOR -
                                    arc4random_uniform(self.playground.size.height / SPREAD_FACTOR));
    vertex.position = CGPointMake(xPos, yPos);
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
      SKSpriteNode *newAdjacent = self.vertices[arc4random_uniform(numOfVertices)];
      if (![adjacent containsObject:newAdjacent]) {
        [adjacent addObject:newAdjacent];
        [[self.edges objectForKey:newAdjacent] addObject:originVertex];
        break;
      }
    }
  }
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

#define POINTS_PER_SEC = 1.0

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    CGPoint targetPoint = [touch locationInNode:self.playground];
    for (SKSpriteNode *vertex in self.vertices) {
      if ([vertex containsPoint:targetPoint]) {
        if ([[self.edges objectForKey:[self.visitedVertices lastObject]] containsObject:vertex]) {
          if (![self.visitedVertices containsObject:vertex] ||
              ([self.visitedVertices count] == [self.vertices count] && vertex == self.visitedVertices[0])) {
            SKAction *moveAction = [SKAction moveTo:targetPoint duration:1.0];
            [self.nathan runAction:moveAction];
            [self.visitedVertices addObject:vertex];
            [self checkWin];
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
  }
  
}

-(void)update:(CFTimeInterval)currentTime {
  /* Called before each frame is rendered */
}

@end
