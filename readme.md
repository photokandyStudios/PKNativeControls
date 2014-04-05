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

Available on [Github](https://github.com/photokandyStudios/PKNativeControls). Contributions welcome!

## Minimum Requirements

* Cordova 2.9 or higher (tested 3.3)
* iOS 7 or higher (for now; iOS 6 support coming)

## Installation

Add the plugin using Cordova's CLI:

```
cordova plugin add com.photokandy.nativecontrols
```

## Use

All interaction with the library is through `window.nativeControls`. 

### `Rect`s

`Rect`s are used when you need to specify the frame for a native control. A frame is simply the position and size of a native control on the screen.

The `Rect` method takes four parameters: `x` and `y` coordinates for the top-left corner of the frame and `w` and `h` values indicating the size of the frame. An object of the form `{origin: {x: #, y: #}, size: {w: #, h: #}}` is returned.

```
var aRect = window.nativeControls.Rect (10, 50, 100, 200);
```
The above rectangle indicates a rectangle with the top left corner at (10, 50) and a bottom right corner at (110, 250).

**Note:** You aren't required to use window.nativeControls.Rect as long as you pass in an object of the above form.


### `Color`s

`Color`s are used when you need to specify the color of an item. Instead of passing hex colors (like `#204080`), the red, green, blue, and alpha components are passed. Alternatively, a few predefined colors can be passed as a string (like `BLUE`).

Four parameters are required unless a predefined color is used -- the first three specify the red, green, and blue values, and range from 0 to 255. The last value specifies the alpha value, and ranges from 0.0 to 1.0. 

The returned object is of the form `{r: #, g: #, b: #, a: #}`.

```
var aBlueColor = window.nativeControls.Color ( 0, 0, 128, 1.0 );
var aRedColor = window.nativeControls.Color ( 'RED' );
```

**Note:** You aren't required to use window.nativeControls.Color as long as you pass in an object of the above form.

#### Predefined colors
* `Clear`
* `Black`
* `Blue`
* `Green`
* `Red`
* `DarkGray`
* `Gray`
* `LightGray`
* `White`
* `Cyan`
* `Yellow`
* `Magenta`
* `Orange`
* `Purple`
* `Brown`

### Native Controls

All native controls are based on a `NativeControl` class that is initialized with the type of control you wish to create. This can be done by calling any of the native control creation methods:

* `NavigationBar`
* `NavigationItem`
* `BarButton`
* `ToolBar`
* `MessageBox`
* `ActionSheet`

For example, you can create a `BarButton` using

```
var aButton = window.nativeControls.BarButton();
```

When you are done with a native control, you should always destroy it, otherwise your app will leak resources. Destroy it as follows:

```
aButton.destroy();
```


#### `BarButton`s

`BarButton`s can be added to `NavigationItem`s and `ToolBar`s. They can be a text label or an icon. They will be tinted with their parent container's tint color (unless overridden).

```
var button1 = window.nativeControls.BarButton();
button1.title = "Add"
var button2 = window.nativeControls.BarButton();
button2.image = "/path/to/image" // no .png or @2x
```

In order to respond to a button tap, you can attach an event handler:

```
button1.addEventListener ( "tap", function (evt) { ... } );
```

You can also remove event listeners when you no longer need to respond to the event.

Images will use "@2x" retina assets automatically if provided, and will scale them appropriately if @1x retina assets are not provided. If the image is in the `www/img` directory, or a subdirectory, refer to it like so:

```
button3.image = "/www/img/book";
```

##### Properties

* `title <string>` - the title of the button
* `image <string>` - the image for the button (overrides `title`)
* `tintColor <Color>` - the tint color of the button

##### Methods

* `addEventListener (event, handler)` - adds an event listener to the button
* `removeEventListener (event, handler)` - removes an event listener from the button
* `destroy` - destroys the control

##### Events

* `tap` - fired when the button is tapped.

#### `NavigationBar`s

This will create a navigation bar at the top of the window with a white background and a
red tint color (for any buttons):

```
var navigationBar = window.nativeControls.NavigationBar();
navigationBar.tintColor = window.nativeControls.Color ( "red" );
navigationBar.barTintColor = window.nativeControls.Color ( "white" );
navigationBar.addToView();
```

Navigation bars can be re-oriented on the screen:

```
navigationBar.frame = window.nativeControls.Rect ( 320, 0, 768-320, 64 );
```

Navigation bars in iOS 7 usually carry translucency (blurring of the background); this can be turned off if desired:

```
navigationBar.translucent = false;
```

Note: your content is not moved out of the way of the navigation bar. You need to apply the appropriate padding, margins, or positioning in order to keep your content out of the way. The benefit here is if you allow the content to scroll under the navigation bar, you can inherit the translucent effect present in iOS 7.

##### Properties

* `barTintColor <Color>` - the background color of the navigation bar
* `tintColor <Color>` - the tint color of the button
* `frame <Rect>` - the location of the navigation bar on screen
* `translucent <boolean>` - indicates if the navigation bar is translucent or opaque

##### Methods

* `addToView` - adds the navigation bar to the web view
* `removeFromView` - removes the navigation bar from the web view
* `push ( NavigationItem )` - pushes a `NavigationItem` onto the bar
* `pop` - pops the currently visible `NavigationItem` off the bar
* `destroy` - destroys the control

##### Events

* None


#### `NavigationItem`s

`NavigationBar`s by themselves aren't terribly interesting. In order to display text or controls, you need to create a `NavigationItem`:

```
var navigationItem = window.nativeControls.NavigationItem();
navigationItem.title = "View Title";
```

At this point, one can add `BarButton`s to the left or right side:

```
navigationItem.leftButtons = [ button1, button2 ];
navigationItem.rightButtons = [ button3, button4 ];
```

After adding buttons, it can be pushed onto a navigation bar:

```
navigationBar.push ( navigationItem );
```

If further `NavigationItem`s are pushed, a back button appears with the title of the previous `NavigationItem`. The user could pop it manually (by pressing the back button), or it can be popped  programmatically:

```
navigationBar.pop ();
```

Note: When pushing and popping `NavigationItem`s, be careful not to do anything else with a `NavigationBar` or `NavigationItem` during the animation process, or you will corrupt the view hierarchy. As iOS animations are fixed-duration, it's best
to delay about 400ms (perhaps even a little longer) to get around any animation.

Navigation items can fire events when they are popped and pushed with the `pop` and `push` events.

##### Properties

* `title <String>` - the name of the `NavigationItem`
* `leftButtons <Array of BarButton>` - `Array` of `BarButton`s to display on the left side of the `NavigationItem`
* `rightButtons <Array of BarButton>` - `Array` of `BarButton`s to display on the right side of the `NavigationItem`

##### Methods

* `destroy` - destroys the control

##### Events

* `push` - fired when this `NavigationItem` is pushed onto a `NavigationBar`
* `pop` - fired when this `NavigationItem` is popped from a `NavigationBar` (or when a user taps the back button on a `NavigationItem`)


#### `ToolBar`s

`ToolBar`s can be created like this:

```
var toolbar = window.nativeControls.ToolBar();
toolbar.buttons = [button1, button2];
toolbar.tintColor = window.nativeControls.Color ("blue");
toolbar.addToView();
```

Toolbars can also be positioned by changing their `frame` property.

##### Properties

* `tintColor <Color>` - The tint color for any `BarButton`s
* `buttons <Array of BarButton>` - `Array` of `BarButton`s to display in the center of the `ToolBar`
* `frame <Rect>` - the location of the tool bar on screen


##### Methods

* `addToView` - adds the tool bar to the web view
* `removeFromView` - removes the tool bar from the web view
* `destroy` - destroys the control

##### Events

* None



### `MessageBox`es, Input boxes, and `ActionSheeet`s

These are lumped together, because although they are presentationally different (on iPhone), they are very similar logically.

A message box can be created as follows:

```
var messageBox = window.nativeControls.MessageBox();
messageBox.title = "Title of the message";
messageBox.text = "Are you sure?";
messageBox.addButtons ( [ "Yes", "No", "Cancel" ] );
messageBox.cancelButtonIndex = 2; // zero-based
messageBox.addEventListener ( "tap", function ( evt ) { console.log ( evt.data ); } );
messageBox.show();
```

Message boxes can be hidden by calling `hide` -- any event handler will be called with the cancel button index.

Alert boxes are created very similarly, except they don't support the `text` property.  Furthermore, they add an additional property called `destructiveButtonIndex` that can be used to specify which button will have a destructive effect, like so:

```
var actionSheet = window.nativeControls.ActionSheet();
actionSheet.title = "Title of sheet";
actionSheet.addButtons ( [ "Delete", "Share", "Cancel" ] );
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

Input boxes can fire additional events: `inputChanged` and `passwordChanged`. They also pass along the contents of the input fields when a `tap` occurs. The way this is done currently is hacky in the extreme, but it works as long as the user input isn't going to consist of pipes (`|`).

```
messageBox.addEventLister ( "tap", function ( evt )
{
  var data = evt.data.split("|||");
  var buttonPressed = data[0];
  var inputText = data[1];
  var passwordText = data[2];
}
```

##### Properties

* `title <String>` - The title of the alert
* `text <String>` - Secondary text of the alert; valid only for `messageBox` (not `actionSheet`)
* `cancelButtonIndex <Integer>` - specifies which button is the cancel button; zero-based
* `destructiveButtonIndex <Integer>` - specifies which button is destructive; zero-based. Only available for `actionSheet`s
* `type <String>` - specifies the type of `MessageBox`; one of `default` (normal `MessageBox`), `input` (`MessageBox` with one input field), `secureInput` (`MessageBox` with one input field that masks characters), and `userNameAndPassword` (`MessageBox` with a username field and password field). Only available for `MessageBox`
* `inputText` - sets the default text for a `MessageBox` with an input field; only available for `MessageBox`
* `passwordText` - sets the default password for a `MessageBox` with username and password fields; only available for `MessageBox`

##### Methods

* `show` - displays the alert
* `hide` - dismisses the alert; any handler is called indicating that the `cancelButtonIndex` button was tapped
* `destroy` - destroys the control

##### Events

* `tap` - fired whenever a button is tapped or the alert is dismissed. The button tapped is specified in the `data` field of the `event` (zero-based). For `MessageBox`es having data fields, the input fields are appended to `data` and split using `|||`.

## Protocol

Communication from JavaScript over the native bridge are queued internally. The queue only processes one command at a time and executes commands in the order they were queued.

Commands can be enqueued by calling `window.nativeControls.queueExec` with the following parameters:

* The native control
* The command (string)
* Command data
* success handler (optional)
* failure handler (optional)

The queue is processed whenever `queueExec` is called and as long as there are items in the queue. Commands are then sent over to the native side by using `cordova.exec` passing `PKNativeControls` and `handleOperation` as the method call. Data passed includes the control's class, unique ID, the command, and the command data.

The native side receives these values and acts on them according to the type of control, the control's unique ID, and the command. If the operation is successful, the succes handler is called. If the operation fails, the failure handler is called. 

### Control Classes and Supported Commands

| Command            | NavigationBar | NavigationItem | BarButton | ToolBar | MessageBox | ActionSheet |
|:-------------------|:-------------:|:--------------:|:---------:|:-------:|:----------:|:-----------:|
|addToView           | X             | -              | -         | X       | -          | -           |
|addButtons          | -             | -              | -         | -       | X          | X           |
|create              | X             | X              | X         | X       | X          | X           |
|destroy             | X             | X              | X         | X       | X          | X           |
|getFrame*           | X             | -              | -         | X       | -          | -           |
|getInputText*       | -             | -              | -         | -       | X          | -           |
|getPasswordText*    | -             | -              | -         | -       | X          | -           |
|hide                | -             | -              | -         | -       | X          | X           |
|pop                 | X             | -              | -         | -       | -          | -           |
|push                | X             | -              | -         | -       | -          | -           |
|removeFromView      | X             | -              | -         | X       | -          | -           |
|setBarTintColor     | X             | -              | -         | X       | -          | -           |
|setButtons          | -             | -              | -         | X       | -          | -           |
|setCancelButton     | -             | -              | -         | -       | X          | X           |
|setDestructiveButton| -             | -              | -         | -       | -          | X           |
|setFrame            | X             | -              | -         | X       | -          | -           |
|setImage            | -             | -              | X         | -       | -          | -           |
|setInputText        | -             | -              | -         | -       | X          | -           |
|setLeftButtons      | -             | X              | -         | -       | -          | -           |
|setPasswordText     | -             | -              | -         | -       | X          | -           |
|setRightButtons     | -             | X              | -         | -       | -          | -           |
|setTintColor        | X             | -              | X         | X       | -          | -           |
|setTitle            | -             | X              | X         | -       | X          | X           |
|setTranslucency     | X             | -              | -         | -       | -          | -           |
|setType             | -             | -              | -         | -       | X          | -           |
|show                | -             | -              | -         | -       | X          | X           |

\* Data is returned to the success handler

### Commands and Parameters

| Command            | Parameter                      | Return                         |
|:-------------------|:-------------------------------|:-------------------------------|
|addToView           | -                              | -                              |
|addButtons          | Array of Control IDs           | -                              |
|create              | -                              | -                              |
|destroy             | -                              | -                              |
|getFrame            | -                              | Array: [x, y, w, h]            |
|getInputText        | -                              | String: Input text             |
|getPasswordText     | -                              | String: Password text          |
|hide                | -                              | -                              |
|pop                 | -                              | -                              |
|push                | NavigationItem Control ID      | -                              |
|removeFromView      | -                              | -                              |
|setBarTintColor     | Array: [r, g, b, a]            | -                              |
|setButtons          | Array of Bar Button IDs        | -                              |
|setCancelButton     | Integer                        | -                              |
|setDestructiveButton| Integer                        | -                              |
|setFrame            | Array: [x, y, w, h]            | -                              |
|setImage            | String: path to image          | -                              |
|setInputText        | String                         | -                              |
|setLeftButtons      | Array of Bar Button IDs        | -                              |
|setPasswordText     | String                         | -                              |
|setRightButtons     | Array of Bar Button IDs        | -                              |
|setTintColor        | Array: [r, g, b, a]            | -                              |
|setTitle            | String                         | -                              |
|setTranslucency     | Boolean                        | -                              |
|setType             | String                         | -                              |
|show                | -                              | -                              |

### Events

Controls that can send events do so using `cordova.fireDocumentEvent`. The event is of the form `UUID_Event`. For example, if a control has an ID of `28bbc290-d3df-4df3-ac58-e23296bcb7ea` and a `tap` event is fired, a document event of `28bbc290-d3df-4df3-ac58-e23296bcb7ea_tap` is fired. A native control's `addEventListener` method simply registers for this event name.

Return data is passed via a `data` object when using `cordova.fireDocumentEvent`; this is accessible to event handlers by using `event.data`.
