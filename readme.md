# PKNativeControls

@author Kerri Shotts
@email kerrishotts@gmail.com
@version 1.0.0

Implements some basic native controls for iOS. This library should be
considered "alpha" release, since it's very new. It currently only supports iOS 7, but
support is planned to extend to iOS 6 as well.

The library has been designed so as to be simple to code against: generally you don't
need to worry about a lot of asynchronous code except for event-handling. It's also
somewhat iOS-centric, so although the protocol could easily be implemented for another
platform, the lingo is iOS-inspired.

The license is MIT, so feel free to use, enhance, etc. If you do make changes that would
benefit the community, it would be great if you would contribute them back to the original
plugin, but that is not required.

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

## Repository

Available at https://github.com/photokandyStudios/PKNativeControls

## Minimum Requirements

* Cordova 2.9 or higher (tested 3.3)
* iOS 7 or higher (for now; iOS 6 support coming)

## Installation

Add the plugin using Cordova's CLI:

cordova plugin add com.photokandy.nativecontrols

## Use

All interaction with the library is through `window.nativeControls`. There are several 
methods that can be used to instantiate various native controls:

* NavigationBar
* NavigationItem
* BarButton
* ToolBar
* MessageBox
* ActionSheet

There are also utility methods:

* Rect
* Color

More native controls are planned for future releases.

### Navigation Bars

```
var navigationBar = window.nativeControls.NavigationBar();
navigationBar.tintColor = window.nativeControls.Color ( "red" );
navigationBar.barTintColor = window.nativeControls.Color ( "white" );
navigationBar.addToView();
```

This will create a navigation bar at the top of the window with a white background and a
red tint color (for any buttons).

Navigation bars can be re-oriented on the screen:

```
navigationBar.frame = window.nativeControls.Rect ( 320, 0, 768-320, 64 );
```

Navigation bars in iOS 7 usually carry translucency (blurring of the background); this can be 
turned off if desired:

```
navigationBar.translucent = false;
```

Note: your content is not moved out of the way of the navigation bar. You need to apply
the appropriate padding, margins, or positioning in order to keep your content out of the
way. The benefit here is if you allow the content to scroll under the navigation bar, you
can inherit the translucent effect present in iOS 7.

### Navigation Bar Items

Navigation bars by themselves aren't terribly interesting. In order to display text or
controls, you need to create a navigation bar item:

```
var navigationBarItem = window.nativeControls.NavigationBarItem();
navigationBarItem.title = "View Title";
```

At this point, one can add Bar Buttons to the left or right side:

```
navigationBarItem.leftButtons = [ button1, button2 ];
navigationBarItem.rightButtons = [ button3, button4 ];
```

After adding buttons, it can be pushed onto a navigation bar:

```
navigationBar.push ( navigationBarItem );
```

If further items are pushed, a back button appears with the title of the previous item. The
user could pop it manually (by pressing the back button), or this will pop it programmatically:

```
navigationBar.pop ();
```

Note: When pushing and popping navigation items, be careful not to do anything else with a navigation bar or item
during the animation process, or you will corrupt the view hierarchy. As iOS animations are fixed-duration, it's best
to delay about 400ms (maybe a little longer) to get around any corruption.

Navigation items can fire events when they are popped and pushed with the `pop` and `push` events.

### Bar Buttons

Bar buttons can be added to navigation items and tool bars. They can be a text label or
an icon. They will be tinted with their parent container's tint color (unless overridden).

```
var button1 = window.nativeControls.BarButton();
button1.title = "Add"
var button2 = window.nativeControls.BarButton();
button2.image = "/path/to/image" -- no .png or @2x
```

In order to respond to a button tap, you can attach an event handler:

```
button1.addEventListener ( "tap", function (evt) { ... } );
```

You can also remove event listeners when you no longer need to respond to the event.

Images will use "@2x" retina assets automatically if provided, and will scale them appropriately
if @1x retina assets are not provided. If the image is in the "www" directory, or a subdirectory,
refer to it like so:

```
button3.image = "/www/img/book";
```

### Tool Bars

Tool bars can be created like this:

```
var toolbar = window.nativeControls.ToolBar();
toolbar.buttons = [button1, button2];
toolbar.tintColor = window.nativeControls.Color ("blue");
toolbar.addToView();
```

Toolbars can also be positioned by changing their `frame` property.

### Message Boxes and Action Sheets

These are lumped together, because although they are presentationally different (on iPhone),
they are very similar logically.

A message box can be created as follows:

```
var messageBox = window.nativeControls.MessageBox();
messageBox.title = "Title of the message";
messageBox.text = "Are you sure?";
messageBox.addButtons ( "Yes", "No", "Cancel" );
messageBox.cancelButtonIndex = 2; -- zero-based
messageBox.addEventListener ( "tap", function ( evt ) { console.log ( evt.data ); } );
messageBox.show();
```

Message boxes can be hidden by calling `hide` -- any event handler will be called with the
cancel button index.

Alert boxes are created very similarly, except they don't support the `text` property. 
Furthermore, they add an additional property called `destructiveButtonIndex` that can
be used to specify which button will have a destructive effect, like so:

```
var actionSheet = window.nativeControls.ActionSheet();
actionSheet.title = "Title of sheet";
actionSheet.addButtons ( "Delete", "Share", "Cancel" );
actionSheet.cancelButtonIndex = 2;
actionSheet.destructiveButtonIndex = 0;
actionSheet.show();
```

Input boxes are Message boxes with a different `alertType`:

```
messageBox.alertType = "input" // or secureInput, default, userNameAndPassword
messageBox.inputText = "default text";
messageBox.passwordText = "default password"; // only if userNameAndPassword
```

Input boxes can fire additional events: `inputChanged` and `passwordChanged`. They also pass along the contents
of the input fields when a `tap` occurs. The way this is done currently is hacky in the extreme, but it works as
long as the user input isn't going to consist of pipes (|).

```
messageBox.addEventLister ( "tap", function ( evt )
{
  var data = evt.data.split("|||");
  var buttonPressed = data[0];
  var inputText = data[1];
  var passwordText = data[2];
}
```



