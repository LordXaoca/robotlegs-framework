//------------------------------------------------------------------------------
//  Copyright (c) 2012 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.framework.impl
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;

	public class InvalidatorTest
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const EVENT_TYPE:String = "tick";

		private var invalidator:Invalidator;

		private var dispatcher:EventDispatcher;

		private var counter:int;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			counter = 0;
			invalidator = null;
			dispatcher = new EventDispatcher();
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function commit_is_called_after_tick_when_invalidated():void
		{
			createInvalidator(incrementCounter);
			invalidate();
			tick();
			assertThat(counter, equalTo(1));
		}

		[Test]
		public function commit_is_not_called_until_tick():void
		{
			createInvalidator(incrementCounter);
			invalidate();
			assertThat(counter, equalTo(0));
		}

		[Test]
		public function commit_is_called_once_per_tick():void
		{
			createInvalidator(incrementCounter);
			invalidate();
			tick();
			tick();
			assertThat(counter, equalTo(1));
		}

		[Test]
		public function commit_is_called_once_per_invalidation():void
		{
			createInvalidator(incrementCounter);
			invalidate();
			invalidate();
			tick();
			assertThat(counter, equalTo(1));
		}

		[Test]
		public function commit_is_called_for_each_invalidation():void
		{
			createInvalidator(incrementCounter);
			invalidate();
			tick();
			invalidate();
			tick();
			assertThat(counter, equalTo(2));
		}

		[Test]
		public function optimisation___handler_is_only_added_once_between_ticks():void
		{
			dispatcher = new CallbackDispatcher().whenAddingListener(incrementCounter);
			createInvalidator(nop);
			invalidate();
			invalidate();
			assertThat(counter, equalTo(1));
		}

		[Test]
		public function optimisation___handler_is_NOT_removed_until_a_non_invalidated_tick_has_passed():void
		{
			dispatcher = new CallbackDispatcher().whenRemovingListener(incrementCounter);
			createInvalidator(nop);
			invalidate();
			tick();
			invalidate();
			tick();
			assertThat(counter, equalTo(0));
		}

		[Test]
		public function optimisation___handler_IS_removed_after_a_non_invalidated_tick_has_passed():void
		{
			dispatcher = new CallbackDispatcher().whenRemovingListener(incrementCounter);
			createInvalidator(nop);
			invalidate();
			tick();
			tick();
			assertThat(counter, equalTo(1));
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function createInvalidator(commitFunction:Function):void
		{
			invalidator = new Invalidator(commitFunction, dispatcher, EVENT_TYPE);
		}

		private function invalidate():void
		{
			invalidator.invalidate();
		}

		private function tick():void
		{
			dispatcher.dispatchEvent(new Event(EVENT_TYPE));
		}

		private function incrementCounter():void
		{
			counter++;
		}

		private function nop():void
		{
		}
	}
}

import flash.events.EventDispatcher;

class CallbackDispatcher extends EventDispatcher
{

	/*============================================================================*/
	/* Private Properties                                                         */
	/*============================================================================*/

	private var _addEventListenerCallback:Function;

	private var _removeEventListenerCallback:Function;

	/*============================================================================*/
	/* Public Functions                                                           */
	/*============================================================================*/

	public function whenAddingListener(callback:Function):CallbackDispatcher
	{
		_addEventListenerCallback = callback;
		return this;
	}

	public function whenRemovingListener(callback:Function):CallbackDispatcher
	{
		_removeEventListenerCallback = callback;
		return this;
	}

	override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
	{
		_addEventListenerCallback && _addEventListenerCallback();
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	{
		_removeEventListenerCallback && _removeEventListenerCallback();
		super.removeEventListener(type, listener, useCapture);
	}
}
