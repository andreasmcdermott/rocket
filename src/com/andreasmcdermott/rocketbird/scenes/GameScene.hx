package com.andreasmcdermott.rocketbird.scenes;
import com.andreasmcdermott.rocketbird.entities.Obstacle;
import com.andreasmcdermott.rocketbird.entities.Rocket;
import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.geom.Point;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import hxfw.entities.Entity;
import hxfw.entities.Group;
import hxfw.entities.TextDisplay;
import hxfw.Game;
import hxfw.Input;
import hxfw.Random;
import hxfw.scenes.Scene;
import hxfw.Timer;
import hxfw.Tween;
import openfl.Assets;

using hxfw.Tween;

/**
 * ...
 * @author Andreas McDermott
 */
class GameScene extends Scene
{
	public static var playing(default, null):Bool;
	public static var muted(default, null):Bool;
	public static var speed(default, null):Float;
	private var background:Entity;
	private var backgroundCloser:Entity;
	private var overlay:Entity;
	private var rocket:Rocket;
	private var paused:Bool = false;
	private var text:TextDisplay;
	private var score:Int = 0;
	private var highscore:Int = 0;
	private var scoreDisplay:TextDisplay;
	private var music:Sound;
	private var musicChannel:SoundChannel;
	private var obstacles:Group;
	private var title:TextDisplay;
	
	public function new() 
	{
		super();
		playing = false;
		muted = false;
		speed = 120;
	}
	
	override private function load():Void
	{
		super.load();
		
		obstacles = new Group();
		
		music = Assets.getMusic("msc/RocketBirdTheme.wav");
		musicChannel = music.play(0, 9999);
		
		title = new TextDisplay(8, 8, 200, 200, "Rocket: A Flappy Bird fan game.\nCreated for the Flappy Jam.\nBy Andreas McDermott.\nwww.andreasmcdermott.com.");
		title.setColor(0xff76428A);
		
		scoreDisplay = cast new TextDisplay(2, 2, 100, 100, Std.string(score)).setShadow(0.5, 0.5, 0xff000000).setColor(0xffffffff).setScale(2, 2);
		text = cast new TextDisplay(Game.Width / 2, Game.Height / 2 - 8, 200, 50, "UP/LMB to boost.\nP to pause.\nM to mute.").setShadow().setColor(0xffffffff);
		background = new Entity(0, 0, Game.Width, Game.Height)
			.assignDrawable(new Bitmap(Assets.getBitmapData("img/background.png"), PixelSnapping.ALWAYS));
		backgroundCloser = new Entity(0, 0, Game.Width, Game.Height)
			.assignDrawable(new Bitmap(Assets.getBitmapData("img/background-close.png"), PixelSnapping.ALWAYS));
		rocket = cast new Rocket(64, Game.Height / 2 - 8);
		overlay = new Entity(0, 0, 1, 1).assignDrawable(Main.TheBitmap).setColor(0xff000000).setScale(Game.Width, Game.Height);
		
		overlay.tween(1, { a: 0.66 } ).delay(2.5).then(function (d:Dynamic) { title = null; } );
	}
	
	override private function update()
	{
		timer.update();
		
		backgroundCloser.x -= speed * Game.Dt;
		if (backgroundCloser.x < -Game.Width)
			backgroundCloser.x += Game.Width;
			
		if ((!playing || paused) && title == null && Input.isKeyPressed(Keyboard.UP) || Input.isLeftMouseButtonPressed())
		{
			rocket.alive();
			playing = true;		
			paused = false;
			text.setText("");
		}
		else if (!paused && !rocket.isDead() && title == null && Input.isKeyPressed(Keyboard.P))
		{
			playing = false;
			paused = true;
			text.setText("Paused.");
		}
		else if (Input.isKeyPressed(Keyboard.M))
		{
			muted = !muted;
			if (muted)
			{
				musicChannel.stop();
				if(playing && !paused)
					text.setText("Sound off.");
			}
			else
			{
				music.play(musicChannel.position, 9999);
				if(playing && !paused)
					text.setText("Sound on.");
			}
			if(playing && !paused)
				timer.delay(function () { text.setText(""); }, 1);
		}
			
		rocket.update();
		
		if (rocket.isDead() && playing)
		{
			highscore = score;
			text.setText("Your score: " + score + ".\nHighscore: " + highscore + ".");
			score = 0;
			scoreDisplay.setText(Std.string(score));
			playing = false;
		}
		
		if (playing && !paused && !rocket.isDead())
		{
			obstacles.update();
			
			if (obstacles.children.length < 2)
			{
				obstacles.addChild(new Obstacle(Game.Width + Random.floatBetween(20, 60)));
				obstacles.addChild(new Obstacle(Game.Width + Game.Width / 2 + Random.floatBetween(20, 60)));
			}
			
			for (o in obstacles)
			{
				var obstacle:Obstacle = cast o;
				if (!rocket.resolveCollision(obstacle.topEntity) && !rocket.resolveCollision(obstacle.bottomEntity))
				{
					if (obstacle.passed(rocket.x) )
					{
						o.setColor(0xff4B692F);
						score += 1;
						scoreDisplay.setText(Std.string(score));
						scoreDisplay.tween(0.2, { scaleX: 3, scaleY: 3 } ).then(function (d:Dynamic) { scoreDisplay.setScale(2, 2); } );
					}
				}
			}
		}
		
		if (rocket.isDead())
		{
			obstacles.removeChildren();
		}
	}
	
	override private function draw()
	{
		background.draw();
		
		var origX:Float;
		backgroundCloser.draw();
		origX = backgroundCloser.x;
		backgroundCloser.x += Game.Width;
		backgroundCloser.draw();
		backgroundCloser.x = origX;		
		
		obstacles.draw();
		
		rocket.draw();
		scoreDisplay.draw();
		
		if (paused || !playing)
			overlay.draw();
			
		if(title != null)
			title.draw();
		else
			text.draw();
	}
}