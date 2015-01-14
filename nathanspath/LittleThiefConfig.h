//
//  TLTTheme.h
//  nathanspath
//
//  Created by Minh Tri Pham on 1/5/15.
//  Copyright (c) 2015 pmt. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

@interface LittleThiefConfig : NSObject

#define MARGIN 20.0
#define GAME_DURATION 35
#define DURATION_INCREASE_FACTOR 1
#define MIN_REPORT_SCORE 2
#define SHAREWORTHY_LEVEL 1

#define APP_ID @"954149664"
#define FB_NAMESPACE @"pmtlittlethief"
#define FB_IMAGE_URL @"http://zyxlabs.com/static/img/fb-nathan.png"
#define FB_APPLINK @"https://fb.me/792852697416569"



//zPositions
#define HOUSE_ZPOS 1

#define NATHAN1_HIGH_ZPOS 3
#define NATHAN2_HIGH_ZPOS 3

#define NATHAN1_LOW_ZPOS 3
#define NATHAN2_LOW_ZPOS 0

#define EDGE_HIGH_ZPOS 2
#define EDGE_LOW_ZPOS -1

#define FINGER_ZPOS 4

#define PAUSE_BG_ZPOS 8
#define PAUSE_BUTTONS_ZPOS 9
#define MESSAGE_ZPOS 20
#define BG_ZPOS -10


+ (SKColor *)yellow;
+ (SKColor *)darkBlue;
+ (SKColor *)red;

+ (NSString *)getLandnameFromLevel:(NSInteger) level;
+ (CGFloat)getBonusFactor:(CGFloat)level;
+ (NSArray *)getEpisodes;

@end
