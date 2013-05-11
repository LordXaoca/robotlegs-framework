//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.async
{
	public class Deferred implements IPromise
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const pending:Array = [];

		private var onResolved:Function;

		private var onRejected:Function;

		private var processed:Boolean;

		private var completed:Boolean;

		private var completionAction:String;

		private var completionValue:*;

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
			if (onResolved != null || onRejected != null)
			{
				const deferred:Deferred = new Deferred(onResolved, onRejected);
				Tick.nextTick(schedule, [deferred]);
				return deferred;
			}
			return this;
		}

		public function onReject(onRejected:Function):IPromise
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
					// Allow handlers without arguments
					const result:* = closure.length == 0
							? closure()
							: closure(value);
					// Do not overwrite the value for Void returns
					if (result !== undefined)
						value = result;
				}
				// Softly check for a returned Promise
				value && "then" in value && value.then is Function
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
