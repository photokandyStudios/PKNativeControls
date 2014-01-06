/**
 *
 * PKNativeControls.m
 *
 * @author Kerri Shotts
 * @version 1.0.1
 *
 * Copyright (c) 2013 Kerri Shotts, photoKandy Studios LLC
 *
 * License: MIT
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to the following
 * conditions:
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
 * OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import "PKNativeControls.h"
#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"

typedef CDVPluginResult* (^nativeControlHandler)(NSString*, NSString*, id, UIView*);

@implementation PKNativeControls
{
  NSMutableDictionary* _nativeControls;                     // dictionary of all native controls
};

#define NATIVE_CONTROL_HANDLER (CDVPluginResult*)^(NSString *CLASS, NSString *ID, id value, UIView *nc)

-(NSDictionary *) codeHandlers
{
  static NSDictionary* ch;
  if (!ch)
  {
    ch =
    @{
        @"DEFAULT":
        @{
            @"destroy":        NATIVE_CONTROL_HANDLER
            {
              if ([nc respondsToSelector:@selector(removeFromSuperview)])
              {
                [nc removeFromSuperview];
              }
              [_nativeControls removeObjectForKey:ID];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"addToView":      NATIVE_CONTROL_HANDLER
            {
              [self.webView.superview addSubview: nc];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"removeFromView": NATIVE_CONTROL_HANDLER
            {
              if ([nc respondsToSelector:@selector(removeFromSuperview)])
              {
                [nc removeFromSuperview];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setFrame":       NATIVE_CONTROL_HANDLER
            {
              if ([nc respondsToSelector:@selector(setFrame:)])
              {
                NSArray *theFrameValues = value;
                CGRect theFrame = CGRectMake([theFrameValues[0] floatValue], [theFrameValues[1] floatValue],
                                             [theFrameValues[2] floatValue], [theFrameValues[3] floatValue]);
                [nc setFrame:theFrame];
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NC040: Could not set the frame."];
            },
            @"getFrame":       NATIVE_CONTROL_HANDLER
            {
              if ([nc respondsToSelector:@selector(frame)])
              {
                CGRect theFrame = nc.frame;
                NSArray *theFrameValues = @[ @(theFrame.origin.x), @(theFrame.origin.y), @(theFrame.size.width), @(theFrame.size.height)];
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:theFrameValues];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NC041: Could not get the frame."];
            },
            @"setTitle":        NATIVE_CONTROL_HANDLER
            {
              if ([nc respondsToSelector:@selector(setTitle:)])
              {
                [nc performSelector:@selector(setTitle:) withObject:value];
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NC050: Control did not set title."];
            },
            @"setImage":        NATIVE_CONTROL_HANDLER
            {
              if ([nc respondsToSelector:@selector(setImage:)])
              {
                [nc performSelector:@selector(setImage:) withObject:[UIImage imageNamed:value]];
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NC051: Control did not set image."];
            },
            @"setTintColor":    NATIVE_CONTROL_HANDLER
            {
              if ([nc respondsToSelector:@selector(setTintColor:)])
              {
                NSArray *colorValues = value;
                UIColor *aColor = [UIColor colorWithRed:[colorValues[0] floatValue]/255
                                                  green:[colorValues[1] floatValue]/255
                                                  blue: [colorValues[2] floatValue]/255
                                                  alpha:[colorValues[3] floatValue]];
                [nc performSelector:@selector(setTintColor:) withObject:aColor];
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NC030: Control did not set tint color."];
            },
            @"setBarTintColor": NATIVE_CONTROL_HANDLER
            {
              if ([nc respondsToSelector:@selector(setBarTintColor:)])
              {
                NSArray *colorValues = value;
                UIColor *aColor = [UIColor colorWithRed:[colorValues[0] floatValue]/255
                                                  green:[colorValues[1] floatValue]/255
                                                  blue: [colorValues[2] floatValue]/255
                                                  alpha:[colorValues[3] floatValue]];
                [nc performSelector:@selector(setBarTintColor:) withObject:aColor];
                return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NC031: Control did not set bar tint color."];
            }
        },
        @"NavigationBar":
        @{
            @"create":          NATIVE_CONTROL_HANDLER
            {
              // create the navigation bar, with a default frame.
              UINavigationBar* navc = ({
                UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame: ({
                                                              CGRect frame = self.webView.superview.frame;
                                                              frame.origin.y = 0;
                                                              frame.size.height = 64;
                                                              frame;
                                                            })];
                navigationBar.delegate = self;
                navigationBar;
              });
              [self _addNativeControl:navc withID:ID];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"push":            NATIVE_CONTROL_HANDLER
            {
              // Push a navigation item on to the navigation bar
              UINavigationBar* navc = (UINavigationBar*) nc;
              [navc pushNavigationItem:_nativeControls[value] animated:YES];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"pop":             NATIVE_CONTROL_HANDLER
            {
              // Pop a navigation item off the navigation bar
              UINavigationBar* navc = (UINavigationBar*) nc;
              [navc popNavigationItemAnimated: navc.backItem != nil];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setTranslucency": NATIVE_CONTROL_HANDLER
            {
              // Set the bar's translucency to true/YES or false/NO
              UINavigationBar* navc = (UINavigationBar*) nc;
              navc.translucent = [value boolValue];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        },
        @"NavigationItem":
        @{
            @"create": NATIVE_CONTROL_HANDLER
            {
              UINavigationItem* navi = ({
                UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
                navigationItem.leftItemsSupplementBackButton = YES;
                navigationItem;
              });
              [self _addNativeControl:navi withID:ID];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setLeftButtons": NATIVE_CONTROL_HANDLER
            {
              NSArray *buttonIDs = value;
              NSMutableArray *buttonControls = [[NSMutableArray alloc] init];
              for (NSString* buttonID in buttonIDs) {
                [buttonControls addObject:_nativeControls[buttonID]];
              }
              ((UINavigationItem *) nc).leftBarButtonItems = buttonControls;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setRightButtons": NATIVE_CONTROL_HANDLER
            {
              NSArray *buttonIDs = value;
              NSMutableArray *buttonControls = [[NSMutableArray alloc] init];
              for (NSString* buttonID in buttonIDs) {
                [buttonControls addObject:_nativeControls[buttonID]];
              }
              ((UINavigationItem *) nc).rightBarButtonItems = buttonControls;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        },
        @"BarButton":
        @{
            @"create": NATIVE_CONTROL_HANDLER
            {
              UIBarButtonItem* barb = ({
                UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonPressed:)];
                barButton;
              });
              [self _addNativeControl:barb withID:ID];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        },
        @"ToolBar":
        @{
            @"create": NATIVE_CONTROL_HANDLER
            {
              // create the tool bar, with a default frame.
              UIToolbar* tool = ({
                UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame: ({
                                                              CGRect frame = self.webView.superview.frame;
                                                              frame.origin.y = frame.origin.y - 44;
                                                              frame;
                                                            })];
                toolBar;
              });
              [self _addNativeControl:tool withID:ID];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setButtons": NATIVE_CONTROL_HANDLER
            {
              NSArray *buttonIDs = value;
              NSMutableArray *buttonControls = [[NSMutableArray alloc] init];
              for (NSString* buttonID in buttonIDs) {
                [buttonControls addObject:_nativeControls[buttonID]];
              }
              ((UIToolbar *) nc).items = buttonControls;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        },
        @"MessageBox":
        @{
            @"create": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = ({
                UIAlertView *alertView = [[UIAlertView alloc] init];
                alertView.delegate = self;
                alertView;
              });
              [self _addNativeControl:alert withID:ID];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setText": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              alert.message = value;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setTitle": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              alert.title = value;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"addButtons": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              NSArray *buttonValues = value;
              for (NSString *button in buttonValues) {
                [alert addButtonWithTitle:button];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setCancelButton": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              [alert setCancelButtonIndex:[value intValue]];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"show": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              [alert show];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"hide": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              [alert dismissWithClickedButtonIndex:alert.cancelButtonIndex animated:YES];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setType": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              NSString *style = value;
              if ([style isEqualToString:@"default"])
              {
                alert.alertViewStyle = UIAlertViewStyleDefault;
              }
              if ([style isEqualToString:@"input"])
              {
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
              }
              if ([style isEqualToString:@"secureInput"])
              {
                alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
              }
              if ([style isEqualToString:@"userNameAndPassword"])
              {
                alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"getInputText": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[alert textFieldAtIndex:0].text];
            },
            @"setInputText": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              [alert textFieldAtIndex:0].text = value;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"getPasswordText": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[alert textFieldAtIndex:1].text];
            },
            @"setPasswordText": NATIVE_CONTROL_HANDLER
            {
              UIAlertView *alert = (UIAlertView *)nc;
              [alert textFieldAtIndex:1].text = value;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            
        },
        @"ActionSheet":
        @{
            @"create": NATIVE_CONTROL_HANDLER
            {
              UIActionSheet *as = ({
                UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
                actionSheet.delegate = self;
                actionSheet;
              });
              [self _addNativeControl:as withID:ID];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setTitle": NATIVE_CONTROL_HANDLER
            {
              UIActionSheet *as = (UIActionSheet *)nc;
              as.title = value;
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"addButtons": NATIVE_CONTROL_HANDLER
            {
              UIActionSheet *as = (UIActionSheet *)nc;
              NSArray *buttonValues = value;
              for (NSString *button in buttonValues) {
                [as addButtonWithTitle:button];
              }
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setCancelButton": NATIVE_CONTROL_HANDLER
            {
              UIActionSheet *as = (UIActionSheet *)nc;
              [as setCancelButtonIndex:[value intValue]];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"setDestructiveButton": NATIVE_CONTROL_HANDLER
            {
              UIActionSheet *as = (UIActionSheet *)nc;
              [as setDestructiveButtonIndex:[value intValue]];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"show": NATIVE_CONTROL_HANDLER
            {
              //TODO: Handle iPad
              UIActionSheet *as = (UIActionSheet *)nc;
              [as showInView:self.webView.superview];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            },
            @"hide": NATIVE_CONTROL_HANDLER
            {
              UIActionSheet *as = (UIActionSheet *)nc;
              [as dismissWithClickedButtonIndex:as.cancelButtonIndex animated:YES];
              return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
        
            
    };
  }
  return ch;
}

/**
 * Handle navigation bar operations
 */
-(void)handleOperation:(CDVInvokedUrlCommand*) command
{

  CDVPluginResult* pluginResult = nil;
  
  NSString *CLASS = command.arguments[0];
  NSString *ID = command.arguments[1];
  NSString *OP = command.arguments[2];
  id value = command.arguments[3];
  
  // look up the block of code based on the CLASS and OP
  NSDictionary *allHandlers = [self codeHandlers];
  NSDictionary *handlerForClass = allHandlers[CLASS];
  nativeControlHandler handlerForOP = handlerForClass[OP];
  
  NSDictionary *handlerForDefault = allHandlers[@"DEFAULT"];
  nativeControlHandler handlerForDefaultOP = handlerForDefault[OP];
  
  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No handler for specificed control class."];
  
  // now look up the view, if it exists, based on ID
  UIView *nc = nil;
  if (ID)
  {
    nc = _nativeControls[ID];
  }
  // if it doesn't exist, and the OP is anything but a create OP, error out
  if (!nc && ![OP isEqualToString:@"create"])
  {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Control ID not found. Did you destroy it?"];
  }
  else
  {
    // call the appropriate code handler, based on which one exists
    if (handlerForOP)
    {
      pluginResult = handlerForOP ( CLASS, ID, value, nc );
    }
    else if (handlerForDefaultOP)
    {
      pluginResult = handlerForDefaultOP ( CLASS, ID, value, nc );
    }
  }
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *  Creates the _nativeControls dictionary if it isn't already created.
 */
-(void) _createNativeControls
{
  if (_nativeControls == nil)
  {
    _nativeControls = [NSMutableDictionary dictionary];
  }
}

/**
 * Adds a native control to the internal array and assigns
 * a UUID to it, and returns it.
 */
-(NSString *)_addNativeControl: (id) control
{
  [self _createNativeControls];
  NSString *theID = [[NSUUID UUID] UUIDString];
  [_nativeControls setValue:control forKey:theID];
  return theID;
}

-(void)_addNativeControl: (id) control withID: (NSString *) ID
{
  [self _createNativeControls];
  [_nativeControls setValue:control forKey:ID];
}

/**
 * triggers an event in the webview
 */
-(void) sendEvent: (NSString *)event withData: (NSString *)data forControlID: (NSString *)ID
{
  if (data == NULL)
  {
    [self writeJavascript:[NSString stringWithFormat:@"setTimeout( function() { cordova.fireDocumentEvent('%@_%@') }, 0);", ID, event]];
  }
  else
  {
    [self writeJavascript:[NSString stringWithFormat:@"setTimeout( function() { cordova.fireDocumentEvent('%@_%@', {data:'%@'} ) }, 0);", ID, event, data]];
  }
}
-(void) sendEvent: (NSString *)event forControlID: (NSString *)ID
{
 [self sendEvent:event withData:NULL forControlID:ID];
}

/**
 * Finds a control in the dictionary, given only the control (not the ID)
 */
-(NSString *)getIDForControl: (id)control
{
  NSArray *possibleIDs = [_nativeControls allKeysForObject:control];
  return [possibleIDs firstObject];
}

#pragma mark -
#pragma mark Button presses

/**
 * Send a "tap" event for any bar button that is pressed
 */
-(void)barButtonPressed: (id) sender
{
  NSString *ID = [self getIDForControl:sender];
  [self sendEvent:@"tap" forControlID:ID];
}

#pragma mark -
#pragma mark UINavigationBarDelegate methods

-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
  [self sendEvent:@"pop" forControlID:[self getIDForControl:item]];
  return YES;
}

-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item
{
  [self sendEvent:@"push" forControlID:[self getIDForControl:item]];
  return YES;
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

/*
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  [self sendEvent:@"tap" withData: [NSString stringWithFormat:@"%i", buttonIndex] forControlID:[self getIDForControl:alertView]];
}
*/
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  NSString *ID = [self getIDForControl:alertView];
  if (alertView.alertViewStyle == UIAlertViewStyleDefault)
  {
    [self sendEvent:@"tap" withData: [NSString stringWithFormat:@"%i", buttonIndex] forControlID:ID];
  }
  else
  {
    [self sendEvent:@"inputChanged" withData: [alertView textFieldAtIndex:0].text forControlID:ID];
    if (alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput)
    {
      [self sendEvent:@"passwordChanged" withData: [alertView textFieldAtIndex:1].text forControlID:ID];
      [self sendEvent:@"tap" withData: [NSString stringWithFormat:@"%i|||%@|||%@", buttonIndex, [alertView textFieldAtIndex:0].text, [alertView textFieldAtIndex:1].text] forControlID:ID];
    }
    else
    {
      [self sendEvent:@"tap" withData: [NSString stringWithFormat:@"%i|||%@", buttonIndex, [alertView textFieldAtIndex:0].text] forControlID:ID];
    }
  }
}


#pragma mark-
#pragma mark UIActionSheetDelegate methods
/*
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  [self sendEvent:@"tap" withData: [NSString stringWithFormat:@"%i", buttonIndex] forControlID:[self getIDForControl:actionSheet]];
}
*/
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  [self sendEvent:@"tap" withData: [NSString stringWithFormat:@"%i", buttonIndex] forControlID:[self getIDForControl:actionSheet]];
}


@end
