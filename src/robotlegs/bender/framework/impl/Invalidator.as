//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.framework.impl
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class Invalidator
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var commit:Function;

		private var ticker:IEventDispatcher;

		private var trigger:String;

		private var listening:Boolean;

		private var invalidating:Boolean;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function Invalidator(
			commitFunction:Function,
			dispatcher:IEventDispatcher = null,
			eventType:String = "")
		{
			commit = commitFunction;
			ticker = dispatcher || new Sprite();
			trigger = eventType || Event.EXIT_FRAME;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function invalidate():void
		{
			invalidating = true;
			if (!listening)
			{
				listening = true;
				ticker.addEventListener(trigger, onTick, false, 0, true);
			}
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function onTick(event:Event):void
		{
			// There is an optimization here that leaves the listener attached
			// for one extra tick.

			// This reduces the overhead of constantly attaching and removing
			// the listener when invalidation occurs between ticks.

			if (invalidating)
			{
				invalidating = false;
				commit();
			}
			else
			{
				listening = false;
				ticker.removeEventListener(trigger, onTick);
			}
		}
	}
}
