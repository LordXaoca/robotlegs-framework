//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.async.support
{
	import flash.utils.setTimeout;

	import org.flexunit.async.Async;

	public class AsyncAssertHelper
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		public function get currentFrame():uint
		{
			return _frameCounter.currentFrame;
		}

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _frameCounter:FrameCounter = new FrameCounter();

		private var _testCase:Object;

		private var _assert:Function;

		private var _timeout:int;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function AsyncAssertHelper(testCase:Object, assertFunction:Function, timeout:int = 500)
		{
			_testCase = testCase;
			_assert = assertFunction;
			_timeout = timeout;
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function bindAssert(timeout:int = -1):Function
		{
			_frameCounter.start();
			timeout < 0 && (timeout = _timeout);
			const asserts:Array = [];
			const proceed:Function = Async.asyncHandler(_testCase, function(... x):void {
				for each (var assert:Function in asserts)
				{
					assert();
				}
			}, timeout);
			return function(... rest):void {
				asserts.push(function():void {
					_assert.apply(null, rest);
				});
				if (asserts.length == 1)
				{
					setTimeout(proceed, 50);
				}
			}
		}

	}
}
