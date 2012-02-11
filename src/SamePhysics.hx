package ;
import box2D.collision.B2AABB;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2ContactListener;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.dynamics.joints.B2MouseJoint;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Graphics;
import nme.Lib;
import nme.utils.Timer;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.TimerEvent;

/**
 * ...
 * @author lee
 */

class SamePhysics extends Sprite
{
	private var body:B2Body;
	private var mouseJoint:B2MouseJoint;
	private var m_world:B2World;
	private var m_iterations:Int ;
	private var m_timeStep:Float;
	private var contact_listener:MyB2ContactListener;
	private var blocks_to_remove:Array<Int>;
	private var blocks_on_stage:Array<Int> ;
	private var remove_the_blocks:Bool ;
	private var number_of_shakes:Int ;
	private var progressive:Int;
	private var level:Int ;
	private var time_left:Int ;
	private var game_over:Bool ;
	private var jolly:Int ;
	public var shake_the_screen:Bool ;
	
	private var mousePVec:B2Vec2;
	
	public function new() 
	{
		super();
		construct();
		init();
	}
	
	private function construct():Void {
		m_iterations= 10;
		m_timeStep = 1.0 / 30.0;
		contact_listener = new MyB2ContactListener();
		blocks_to_remove = new Array<Int>();
		blocks_on_stage = new Array<Int>();
		remove_the_blocks = false;
		number_of_shakes = 10;
		progressive = 0;
		level = 1;
		time_left = 20;
		game_over = false;
		jolly = 10;
		shake_the_screen = false;
		mousePVec = new B2Vec2();
	}
	private function init():Void {
		addChild(new Bitmap(Assets.getBitmapData('assets/bg.png')));
		
		var physicsDebug = new Sprite();
		addChild(physicsDebug);
		var debugDraw = new B2DebugDraw();
		debugDraw.setSprite(physicsDebug);
		debugDraw.setDrawScale(30);
		debugDraw.setFlags(B2DebugDraw.e_shapeBit);
		
		var worldAABB:B2AABB = new B2AABB();
		worldAABB.lowerBound.set( -100, -100);
		worldAABB.upperBound.set(100, 100);
		var gravity:B2Vec2 = new B2Vec2(0, 10);
		var doSleep:Bool = true;
		m_world = new B2World( gravity, doSleep);
		m_world.setContactListener(contact_listener);
		
		m_world.setDebugDraw(debugDraw);
		
		create_box(9,13,9,0.5,0);
		create_box(9,0,9,0.5,0);
		create_box(0,9,0.5,9,0);
		create_box(14, 9, 0.5, 9, 0);
		
		create_level(1);
		
		addEventListener(Event.ENTER_FRAME, on_enter_frame, false, 0, true);
		addEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
		
		var shakebutton:Sprite = new Sprite();
		shakebutton.graphics.beginFill(0x55555,0.3);
		shakebutton.graphics.drawRect(0,0,100,30);
		shakebutton.graphics.endFill();
		shakebutton.x=450;
		shakebutton.y=330;
		
		addChild(shakebutton);
		shakebutton.addEventListener(MouseEvent.CLICK, on_shake_clicked);
	}
	
	public function create_box(x_pos, y_pos, x_side, y_side, density):Void {
		var bodyDef:B2BodyDef;
		var box:B2PolygonShape;
		
		bodyDef = new B2BodyDef();
		bodyDef.position.set(x_pos, y_pos);
		
		box = new B2PolygonShape();
		box.setAsBox(x_side, y_side);
		
		
		var boxDef:B2FixtureDef = new B2FixtureDef();
		boxDef.friction = 0.3;
		boxDef.density = density;
		boxDef.shape = box;
		
		
		body = m_world.createBody(bodyDef);
		body.createFixture(boxDef);
		
	}
	
	public function create_level(l):Void {
		contact_listener.clear_collisions();
		blocks_on_stage = new Array();
		blocks_to_remove = new Array();
		var random_color:Int;
		var bodyDef:B2BodyDef;
		
		var box:B2PolygonShape;
		var boxDef:B2FixtureDef;
		for (j in 0...13) {
			for (i in 0...12) {
				random_color = Math.floor(Math.random() * (level + 3)) + 1;
				if (random_color>8) {
					random_color = Math.floor(Math.random() * 8) + 1;
				}
				bodyDef = new B2BodyDef();
				bodyDef.position.set(j + 1, i + 1);
				bodyDef.type = B2Body.b2_dynamicBody;
				
				box = new B2PolygonShape();
				box.setAsBox(0.5, 0.5);
				
				boxDef = new B2FixtureDef();
				boxDef.shape = box;
				boxDef.friction = 1;
				boxDef.density = 0.5;
				boxDef.restitution = 0;
				bodyDef.userData = new Square2();
				bodyDef.userData.prog = progressive;
				bodyDef.userData.col = random_color;
				body = m_world.createBody(bodyDef);
				
				body.createFixture(boxDef);
				addChild(bodyDef.userData);
				bodyDef.userData.show(random_color);
				blocks_on_stage.push(progressive);
				progressive++;
			}
		}
	}
	
	public function on_enter_frame(e:Event):Void {
		if (progressive==0) {
			level++;
			jolly += 5;
			number_of_shakes += 5;
			create_level(level);
		}
		var current_object:Int;
		var object_position:Int;
		var object:Int;
		var block_under_mouse:Int = -1;
		var temp:Int;
		var body:B2Body = GetBodyAtMouse();
		if (body != null) {
			object = body.getUserData().prog;
			get_rec_blocks(object);
		}
		temp = blocks_to_remove.length;
		if (remove_the_blocks) {
			if (temp==1) {
				if (jolly>0) {
					progressive--;
					jolly--;
					time_left = 20;
				}else {
					blocks_to_remove = new Array();
				}
			}else {
				if (temp>1) {
					progressive-= temp;
					time_left = 20;
				}
			}
		}
		m_world.step(m_timeStep, m_iterations, m_iterations);
		m_world.clearForces();
		m_world.drawDebugData();
		var bb:B2Body = m_world.m_bodyList;
		while (true) {
			if (bb.getUserData()==null) {
				break;
			}
			if (Std.is(bb.getUserData(), Sprite)) {
				
				current_object = bb.getUserData().prog;
				object_position = getIndex(blocks_to_remove, current_object);
				if (object_position!=-1 && remove_the_blocks) {
					blocks_to_remove.splice(object_position, 1);
					blocks_on_stage.splice(getIndex(blocks_on_stage,bb.getUserData().prog), 1);
					removeChild(bb.getUserData());
					bb.setUserData(null);
					m_world.destroyBody(bb);
				}else {
					if (object_position!=-1) {
						bb.getUserData().alpha = 0.5;
						blocks_to_remove.splice(object_position, 1);
					}else {
						if (shake_the_screen) {
							bb.applyImpulse(new B2Vec2(Math.random() * 10 - 5, -5), bb.getWorldCenter());
							bb.applyTorque(Math.random() * 100 - 50);
						}
						bb.getUserData().alpha = 1;
					}
					bb.getUserData().x = bb.getPosition().x * 30;
					bb.getUserData().y = bb.getPosition().y * 30;
					bb.getUserData().rotation = bb.getAngle() * (180/Math.PI);	
				}
			}
			bb = bb.m_next;
		}
		remove_the_blocks = false;
		shake_the_screen = false;
	}
	
	
	public function GetBodyAtMouse(incldeStatic:Bool=false):B2Body {
		var mouseXWorldPhys = mouseX / 30;
		var mouseYWorldPhys = mouseY / 30;
		mousePVec.set(mouseXWorldPhys, mouseYWorldPhys);

		var body:B2Body = null;
		
		m_world.queryPoint(function (f:B2Fixture):Bool {
				var b:B2Body = f.getBody();
				if (b.getType()!=B2Body.b2_staticBody || incldeStatic) {
					body = b;
					return false;
				}
				return true;
		},mousePVec);
		return body;
	}
	
	public function get_rec_blocks(block:Int):Void {
		var temp:Int;
		var temp_array:Array<Dynamic>;
		temp = getIndex(blocks_to_remove, block);
		if (temp==-1 && getIndex(blocks_on_stage,block)!=-1) {
			blocks_to_remove.push(block);
			temp_array = contact_listener.get_collz(block);
			temp = temp_array.length;
			for (i in 0...temp) {
				get_rec_blocks(temp_array[i]);
			}
		}
	}
	
	private function getIndex(arr:Array<Dynamic>,tar:Dynamic):Int {
		for (i in 0...arr.length) {
			if (arr[i]==tar) {
				return i;
			}
		}
		return -1;
	}
	
	public function on_mouse_down(evt:MouseEvent):Void {
		remove_the_blocks = true;
	}
	
	public function on_shake_clicked(evt:MouseEvent):Void {
		
		if (number_of_shakes > 0) {
			shake_the_screen = true;
			number_of_shakes--;
		}
	}
	
	
	
}