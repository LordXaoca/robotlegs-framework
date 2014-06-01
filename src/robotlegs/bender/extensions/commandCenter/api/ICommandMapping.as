//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.commandCenter.api
{
	/**
	 * @private
	 */
	public interface ICommandMapping
	{
		/**
		 * The concrete Command Class for this mapping
		 */
		function get commandClass():Class;

		/**
		 * The "execute" method to invoke on the Command instance
		 */
		function get executeMethod():String;

		/**
		 * A list of Guards to query before execution
		 */
		function get guards():Array;

		/**
		 * A list of Hooks to run during execution
		 */
		function get hooks():Array;

		/**
		 * Unmaps a Command after a successful execution
		 */
		function get fireOnce():Boolean;

		/**
		 * Command "group" identifier.
		 *
		 * @see robotlegs.bender.extensions.commandCenter.dsl.ICommandConfigurator#toGroup()
		 * @see robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap#unmapGroup()
		 */
		function get groupName() : String;

		/**
		 * Supply the payload values via instance injection
		 */
		function get payloadInjectionEnabled():Boolean;

		/**
		 * The "execute" method to invoke on the Command instance
		 */
		function setExecuteMethod(name:String):ICommandMapping;

		/**
		 * A list of Guards to query before execution
		 */
		function addGuards(... guards):ICommandMapping;

		/**
		 * A list of Hooks to run during execution
		 */
		function addHooks(... hooks):ICommandMapping;

		/**
		 * Unmaps a Command after a successful execution
		 */
		function setFireOnce(value:Boolean):ICommandMapping;

		/**
		 * Supply the payload values via instance injection
		 */
		function setPayloadInjectionEnabled(value:Boolean):ICommandMapping;

		/**
		 * Setup specific command's identifier, further we can unmap all commands with the same groupName
		 * @param name
		 * @return Self
		 *
		 * @see robotlegs.bender.extensions.commandCenter.dsl.ICommandConfigurator#toGroup()
		 * @see robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap#unmapGroup()
		 */
		function setGroup(name : String) : void;
	}
}
