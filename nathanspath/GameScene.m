//
//  GameScene.m
//  nathanspath
//
//  Created by Minh Tri Pham on 12/23/14.
//  Copyright (c) 2014 pmt. All rights reserved.
//

#import "GameScene.h"
#include "stdlib.h"
@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *playground;
@property (nonatomic, strong) NSMutableArray *vertices;
@property (nonatomic, strong) NSMutableDictionary *edges;

@end
@implementation GameScene

#pragma mark Lazy Instantiation

-(NSMutableArray *)vertices {
  if (!_vertices) {
    _vertices = [[NSMutableArray alloc] init];
  }
  return _vertices;
}

-(NSMutableDictionary *)edges {
  if (!_edges) {
    _edges = [[NSMutableDictionary alloc] init];
  }
  return _edges;
}

-(void)didMoveToView:(SKView *)view {
  /* Setup your scene here */
  self.backgroundColor = [SKColor lightGrayColor];
  self.playground = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(self.size.width - 50, self.size.height - 80)];
  self.playground.position = CGPointMake(self.size.width/2, self.size.height/2 + 30);
  [self addChild:self.playground];
  
  [self generateGraph:10];
  NSLog(@"%@", [self.edges objectForKey:self.vertices[0]])
;
  
}

#define SPREAD_FACTOR 30

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
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  /* Called when a touch begins */
  
  }

-(void)update:(CFTimeInterval)currentTime {
  /* Called before each frame is rendered */
}

@end
