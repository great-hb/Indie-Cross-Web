package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.geom.Matrix;

class VideoHandler {
    public var finishCallback:Void->Void;
    public var stateCallback:FlxState;

    public var video:Video;
    public var netConnection:NetConnection;
    public var netStream:NetStream;

    public var sprite:FlxSprite;

    public var fadeToBlack:Bool = false;
    public var fadeFromBlack:Bool = false;
    public var allowSkip:Bool = false;

	public var bitmapData:openfl.display.BitmapData;

    public function new() {
        FlxG.autoPause = false;
    }

    public function playMP4(
        path:String, 
        ?repeat:Bool = false, 
        ?outputTo:FlxSprite = null, 
        ?isWindow:Bool = false, // does nothing anymore
        ?isFullscreen:Bool = false,  // does nothing anymore
        ?midSong:Bool = false
    ):Void {

        // Create a NetConnection and NetStream for playing the video
        netConnection = new NetConnection();
        netConnection.connect(null);

		var meta:Dynamic = { };
		meta.onPlayStatus = function(meta:Dynamic):Void
		{
			if (meta.code == "NetStream.Play.Complete") {
				if (repeat) {
					netStream.seek(0); // Reset the stream to the beginning
					netStream.play(path); // Replay the video
				} else {
					onVideoComplete();
				}
			} else if (meta.code == "NetStream.Play.Stop") { // idk
				onVideoComplete();
			}
		}

        netStream = new NetStream(netConnection);
		netStream.client = meta;

        var width:Int = FlxG.width;
        var height:Int = FlxG.height;

		trace("Using video size of " + width + "x" + height);

        video = new Video(width, height);
		netStream.play(path);
        video.attachNetStream(netStream);
		FlxG.addChildBelowMouse(video);

        if (outputTo != null) {
            // display frames on a FlxSprite
			video.alpha = 0;
            sprite = outputTo;
        }

        onVideoReady(); // lazy, this prob works fine
        FlxG.stage.addEventListener(Event.ENTER_FRAME, update);
		FlxG.stage.addEventListener(Event.ENTER_FRAME, fixVolume);
    }

	function onVideoReady() {
    	bitmapData = new openfl.display.BitmapData(Std.int(sprite.width), Std.int(sprite.height), true, 0x00000000);

		if (fadeFromBlack)
		{
			FlxG.camera.fade(FlxColor.BLACK, 0, false);
		}
	}

    private function copyFrameToSprite():Void {
        try {
            if (sprite != null && video != null) {
                bitmapData.fillRect(bitmapData.rect, 0x00000000); // Clear the BitmapData
                
                var matrix:Matrix = new Matrix();
                matrix.scale(
                    sprite.width / video.width,  // Scale factor for width
                    sprite.height / video.height // Scale factor for height
                );
                
                bitmapData.draw(video, matrix); // Draw video onto BitmapData
                sprite.pixels = bitmapData;
                sprite.dirty = true; // Mark as dirty
            }
        } catch (e:Dynamic) {
            trace('An error occurred: ' + e);
            cleanUp();
        }
    }

	function fixVolume(e:Event)
	{
		if (netStream != null) {
            var volume = 0.0;
			if (!FlxG.sound.muted && FlxG.sound.volume > 0.01) 
			{
				volume = FlxG.sound.volume * 0.5 + 0.5;
			}
            netStream.soundTransform = new openfl.media.SoundTransform(volume);
		}
	}

    function onVideoComplete():Void {
        trace("Video complete!");

        if (fadeToBlack) {
            FlxG.camera.fade(FlxColor.BLACK, 1, false);
        }

        if (fadeFromBlack) {
            FlxG.camera.fade(FlxColor.BLACK, 1, true);
        }

        new FlxTimer().start(0.3, function(timer:FlxTimer) {
            if (finishCallback != null) {
                finishCallback();
            } else if (stateCallback != null) {
                LoadingState.loadAndSwitchState(stateCallback);
            }

            cleanUp();
        });
    }

    public function cleanUp():Void {
        FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);
        FlxG.stage.removeEventListener(Event.ENTER_FRAME, fixVolume);
        if (video != null && FlxG.game.contains(video)) {
            FlxG.game.removeChild(video);
        }
        if (netStream != null) {
            netStream.dispose();
        }
        video = null;
        netStream = null;
        netConnection = null;
    }

    public function kill():Void {
        if (finishCallback != null) {
            finishCallback();
        }
        cleanUp();
    }

    public function trySkip():Void {
        if (allowSkip) {
            if (netStream != null) {
                trace("skipping...");
                onVideoComplete();
            }
        }
    }

    public function update(e:Event):Void {
        if (FlxG.keys.justPressed.ENTER) {
            trySkip();
        }

        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
        if (gamepad != null && gamepad.justPressed.B) {
            trySkip();
        }

		copyFrameToSprite();
    }
}
