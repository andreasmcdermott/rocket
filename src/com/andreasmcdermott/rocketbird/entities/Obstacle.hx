package com.andreasmcdermott.rocketbird.entities;

import com.andreasmcdermott.rocketbird.scenes.GameScene;
import hxfw.Collider;
import hxfw.entities.Entity;
import hxfw.Game;
import hxfw.Random;

/**
 * ...
 * @author Andreas McDermott
 */
class Obstacle extends Entity
{
	public var topEntity:Entity;
	public var bottomEntity:Entity;
	private var isPassed:Bool;
	public function new(x:Float) 
	{
		super(x, 0, 20, Game.Height);
		
		isPassed = false;
		
		var gapStart = Random.floatBetween(20, 50);
		var gapEnd = Random.floatBetween(gapStart + 40, 100);
		topEntity = new Entity(x, 0, 1, 1).assignDrawable(Main.TheBitmap).setScale(width, gapStart).setColor(0xff8A6F30);
		topEntity.collider = Collider.createBoxCollider(0, 0, 0, topEntity);
		bottomEntity = new Entity(x, gapEnd, 1, 1).assignDrawable(Main.TheBitmap).setScale(width, Game.Height - gapEnd).setColor(0xff8A6F30);
		bottomEntity.collider = Collider.createBoxCollider(0, 0, 0, bottomEntity);
	}
	
	override public function setColor(color:UInt):Entity 
	{
		super.setColor(color);
		topEntity.setColor(color);
		bottomEntity.setColor(color);
		return this;
	}
	
	public function passed(rx:Float):Bool
	{
		if (isPassed)
			return false;
			
		var justPassedIt = x + width < rx;
		isPassed = justPassedIt;
		
		return justPassedIt;
	}
	
	override private function update()
	{
		super.update();
		
		x -= GameScene.speed * Game.Dt;
		
		topEntity.x = x;
		bottomEntity.x = x;
		
		if (x < -width)
			parent.removeChild(this);
	}
	
	override private function draw()
	{
		super.draw();
		
		topEntity.draw();
		bottomEntity.draw();
	}
}