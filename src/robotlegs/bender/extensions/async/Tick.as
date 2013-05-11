//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.async
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class Tick
	{

		/*============================================================================*/
		/* Private Static Properties                                                  */
		/*============================================================================*/

		private static const dispatcher:Sprite = new Sprite();

		private static var enter:Ticker;

		/*============================================================================*/
		/* Public Static Functions                                                    */
		/*============================================================================*/

		public static function nextTick(closure:Function, args:Array = null):void
		{
			enter || (enter = new Ticker(dispatcher, Event.ENTER_FRAME));
			enter.add(closure, args);
		}
	}
}

import flash.events.Event;
import flash.events.EventDispatcher;

class Ticker
{

	/*============================================================================*/
	/* Private Properties                                                         */
	/*============================================================================*/

	private const _fns:Array = [];

	private const _rgs:Array = [];

	private var _dispatcher:EventDispatcher;

	private var _eventType:String;

	/*============================================================================*/
	/* Constructor                                                                */
	/*============================================================================*/

	public function Ticker(dispatcher:EventDispatcher, eventType:String = "enterFrame")
	{
		_dispatcher = dispatcher;
		_eventType = eventType;
	}

	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/

	public function add(func:Function, args:Array = null):void
	{
		_fns.push(func);
		_rgs.push(args);
		_fns.length == 1 && _dispatcher.addEventListener(_eventType, invoke);
	}

	/*============================================================================*/
	/* Private Functions                                                          */
	/*============================================================================*/

	private function invoke(e:Event):void
	{
		const length:uint = _fns.length;
		if (length > 0)
		{
			const f:Array = _fns.splice(0);
			const a:Array = _rgs.splice(0);
			for (var i:int = 0; i < length; i++)
			{
				const func:Function = f[i] as Function;
				const args:Array = a[i] as Array;
				args && args.length > 0
					? func.apply(null, args)
					: func();
			}
		}
		else
		{
			// Only remove the listener if the queue is empty after a tick
			_dispatcher.removeEventListener(_eventType, invoke);
		}
	}
}
