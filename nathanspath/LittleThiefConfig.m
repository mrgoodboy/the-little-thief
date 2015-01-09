//
//  TLTTheme.m
//  nathanspath
//
//  Created by Minh Tri Pham on 1/5/15.
//  Copyright (c) 2015 pmt. All rights reserved.
//

#import "LittleThiefConfig.h"

@implementation LittleThiefConfig

+ (SKColor *)yellow {
  return [SKColor colorWithRed:255.0/255.0 green:241.0/255.0 blue:1.0/255.0 alpha:1.0];
}

+ (SKColor *)darkBlue {
  return [SKColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:127.0/255.0 alpha:0.95];
  
}

+ (SKColor *)red {
  return [SKColor colorWithRed:216.0/255.0 green:35.0/255.0 blue:41.0/255.0 alpha:0.95];
}

+ (NSArray *)getEpisodes {
  return @[@"Blueland", @"Purpleland", @"Yellowland", @"Greyland", @"Orangeland", @"Redland", @"Blackland"];
}

+ (NSString *)getLandnameFromLevel:(NSInteger) level {
  NSInteger town = ceil((level-1)/5.0);
  return [[LittleThiefConfig getEpisodes] objectAtIndex:town];
}

+ (CGFloat)getBonusFactor:(CGFloat)level {
  if (level >= 21) {
    return 0;
  } else {
    NSInteger town = ceil(level/5.0);
    return town/10.0 + 0.2;
  }
}

@end
