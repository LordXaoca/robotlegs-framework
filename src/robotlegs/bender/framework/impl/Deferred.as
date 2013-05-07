//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.framework.impl
{
	import robotlegs.bender.framework.api.IPromise;

	public class Deferred implements IPromise
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const pending:Array = [];

		private var processed:Boolean;

		private var completed:Boolean;

		private var completionAction:String;

		private var completionValue:*;

		private var onResolved:Function;

		private var onRejected:Function;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function Deferred(onResolved:Function = null, onRejected:Function = null)
		{
			this.onResolved = onResolved;
			this.onRejected = onRejected || explode;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function then(onResolved:Function = null, onRejected:Function = null):IPromise
		{
			if (onResolved as Boolean || onRejected as Boolean)
			{
				const deferred:Deferred = new Deferred(onResolved, onRejected);
				NextTick.call(schedule, [deferred]);
				return deferred;
			}
			return this;
		}

		public function fail(onRejected:Function):IPromise
		{
			return then(null, onRejected);
		}

		public function resolve(result:* = null):void
		{
			processed || process(onResolved, result);
		}

		public function reject(error:* = null):void
		{
			processed || process(onRejected, error);
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function schedule(deferred:Deferred):void
		{
			pending.push(deferred);
			completed && propagate();
		}

		private function propagate():void
		{
			for each (var deferred:Deferred in pending.splice(0))
				deferred[completionAction](completionValue);
		}

		private function process(closure:Function, value:*):void
		{
			processed = true;
			try
			{
				if (closure)
				{
					if (closure.length == 1)
					{
						const result:* = closure(value);
						if (result !== undefined)
							value = result;
					}
					else
					{
						closure();
					}
				}
				value && "then" in value
					? value.then(completeResolved, completeRejected)
					: completeResolved(value);
			}
			catch (error:*)
			{
				completeRejected(error);
			}
		}

		private function completeResolved(result:*):void
		{
			complete('resolve', result);
		}

		private function completeRejected(error:*):void
		{
			complete('reject', error);
		}

		private function complete(action:String, value:*):void
		{
			completed = true;
			completionAction = action;
			completionValue = value;
			onResolved = null;
			onRejected = null;
			propagate();
		}

		private function explode(error:*):void
		{
			throw error;
		}
	}
}

import flash.display.Sprite;
import flash.events.Event;

class NextTick
{

	/*============================================================================*/
	/* Private Static Properties                                                  */
	/*============================================================================*/

	private static const SPR:Sprite = new Sprite();

	private static const Q:Array = [];

	/*============================================================================*/
	/* Public Static Functions                                                    */
	/*============================================================================*/

	public static function call(closure:Function, args:Array = null):void
	{
		Q.push(new Scope(closure, args));
		Q.length == 1 && SPR.addEventListener(Event.ENTER_FRAME, run);
	}

	/*============================================================================*/
	/* Private Static Functions                                                   */
	/*============================================================================*/

	private static function run(e:Event):void
	{
		if (Q.length == 0)
		{
			SPR.removeEventListener(Event.ENTER_FRAME, run);
		}
		else
		{
			for each (var scope:Scope in Q.splice(0))
				scope.execute();
		}
	}
}

class Scope
{

	/*============================================================================*/
	/* Private Properties                                                         */
	/*============================================================================*/

	private var _closure:Function;

	private var _args:Array;

	/*============================================================================*/
	/* Constructor                                                                */
	/*============================================================================*/

	public function Scope(closure:Function, args:Array)
	{
		_closure = closure;
		_args = args;
	}

	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/

	public function execute():void
	{
		_args ? _closure.apply(null, _args) : _closure();
	}
}
