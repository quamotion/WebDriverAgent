/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBActionCommands.h"

#import "FBRoute.h"
#import "FBRouteRequest.h"

@implementation FBActionCommands

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute POST:@"/actions"] respondWithTarget:self action:@selector(handlePerformActionsCommand:)],
    ];
}

#pragma mark - Commands

+ (id<FBResponsePayload>)handlePerformActionsCommand:(FBRouteRequest *)request
{
  // The remote end steps as defined in 17.5.2 - Remote End Steps
  // 1. Extract an action sequence
  //    As defined in 17.3 - Extracting an action sequence from a request
  NSArray* actions = request.arguments[@"actions"];
  
  // 2. If actions is undefined or is not an array, return error code with
  //    invalid argument.
  if(actions == nil || ![actions isKindOfClass:[NSArray class]]) {
    return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"The argument to /actions must have an actions property, which must be an array");
  }
  
  // 3. Let actions by tick be an empty list
  NSMutableArray* actionsByTick = [[NSMutableArray alloc] init];
  NSDictionary *inputSources = [[NSMutableDictionary alloc] init];
  
  // 4. For each value action sequence corresponding to an indexed property
  //    in actions:
  for(NSDictionary* actionSequence in actions) {
    // 1. Let input source actions be the result of trying t process an
    //    input source action sequence with argument action sequence
    
    // == Process an input source action sequence ==
    // 1. Let type be the result of getting a property named type from
    //    action sequence
    NSString* type = actionSequence[@"type"];
    
    // 2. If type is not key, pointer or none, return an error with error
    //    code invalid argument.
    if (![type  isEqual: @"key"]
        && ![type  isEqual: @"pointer"]
        && ![type  isEqual: @"none"]) {
      return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"Each action sequence must have a type of key, pointer or none.");
    }
    
    // 3. Let id be the result of getting the property id from action sequence.
    NSString* _id = actionSequence[@"id"];
    
    // 4. If id is undefined or is not a String, return error with error code
    //    invalid argument.
    if(_id == nil || ![_id isKindOfClass:[NSString class]]) {
      return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"Each action must have an id property, which must be a string.");
    }
    
    NSMutableDictionary *parameters = nil;
    
    // 5. If type is equal to pointer, let parameters data be the result of getting the
    //    property parameters from action sequence. Then let parameters be the result of
    //    trying to process pointer parameters with argument parameters data.
    if([type isEqual:@"pointer"]) {
      NSDictionary *parametersData = actionSequence[@"parameters"];
      parameters = [[NSMutableDictionary alloc] init];
      
      // == Process pointer parameters ==
      // 1. Let parameters be the default pointer parameters
      [parameters setObject:@"mouse" forKey:@"pointerType"];
      
      // 2. If parameters data is undefined, return success with data parameters
      if(parametersData != nil) {
        // 3. If parameters data is not an object, return error with error code
        //    invalid argument.
        if(![parametersData isKindOfClass:[NSDictionary class]]) {
          return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"The parameters property for a pointer action must be an object.");
        }
        
        // 4. Let pointer type by the result of getting a property named pointerType
        //    from parameters data
        NSString* pointerType = parametersData[@"pointerType"];
        
        // 5. If pointer type is not undefined:
        if(pointerType != nil) {
          // 1. If pointer type does not have one of the values "mouse", "pen" or "touch"
          //    return error with with error code invalid argument.
          if(![pointerType isEqual:@"mouse"]
             && ![pointerType isEqual:@"pen"]
             && ![pointerType isEqual:@"touch"]) {
            return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"The pointerType of a pointer action must be mouse, pen or touch");
          }
          
          // 2.  Set the pointerType property of parameters to pointer type
          [parameters setValue:pointerType forKey:@"pointerType"];
        } // pointerType != nil
      } // parametersData != nil
    } // type isEqual "pointer"
    
    // 6. Let source be the input source in the list of active input sources
    //    where that input source's input id matches id, or undefined if there
    //    is no matching input source
    NSDictionary *source = inputSources[_id];
    
    // 7. If source is undefined:
    if(source == nil) {
      // 1. Let source be a new input source created from the first match against type
      source = [[NSMutableDictionary alloc] init];
      [source setValue:type forKey:@"type"];
      
      if([type isEqual:@"pointer"]) {
        [source setValue:parameters[@"pointerType"] forKey:@"pointerType"];
      } // type isEqual pointer
      
      // 2. Add source to the current session's list of active input sources
      [inputSources setValue:source forKey:_id];
      
      // 3. Add source's input source state to the current session's input state table,
      // keyed on source's input id
    } // source == nil
    
    // 8. If source's source type does not match type return an error with error
    //    code invalid argument
    if(![source[@"type"] isEqual:type]) {
      return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"An input source must always have the same type");
    }
    
    // 9. If parameters is not undefined, then if its pointerType property does not match
    //    source's pointer type, return an error with error code invalid argument.
    if(parameters != nil && ![parameters[@"pointerType"] isEqual:source[@"pointerType"]]) {
      return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"An input source must always have the same pointer type");
    }
    
    // 10. Let action items be the result of getting a property named actions from action sequence
    NSArray *actionItems = actionSequence[@"actionItems"];
    
    // 11. If action items is not an Array, return error with error code invalid argument
    if(actionItems == nil || ![actionItems isKindOfClass:[NSArray class]]) {
      return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"An action sequence must have an actions property, which must be a sequence");
    }
    
    // 12. Let actions be a new list
    
    // 13. For each action item in action items:
    for(NSDictionary *actionItem in actionItems) {
      // 1. If actionItem is not an object return error with error code invalid arguments
      if(![actionItem isKindOfClass:[NSDictionary class]]) {
        return FBResponseWithStatus(FBCommandStatusInvalidArgument, @"Each entry in the actions property for an action sequence must be an object");
      }
      
      if([type isEqual:@"none"]) {
        return FBResponseWithStatus(FBCommandStatusUnsupported, @"None actions are not supported");
      } else if([type isEqual:@"key"]) {
        return FBResponseWithStatus(FBCommandStatusUnsupported, @"Key actions are not supported");
      } else if([type isEqual:@"pointer"]) {
        return FBResponseWithStatus(FBCommandStatusUnsupported, @"Pointer actions are not supported");
      }
    }
    
    actionsByTick = nil;
  }
  
  return FBResponseWithOK();
}
@end

