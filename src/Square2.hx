package ;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.Assets;

/**
 * ...
 * @author lee
 */

class Square2 extends Sprite
{
	public var prog:Int;
	public var col:Int;
	public function new() 
	{
		super();
		this.mouseChildren = false;
		this.mouseEnabled = false;
	}
	
	public function show(col:Int):Void {
		var b = new Bitmap(Assets.getBitmapData('assets/bm' + col + '.png'));
		b.smoothing = true;
		b.x = -b.width / 2;
		b.y = -b.height / 2;
		addChild(b);
	}
	
}