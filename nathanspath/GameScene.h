//
//  GameScene.h
//  nathanspath
//

//  Copyright (c) 2014 pmt. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AVFoundation/AVFoundation.h"

@interface GameScene : SKScene

@property NSInteger level;
@property NSInteger bonusSeconds;
@property BOOL onlyInstructions;
@property BOOL inInstructions;


//should be in .m
@property NSString *deviceSuffix; //for instructions
@property (nonatomic, strong) SKSpriteNode *nathan;
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



@property NSTimeInterval startTime;
@property NSInteger timeLeft;
@property BOOL inGame;
@property NSInteger gameDuration;

@property NSInteger direction; //0 up 1 down 2 right 3 left nathan
@property (nonatomic, strong) NSMutableArray *directionHistory;
@property (nonatomic, strong) SKTextureAtlas *runningNathanAtlas;

@property (nonatomic, strong) AVAudioPlayer *player; //bg music
@property (nonatomic, strong) AVAudioPlayer *runPlayer;
@property (nonatomic, strong) AVAudioPlayer *clockPlayer;

//game config
@property NSInteger sizeChangeLevel; //level for size change



- (void)playButtonSound;
- (void)addUndoButton;
- (void)prepareRunningMusic;
- (void)setBackground;
- (void)addTimerLabel;
- (void)addNathan;
- (void)addPauseButton;
- (void)addRepositionButton;
- (void)mySetDeviceSuffix;
- (void)generateGraph:(NSInteger)numOfVertices;
- (void)drawEdges;
- (void)visitVertex:(NSString *)vertexName;
- (void)undoMove;
- (void)repositionVertices;
- (void)positionVertices;
- (SKSpriteNode *)vertexWithName:(NSString *)name;
- (void)emitFlashWithMessage:(NSString *)message forDuration:(CGFloat)duration;

@end
