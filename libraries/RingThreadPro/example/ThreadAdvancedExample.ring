load "RingThreadPro.ring"

# Advanced Threading Example
# This example demonstrates various features of the enhanced ThreadManager

# Create thread manager with 4 threads
oThreads = new ThreadManager(4)

# Shared resources
sharedCounter = 0
mutexId = 0

# oThreads.enableDebug()

func main
    ? "Starting Advanced Threading Example..."
    
    # Create synchronization objects
    mutexId = oThreads.createRecursiveMutex()
    ? "Created recursive mutex: " + mutexId
    
    # Set thread names
    oThreads.setThreadName(1, "Counter-1")
    oThreads.setThreadName(2, "Counter-2")
    oThreads.setThreadName(3, "Counter-3")
    oThreads.setThreadName(4, "Counter-4")
    
    # Create threads
    oThreads.createThread(1, "worker(1)")
    oThreads.createThread(2, "worker(2)")
    oThreads.createThread(3, "worker(3)")
    oThreads.createThread(4, "worker(4)")
    
    # Display initial thread information
    oThreads.dumpThreadInfo()
    
    # Wait for all threads to complete
    oThreads.joinAllThreads()
    
    ? nl
    ? "Final Counter Value: " + sharedCounter
    
    # Display final thread information
    ? nl
    oThreads.dumpThreadInfo()
    
    # Cleanup
    oThreads.destroy()
    ? "All resources cleaned up!"

func worker n
    threadName = oThreads.getThreadName(n)
    ? threadName + " starting..."
    
    # Increment counter multiple times
    for i = 1 to 5
        oThreads.lockMutex(mutexId)
        temp = sharedCounter
        oThreads.yieldThread()  # Force some interleaving
        sharedCounter = temp + 1
        ? threadName + " incremented counter to: " + sharedCounter
        oThreads.unlockMutex(mutexId)
    next
    
    ? threadName + " finished!"
