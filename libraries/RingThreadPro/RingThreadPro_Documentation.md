# RingThreadPro - Advanced Thread Management Library for Ring
=================================================

## Overview
RingThreadPro is a comprehensive thread management library for the Ring programming language. It provides robust thread synchronization primitives and a flexible threading interface for building concurrent applications.

## Core Features

1. Thread Management
------------------
- Thread Creation and Control
  * Create and manage multiple threads
  * Thread naming support
  * Thread state tracking (ready, running, completed, error, terminated)
  * Thread priorities (1-10)
  * Thread joining and yielding
  * Active thread counting

2. Synchronization Primitives
---------------------------
a) Mutex Management
   * Plain mutex creation
   * Recursive mutex support
   * Timed mutex operations
   * Lock/unlock operations
   * Trylock functionality

b) Condition Variables
   * Create and manage condition variables
   * Signal and broadcast mechanisms
   * Wait on conditions with mutex
   * Timed wait operations

c) Thread Barriers
   * Synchronization points for multiple threads
   * Barrier creation and waiting
   * Thread coordination

3. Error Handling and Debugging
-----------------------------
- Comprehensive error tracking per thread
- Debug mode for detailed logging
- Error state querying and clearing
- Thread state monitoring
- Resource statistics

4. Resource Management
--------------------
- Automatic resource cleanup
- Thread termination support
- Mutex and condition variable cleanup
- Thread pool management

## Example Programs

1. Basic Thread Example (ThreadExample.ring)
-----------------------------------------
- Basic producer-consumer pattern
- Simple thread creation and synchronization
- Mutex usage example

2. Advanced Thread Example (ThreadAdvancedExample.ring)
--------------------------------------------------
- Thread naming and state tracking
- Recursive mutex usage
- Multiple thread coordination
- Thread state monitoring

3. Thread Pool Example (ThreadPoolExample.ring)
-------------------------------------------
- Priority-based task scheduling
- Worker pool pattern implementation
- Advanced synchronization usage
- Resource management demonstration

## API Reference

1. Thread Management
------------------
* createThread(nIndex, funcName)
* joinThread(nIndex)
* joinAllThreads()
* yieldThread()
* setThreadName(nIndex, name)
* getThreadName(nIndex)
* setThreadPriority(nIndex, priority)
* getThreadPriority(nIndex)
* terminateThread(nIndex)
* restartThread(nIndex, funcName)

2. Thread State Management
------------------------
* getThreadState(nIndex)
* isThreadActive(nIndex)
* getActiveThreadCount()
* getThreadError(nIndex)
* clearThreadError(nIndex)

3. Mutex Operations
-----------------
* createMutex(nType)
* createMutexWithTimeout(nType)
* lockMutex(nIndex)
* unlockMutex(nIndex)
* tryLockMutex(nIndex)
* tryLockMutexWithTimeout(nIndex, nSeconds)

4. Condition Variables
--------------------
* createCondition()
* waitCondition(nCondition, nMutex)
* signalCondition(nCondition)
* broadcastCondition(nCondition)

5. Debug and Statistics
---------------------
* enableDebug()
* disableDebug()
* debug(cMessage)
* dumpThreadInfo()
* getResourceCounts()
* getThreadStats(nIndex)
* getAllThreadStats()

## Best Practices

1. Thread Safety
--------------
- Always protect shared resources with mutexes
- Use condition variables for thread coordination
- Implement proper error handling
- Clean up resources properly

2. Performance
------------
- Use appropriate thread priorities
- Avoid excessive thread creation
- Implement proper thread pooling
- Balance workload across threads

3. Debugging
----------
- Enable debug mode for detailed logging
- Monitor thread states regularly
- Track and handle errors properly
- Use thread naming for better tracking

4. Resource Management
-------------------
- Always call destroy() when done
- Clean up mutexes and condition variables
- Properly terminate threads
- Monitor resource usage

## Common Patterns

1. Producer-Consumer
-----------------
- Use mutex for queue protection
- Use condition variables for signaling
- Implement proper queue management
- Handle multiple producers/consumers

2. Thread Pool
------------
- Implement priority-based scheduling
- Use worker threads efficiently
- Manage task queue properly
- Handle thread termination

3. Barrier Synchronization
------------------------
- Coordinate multiple threads
- Implement proper barrier waiting
- Handle timeout cases
- Clean up resources

## Error Handling

1. Thread Errors
--------------
- Track per-thread errors
- Implement error recovery
- Log error conditions
- Clean up on errors

2. Mutex Errors
-------------
- Handle lock failures
- Implement timeout handling
- Avoid deadlocks
- Clean up properly

3. Condition Variable Errors
-------------------------
- Handle wait timeouts
- Manage spurious wakeups
- Handle signal failures
- Clean up on errors

## Version Information
--------------------
- Version: 1.2
- Author: Azzeddine Remmal
- License: Open Source
- Dependencies: Ring Standard Library

