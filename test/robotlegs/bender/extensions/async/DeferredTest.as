//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.async
{
	import flash.utils.setTimeout;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	import robotlegs.bender.extensions.async.support.AsyncAssertHelper;

	public class DeferredTest
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var helper:AsyncAssertHelper;

		private var subject:Deferred;

		private var sentinel:Object; // a sentinel fulfillment value to test for with strict equality

		private var dummy:Object; // we fulfill or reject with this when we don't intend to test against it

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			helper = new AsyncAssertHelper(this, assertThat);
			sentinel = {sentinel: "sentinel"};
			dummy = {dummy: "dummy"};
			subject = unfulfilled();
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		// 3.2.1: Does not apply - AS3 arguments are typed as "Function"

		// 3.2.2 ----------------------------------------------------------------------

		// 3.2.2: If `onFulfilled` is a function

		// 3.2.2.1: it must be called after `promise` is fulfilled, with `promise`’s fulfillment value as its first argument.

		[Test(async)]
		public function spec_3_2_2_1_then_fulfilled_with_fulfillment():void
		{
			const assertThat:Function = helper.bindAssert();

			subject.then(function(value:Object):void {
				assertThat(value, equalTo(sentinel));
			});

			subject.resolve(sentinel);
		}

		// 3.2.2.2: it must not be called more than once.

		// 3.2.2.2: already-fulfilled

		[Test(async)]
		public function spec_3_2_2_2_already_fulfilled():void
		{
			const assertThat:Function = helper.bindAssert();
			var timeCalled:int = 0;

			subject = fulfilled(sentinel);

			subject.then(function(value:Object):void {
				assertThat(++timeCalled, equalTo(1));
			});
		}

		// 3.2.2.2: trying to fulfill a pending promise more than once, immediately

		[Test(async)]
		public function spec_3_2_2_2_pending_fulfilled_multiple_times():void
		{
			const assertThat:Function = helper.bindAssert();
			var timeCalled:int = 0;

			subject.then(function(value:Object):void {
				assertThat(++timeCalled, equalTo(1));
			});

			subject.resolve(sentinel);
			subject.resolve(sentinel);
		}

		// 3.2.2.2: trying to fulfill a pending promise more than once, delayed

		[Test(async)]
		public function spec_3_2_2_2_pending_fulfilled_multiple_times_delayed():void
		{
			const assertThat:Function = helper.bindAssert();
			var timeCalled:int = 0;

			subject.then(function(value:Object):void {
				assertThat(++timeCalled, equalTo(1));
			});

			setTimeout(function():void {
				subject.resolve(sentinel);
				subject.resolve(sentinel);
			}, 50);
		}

		// 3.2.2.2: trying to fulfill a pending promise more than once, immediately then delayed

		[Test(async)]
		public function spec_3_2_2_2_pending_fulfilled_multiple_times_immediately_then_delayed():void
		{
			const assertThat:Function = helper.bindAssert();
			var timeCalled:int = 0;

			subject.then(function(value:Object):void {
				assertThat(++timeCalled, equalTo(1));
			});

			subject.resolve(sentinel);

			setTimeout(function():void {
				subject.resolve(sentinel);
			}, 50);
		}

		// 3.2.2.2: when multiple `then` calls are made, spaced apart in time

		[Test(async)]
		public function spec_3_2_2_2_multiple_then_calls_spaced_apart_in_time():void
		{
			const assertThat:Function = helper.bindAssert();
			var timeCalled:Array = [0, 0, 0];

			subject.then(function(value:Object):void {
				assertThat(++timeCalled[0], equalTo(1));
			});
			setTimeout(function():void {
				subject.then(function():void {
					assertThat(++timeCalled[1], equalTo(1));
				});
			}, 50);
			setTimeout(function():void {
				subject.then(function():void {
					assertThat(++timeCalled[2], equalTo(1));
				});
			}, 100);

			setTimeout(function():void {
				subject.resolve(sentinel);
			}, 150);
		}

		// 3.2.2.2: when `then` is interleaved with fulfillment

		[Test(async)]
		public function spec_3_2_2_2_then_is_interleaved_with_fulfillment():void
		{
			const assertThat:Function = helper.bindAssert();
			var timeCalled:Array = [0, 0];

			subject.then(function(value:Object):void {
				assertThat(++timeCalled[0], equalTo(1));
			});

			subject.resolve(sentinel);

			subject.then(function(value:Object):void {
				assertThat(++timeCalled[1], equalTo(1));
			});
		}

		// ( 3.2.2: If `onFulfilled` is a function )

		// 3.2.2.3: it must not be called if `onRejected` has been called.

		[Test(async)]
		public function spec_3_2_2_3_onFulfilled_not_called_if_onRejected_called():void
		{
			const assertThat:Function = helper.bindAssert();
			var onRejectedCalled:Boolean = false;

			subject = eventuallyRejected(dummy, 50);

			subject.then(function onFulfilled():void {
				assertThat(onRejectedCalled, isFalse());
			}, function onRejected():void {
				onRejectedCalled = true;
			});

			setTimeout(function():void {
				assertThat(onRejectedCalled, isTrue());
			}, 100);
		}

		// 3.2.2.3: trying to reject then immediately fulfill

		[Test(async)]
		public function spec_3_2_2_3_trying_to_reject_then_immediately_fulfill():void
		{
			const assertThat:Function = helper.bindAssert();
			var onRejectedCalled:Boolean = false;

			subject.then(function onFulfilled():void {
				assertThat(onRejectedCalled, isFalse());
			}, function onRejected():void {
				onRejectedCalled = true;
			});

			subject.reject(dummy);
			subject.resolve(dummy);

			setTimeout(function():void {
				assertThat(onRejectedCalled, isTrue());
			}, 100);
		}

		// 3.2.2.3: trying to reject then fulfill, delayed

		[Test(async)]
		public function spec_3_2_2_3_trying_to_reject_then_fulfill_delayed():void
		{
			const assertThat:Function = helper.bindAssert();
			var onRejectedCalled:Boolean = false;

			subject.then(function onFulfilled():void {
				assertThat(onRejectedCalled, isFalse());
			}, function onRejected():void {
				onRejectedCalled = true;
			});

			setTimeout(function():void {
				subject.reject(dummy);
				subject.resolve(dummy);
			}, 50);

			setTimeout(function():void {
				assertThat(onRejectedCalled, isTrue());
			}, 100);
		}

		// 3.2.2.3: trying to reject immediately then fulfill delayed

		[Test(async)]
		public function spec_3_2_2_3_trying_to_reject_immediately_then_fulfill_delayed():void
		{
			const assertThat:Function = helper.bindAssert();
			var onRejectedCalled:Boolean = false;

			subject.then(function onFulfilled():void {
				assertThat(onRejectedCalled, isFalse());
			}, function onRejected():void {
				onRejectedCalled = true;
			});

			subject.reject(dummy);

			setTimeout(function():void {
				subject.resolve(dummy);
			}, 50);

			setTimeout(function():void {
				assertThat(onRejectedCalled, isTrue());
			}, 100);
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function unfulfilled():Deferred
		{
			return new Deferred();
		}

		private function fulfilled(value:Object):Deferred
		{
			const deferred:Deferred = new Deferred();
			deferred.resolve(value);
			return deferred;
		}

		private function eventuallyRejected(reason:Object, delay:int = 50):Deferred
		{
			const deferred:Deferred = new Deferred();
			setTimeout(deferred.reject, delay, reason);
			return deferred;
		}
	}
}
