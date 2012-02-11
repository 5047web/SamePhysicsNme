package ;

import nme.display.FPS;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.Lib;

/**
 * ...
 * @author lee
 */

class Main 
{
	
	static public function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new SamePhysics());
		Lib.current.addChild(new FPS(450,90));
	}
	
}