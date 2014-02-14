package com.andreasmcdermott.rocketbird;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.text.TextFormat;
import flash.ui.Mouse;
import hxfw.Factory;
import hxfw.Game;
import hxfw.Input;
import hxfw.particles.Emitter;
import hxfw.scenes.Scene;
import com.andreasmcdermott.rocketbird.scenes.GameScene;

/**
 * ...
 * @author Andreas McDermott
 */

class Main extends Game 
{
	public static var TheBitmap( default, null):Bitmap;
	
	public function new() 
	{
		super();
		Game.Scale = 4;
	}
	
	override private function init():Void 
	{
		super.init();
		TheBitmap = Factory.createSquare(1, 1);
		Mouse.hide();
		Emitter.setBitmap(TheBitmap);
		Game.DefaultFont = new TextFormat("assets/fnt/04B03", 8, 0xffffffff);
		Scene.goto(new GameScene());
	}
	
	public static function main() 
	{
		Lib.current.addChild(new Main());
	}
}
