//
//  FBHelper.m
//  nathanspath
//
//  Created by Minh Tri Pham on 1/8/15.
//  Copyright (c) 2015 pmt. All rights reserved.
//

#import "FBHelper.h"
#import "LittleThiefConfig.h"

@implementation FBHelper

- (BOOL)bragUnlocked:(NSInteger)level {
  
  NSString *landUnlocked = [LittleThiefConfig getLandnameFromLevel:level];
  NSString *description = [NSString stringWithFormat:@"Help the little thief rob houses, too!"];
  id<FBGraphObject> object =
  [FBGraphObject openGraphObjectForPostWithType:[NSString stringWithFormat:@"%@:land", FB_NAMESPACE]
                                          title:landUnlocked
                                          image:FB_IMAGE_URL
                                            url:FB_APPLINK
                                    description:description];
  
  NSLog(@"%@", object);
  
  id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
  
  // Link the object to the action
  [action setObject:object forKey:@"land"];
  // Check if the Facebook app is installed and we can present the share dialog
  FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
  params.action = action;
  params.actionType = [NSString stringWithFormat:@"%@:unlock", FB_NAMESPACE];
  
  // If the Facebook app is installed and we can present the share dialog
  if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
    // Show the share dialog
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:[NSString stringWithFormat:@"%@:unlock", FB_NAMESPACE]
                                 previewPropertyName:@"land"
                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                               if(error) {
                                                 // There was an error
                                                 NSLog([NSString stringWithFormat:@"Error publishing story: %@", [error localizedDescription]]);
                                               } else {
                                                 // Success
                                                 NSLog(@"result %@", results);
                                               }
                                             }];
    
    // If the Facebook app is NOT installed and we can't present the share dialog
  } else {
    // FALLBACK: publish just a link using the Feed dialog
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"I just unlocked %@ on The Little Thief", landUnlocked], @"name",
                                   @"", @"caption",
                                   description, @"description",
                                   FB_APPLINK, @"link",
                                   FB_IMAGE_URL, @"picture",
                                   nil];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                if (error) {
                                                  // Error launching the dialog or publishing a story.
                                                  NSLog([NSString stringWithFormat:@"Error publishing story: %@", [error localizedDescription]]);
                                                } else {
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    // User cancelled.
                                                    NSLog(@"User cancelled.");
                                                  } else {
                                                    // Handle the publish feed callback
                                                    
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      // User canceled.
                                                      NSLog(@"User cancelled.");
                                                      
                                                    } else {
                                                      // User clicked the Share button
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                    }
                                                  }
                                                }
                                              }];
    
  }
  return YES;
}

- (BOOL)bragHighScore:(NSInteger)level {
  NSString *title = [NSString stringWithFormat:@"I just robbed %lu houses with the little thief", level];
  NSString *description = @"Help the little thief rob houses, too!";
  id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
  
  id<FBGraphObject> object =
  [FBGraphObject openGraphObjectForPostWithType:[NSString stringWithFormat:@"%@:new_high_score", FB_NAMESPACE]
                                          title:title
                                          image:FB_IMAGE_URL
                                            url:FB_APPLINK
                                    description:description];
  NSLog(@"%@", object);
  
  
  // Link the object to the action
  [action setObject:object forKey:@"new_high_score"];
  // Check if the Facebook app is installed and we can present the share dialog
  FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
  params.action = action;
  params.actionType = [NSString stringWithFormat:@"%@:set", FB_NAMESPACE];
  
  // If the Facebook app is installed and we can present the share dialog
  if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
    // Show the share dialog
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:[NSString stringWithFormat:@"%@:set", FB_NAMESPACE]
                                 previewPropertyName:@"new_high_score"
                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                               if(error) {
                                                 // There was an error
                                                 NSLog([NSString stringWithFormat:@"Error publishing story: %@", [error localizedDescription]]);
                                               } else {
                                                 // Success
                                                 NSLog(@"result %@", results);
                                               }
                                             }];
    
    // If the Facebook app is NOT installed and we can't present the share dialog
  } else {
    // FALLBACK: publish just a link using the Feed dialog
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   title, @"name",
                                   @"", @"caption",
                                   description, @"description",
                                   FB_APPLINK, @"link",
                                   FB_IMAGE_URL, @"picture",
                                   nil];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                if (error) {
                                                  // Error launching the dialog or publishing a story.
                                                  NSLog([NSString stringWithFormat:@"Error publishing story: %@", [error localizedDescription]]);
                                                } else {
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    // User cancelled.
                                                    NSLog(@"User cancelled.");
                                                  } else {
                                                    // Handle the publish feed callback
                                                    
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      // User canceled.
                                                      NSLog(@"User cancelled.");
                                                      
                                                    } else {
                                                      // User clicked the Share button
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                    }
                                                  }
                                                }
                                              }];
    
  }
  return YES;
}

- (NSDictionary*)parseURLParams:(NSString *)query {
  NSArray *pairs = [query componentsSeparatedByString:@"&"];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  for (NSString *pair in pairs) {
    NSArray *kv = [pair componentsSeparatedByString:@"="];
    NSString *val =
    [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    params[kv[0]] = val;
  }
  return params;
}

@end
