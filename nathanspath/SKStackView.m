//
//  SKStackView.m
//  nathanspath
//
//  Created by Minh Tri Pham on 1/9/15.
//  Copyright (c) 2015 pmt. All rights reserved.
//

#import "SKStackView.h"

@interface SKStackView ()
@property (nonatomic, strong) NSMutableArray *sceneStack;
@end

@implementation SKStackView

- (NSMutableArray *)sceneStack {
  if (!_sceneStack) {
    _sceneStack = [[NSMutableArray alloc] init];
  }
  return _sceneStack;
}

- (void)pushScene:(SKScene *)scene {
  [self.sceneStack addObject:scene];
  NSLog(@"pushed a scene on stack, %lu scenes on stack", (unsigned long)[self.sceneStack count]);
}

- (void)popSceneWithTransition:(SKTransition *)transition {
  if ([self.sceneStack count] > 0) {
    [self presentScene:[self.sceneStack lastObject] transition:transition];
    [self.sceneStack removeAllObjects];
    NSLog(@"popped a scene from stack, %lu scenes on stack", (unsigned long)[self.sceneStack count]);
  } else {
    NSLog(@"not enough scenes on stack");
  }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
