package com.andreasmcdermott.rocketbird.entities;

import com.andreasmcdermott.rocketbird.scenes.GameScene;
import flash.display.Bitmap;
import flash.geom.Point;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.ui.Keyboard;
import hxfw.Collider;
import hxfw.Game;
import hxfw.Input;
import hxfw.particles.Emitter;
import openfl.Assets;
import flash.display.PixelSnapping;
import hxfw.entities.Entity;
import flash.media.Sound;

using hxfw.Tween;

/**
 * ...
 * @author Andreas McDermott
 */
class Rocket extends Entity
{
	var velocity:Float = 0;
	var backburner:Emitter;
	var downburner:Emitter;
	var lights:Entity;
	var lightsOffset:Float;
	var showLight:Bool;
	var downburnerSnd:Sound;
	var downburnerSndChannel:SoundChannel;
	var downburnerSndTrsfrm:SoundTransform;
	var deathSnd:Sound;
	var deathSndTrsfrm:SoundTransform;
	var dead:Bool = false;
	
	public function new(x, y) 
	{
		super(x, y, 16, 16);
		assignDrawable(new Bitmap(Assets.getBitmapData("img/rocket.png"), PixelSnapping.ALWAYS));
		
		collider = Collider.createCircleCollider(5, 1, this);
		
		downburnerSndTrsfrm = new SoundTransform(0.5);
		downburnerSnd = Assets.getSound("snd/downburner.wav");
		
		deathSndTrsfrm = new SoundTransform(0.75);
		deathSnd = Assets.getSound("snd/fail.wav");
		
		backburner = new Emitter(x - 5,  y + 5, 4, 2);
		backburner
			.setParticleCount(100, 100)
			.setColorTransition(0x99D95763, 0x00FBF236)
			.setLifeSpan(1, 2.5)
			.setRotationSpeed( -2, 2)
			.setScaleTransition(4, 1)
			.setVelocity(new Point(-8), new Point( -8, 0), new Point(-16, -1), new Point( -16, -2));
		backburner.emit(18);
		
		downburner = new Emitter(x + 4,  y + 12, 4, 1);
		downburner
			.setParticleCount(100, 100)
			.setColorTransition(0x99AC3232, 0x00D95763)
			.setLifeSpan(1, 2.5)
			.setRotationSpeed( -2, 2)
			.setScaleTransition(4, 1)
			.setVelocity(new Point(-8, 0), new Point(-8, 0), new Point( -8, 6), new Point( -8, 8));
		downburner.emit(10);
		downburner.pause();
		
		lights = new Entity(x, y, 1, 1);
		lights.assignDrawable(Main.TheBitmap).setColor(0xffAC3232);
		lightsOffset = 2;
		showLight = true;
		
		timer.repeat(function () {
			if (showLight) { showLight = false; }
			else {
				showLight = true;
				lightsOffset += 2;
				if (lightsOffset > 14)
					lightsOffset = 2;
			}
		}, 0.25);
	}
	
	override public function resolveCollision(other:Entity):Bool 
	{
		if (Collider.isColliding(collider, other.collider))
		{
			die();
			return true;
		}
		
		return false;
	}
	
	override private function update()
	{
		super.update();
				
		velocity += 12 * Game.Dt;
		
		if (GameScene.playing && !dead)
		{
			if(Input.isKeyPressed(Keyboard.UP) || Input.isLeftMouseButtonPressed())
			{
				if(!GameScene.muted)
					downburnerSnd.play(0, 0, downburnerSndTrsfrm);
				downburner.unpause();
				timer.delay(function () { downburner.pause(); }, 0.15);
				velocity = -680 * Game.Dt;
			}
			
			if (velocity > 2.4)
				velocity = 2.4;
			else if (velocity < -3.7)
				velocity = -3.7;
				
			y += velocity;
		}
				
		backburner.setPos(x - 5, y + 5);
		downburner.setPos(x + 4, y + 12);
		downburner.update();
		backburner.update();
		
		lights.x = x + lightsOffset;
		lights.y = y + 8;
		
		if (y < -(height / 2) || y > Game.Height - height / 2)
		{
			die();
		}
	}
	
	private function die()
	{
		deathSnd.play(0, 0, deathSndTrsfrm);
		dead = true;
		y = Game.Height / 2 - 8;
	}
	
	public function alive()
	{
		dead = false;
	}
	
	public function isDead():Bool
	{
		return dead;
	}
	
	override private function draw()
	{
		if (dead) return;
		super.draw();
		if(showLight)
			lights.draw();
		backburner.draw();
		downburner.draw();
	}
}