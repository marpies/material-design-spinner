# Material design spinner extension for Feathers

A simple animated display object for apps powered by [Starling](https://github.com/Gamua/Starling-Framework) and [Feathers](https://github.com/BowlerHatLLC/feathers).

![Spinner](spinner.gif)

## Getting started

You can either use a pre-compiled [SWC file](swc/) or the original source file and texture from the [source](source/) directory. The `assets` directory should be in the same level as you project's `src` directory. Alternatively, you can update the [path to the embedded texture](source/src/feathers/extensions/MaterialDesignSpinner.as#L33).

## Usage

The spinner can be used as any other Starling DisplayObject.

```as3
import feathers.extensions.MaterialDesignSpinner;

private var mSpinner:MaterialDesignSpinner;
...

mSpinner = new MaterialDesignSpinner();
addChild(mSpinner);
```

You can change the color to your liking:

```as3
mSpinner.color = 0x00BCD4;
```

The animation starts automatically once it is displayed on the stage, and it is stopped when removed. You can pass in a custom `Juggler` to manage the animation by yourself; `Starling.juggler` is used by default. 

```as3
var myJuggler:Juggler = new Juggler();

mSpinner.juggler = myJuggler;
```

The spinner extends `FeathersControl` which means you are able to use it in your Feathers layouts.

```as3
mSpinner.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
```

## Re-compile SWC

If you edit the texture and wish to re-compile the SWC file, you can use the provided ANT [build](build/) script. Make sure to edit [build.properties](build/build.properties) to match your local environment and execute `ant` from the build directory.

## Requirements

* [Starling Framework 2.0+](https://github.com/Gamua/Starling-Framework)
* [Feathers 3.0+](https://github.com/BowlerHatLLC/feathers)

## Credits

The work is based on [RadialProgressBar](http://forum.starling-framework.org/topic/radial-progress-bar#post-88380) created by [Jakub Wagner](https://twitter.com/@jakubwagner). Modifications have been made by [Marcel Piestansky](https://twitter.com/marpies).

Distributed under [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
