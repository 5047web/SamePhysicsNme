package ;
import box2D.collision.B2ContactPoint;
import box2D.collision.B2Manifold;
import box2D.dynamics.B2ContactImpulse;
import box2D.dynamics.B2ContactListener;
import box2D.dynamics.contacts.B2Contact;
import nme.Lib;

/**
 * ...
 * @author lee
 */

class MyB2ContactListener extends B2ContactListener
{
	public var collz:Array<Dynamic>;
	public function new() 
	{
		super();
		collz = new Array<Dynamic>();
		clear_collisions();
	}
	
	
	override public function beginContact(contact:B2Contact):Void {
		var num1:Int;
		var num2:Int;
		if (contact.getFixtureA().getBody().getUserData() != null && contact.getFixtureB().getBody().getUserData()!=null) {
			if (contact.getFixtureA().getBody().getUserData().col == contact.getFixtureB().getBody().getUserData().col) {
				num1 = contact.getFixtureA().getBody().getUserData().prog;
				num2 = contact.getFixtureB().getBody().getUserData().prog;
				if (getIndex(collz[num1],num2)==-1) {
					collz[num1].push(num2);
				}
				if (getIndex(collz[num2],num1)==-1) {
					collz[num2].push(num1);
				}
			}
		}
	}
	
	override public function endContact(contact:B2Contact):Void 
	{
		var num1:Int;
		var num2:Int;
		var arr_index:Int;
		if (contact.getFixtureA().getBody().getUserData()!=null && contact.getFixtureB().getBody().getUserData()!=null) {
			if (contact.getFixtureA().getBody().getUserData().col==contact.getFixtureB().getBody().getUserData().col) {
				num1 = contact.getFixtureA().getBody().getUserData().prog;
				num2 = contact.getFixtureB().getBody().getUserData().prog;
				arr_index = getIndex(collz[num1], num2);
				if (arr_index!=-1) {
					collz[num1].splice(arr_index, 1);
				}
				arr_index = getIndex(collz[num2], num1);
				if (arr_index!=-1) {
					collz[num2].splice(arr_index,1);
				}
			}
		}
	}
	
	public function get_collz(el:Int):Array<Dynamic> {
		return collz[el];
	}
	public function clear_collisions() {
		for (i in 0...156) {
			collz[i] = new Array<Dynamic>();
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
	
}