load "RingThreadPro.ring"

# Thread Pool Example with Priority and Error Handling
# This example demonstrates a thread pool processing tasks with different priorities

# Create thread manager with pool size
POOL_SIZE = 4
oThreads = new ThreadManager(POOL_SIZE)

# Enable debug mode for detailed logging
oThreads.enableDebug()

# Shared resources
taskQueue = []
taskResults = []
queueMutex = 0
resultMutex = 0
taskAvailable = 0

func main
    ? "Starting Thread Pool Example..."
    
    # Initialize synchronization objects
    queueMutex = oThreads.createMutex(1)  # Using plain mutex
    resultMutex = oThreads.createMutex(1)  # Using plain mutex
    taskAvailable = oThreads.createCondition()
    
    # Set thread names and priorities
    for i = 1 to POOL_SIZE
        oThreads.setThreadName(i, "Worker-" + i)
        oThreads.setThreadPriority(i, 5)  # Default priority
    next
    
    # Create worker threads
    for i = 1 to POOL_SIZE
        oThreads.createThread(i, "worker("+i+")")
    next
    
    # Display initial thread information
    oThreads.dumpThreadInfo()
    
    # Add some tasks to the queue
    addTask("Task-1", 3)  # Low priority
    addTask("Task-2", 7)  # High priority
    addTask("Task-3", 5)  # Medium priority
    addTask("Task-4", 8)  # High priority
    addTask("Task-5", 2)  # Low priority
    
    # Wait a bit for tasks to be processed
    for i = 1 to 5
        oThreads.yieldThread()
    next
    
    # Display results
    showResults()
    
    # Cleanup
    oThreads.destroy()
    ? "Thread pool shutdown complete!"

func worker n
    threadName = oThreads.getThreadName(n)
    priority = oThreads.getThreadPriority(n)
    ? threadName + " started with priority " + priority
    
    while true
        # Wait for task
        oThreads.lockMutex(queueMutex)
        
        while len(taskQueue) = 0
            oThreads.waitCondition(taskAvailable, queueMutex)
        end
        
        # Get highest priority task
        task = getHighestPriorityTask()
        oThreads.unlockMutex(queueMutex)
        
        if task = null
            loop
        ok
        
        # Process task
        ? threadName + " processing task: " + task[1] + " (Priority: " + task[2] + ")"
        
        # Simulate work
        for i = 1 to 3
            oThreads.yieldThread()
        next
        
        # Store result
        oThreads.lockMutex(resultMutex)
        add(taskResults, task[1] + " completed by " + threadName)
        oThreads.unlockMutex(resultMutex)
    end

func addTask taskName, priority
    oThreads.lockMutex(queueMutex)
    add(taskQueue, [taskName, priority])
    oThreads.signalCondition(taskAvailable)
    oThreads.unlockMutex(queueMutex)
    ? "Added task: " + taskName + " with priority " + priority

func getHighestPriorityTask
    if len(taskQueue) = 0 return null ok
    
    maxPriority = 0
    maxIndex = 0
    
    for i = 1 to len(taskQueue)
        if taskQueue[i][2] > maxPriority
            maxPriority = taskQueue[i][2]
            maxIndex = i
        ok
    next
    
    if maxIndex = 0 return null ok
    
    task = taskQueue[maxIndex]
    del(taskQueue, maxIndex)
    return task

func showResults
    ? ""
    ? "Task Results:"
    ? "============"
    for result in taskResults
        ? result
    next
    ? ""
