//
//  FBHelper.h
//  nathanspath
//
//  Created by Minh Tri Pham on 1/8/15.
//  Copyright (c) 2015 pmt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBHelper : UIViewController <UINavigationControllerDelegate>

- (BOOL)bragUnlocked:(NSInteger)level;
- (BOOL)bragHighScore:(NSInteger)level;
@end
