//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.async
{
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import robotlegs.bender.extensions.async.support.AsyncAssertHelper;

	public class TickTest
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var helper:AsyncAssertHelper;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			helper = new AsyncAssertHelper(this, assertThat);
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test(async)]
		public function nextTick_runs_after_one_frame():void
		{
			const assertThat:Function = helper.bindAssert();
			Tick.nextTick(function():void {
				assertThat(helper.currentFrame, equalTo(1));
			});
		}

		[Test(async)]
		public function nextTick_handles_arguments():void
		{
			const assertThat:Function = helper.bindAssert();
			Tick.nextTick(function(name:String, age:Number):void {
				assertThat([name, age], array("VALUE", 50));
			}, ["VALUE", 50]);
		}

		[Test(async)]
		public function nextTick_runs_in_order():void
		{
			const assertThat:Function = helper.bindAssert();
			const results:Array = [];
			function pushResult(val:Object):void {
				results.push(val);
			}
			Tick.nextTick(pushResult, [1]);
			Tick.nextTick(pushResult, ["two"]);
			Tick.nextTick(pushResult, ["3"]);
			Tick.nextTick(function():void {
				assertThat(results, array(1, "two", "3"));
			});
		}

		[Test(async)]
		public function nested_nextTick_spans_frames():void
		{
			const assertThat:Function = helper.bindAssert();
			Tick.nextTick(function():void {
				Tick.nextTick(function():void {
					Tick.nextTick(function():void {
						Tick.nextTick(function():void {
							Tick.nextTick(function():void {
								assertThat(helper.currentFrame, equalTo(5));
							});
						});
					});
				});
			});
		}
	}
}
