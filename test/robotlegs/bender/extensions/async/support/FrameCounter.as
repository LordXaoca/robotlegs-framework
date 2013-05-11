//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.async.support
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class FrameCounter
	{

		/*============================================================================*/
		/* Private Static Properties                                                  */
		/*============================================================================*/

		private static const emitter:Sprite = new Sprite();

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		private var _currentFrame:uint;

		public function get currentFrame():uint
		{
			return _currentFrame;
		}

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var running:Boolean;

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function start():FrameCounter
		{
			running || emitter.addEventListener(Event.ENTER_FRAME, tick, false, 0, true);
			return this;
		}

		public function stop():FrameCounter
		{
			running && emitter.removeEventListener(Event.ENTER_FRAME, tick);
			return this;
		}

		public function reset():FrameCounter
		{
			_currentFrame = 0;
			return this;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function tick(event:Event):void
		{
			_currentFrame++;
		}
	}
}
