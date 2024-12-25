load "RingThreadPro.ring"

# Producer-Consumer Example using ThreadManager
# This example demonstrates thread synchronization using mutex and condition variables

# Shared data and synchronization objects
sharedQueue = []
MAX_ITEMS = 5
oThreads = new ThreadManager(2)
mutexId = 0
condId = 0

func main
    ? "Starting producer-consumer example..."
    
    # Create a mutex for synchronization
    mutexId = oThreads.createMutex(1)  # Using 1 for mtx_plain
    ? "Mutex created: " + mutexId
    
    # Create a condition variable
    condId = oThreads.createCondition()
    ? "Condition variable created: " + condId
    
    # Create producer and consumer threads
    ? "Creating threads..."
    oThreads.createThread(1, "producer()")
    oThreads.createThread(2, "consumer()")
    
    # Wait for threads to complete
    ? "Waiting for threads to complete..."
    oThreads.joinAllThreads()
    
    # Cleanup
    oThreads.destroy()
    ? "All resources cleaned up!"

func producer
    for i = 1 to 10
        oThreads.lockMutex(mutexId)
        ? "Producer: acquired lock"
        
        while len(sharedQueue) >= MAX_ITEMS
            ? "Producer: queue full, waiting..."
            oThreads.waitCondition(condId, mutexId)
        end
        
        add(sharedQueue, i)
        ? "Produced: " + i
        
        oThreads.signalCondition(condId)
        oThreads.unlockMutex(mutexId)
        ? "Producer: released lock"
    next

func consumer
    while true
        oThreads.lockMutex(mutexId)
        ? "Consumer: acquired lock"
        
        while len(sharedQueue) = 0
            ? "Consumer: queue empty, waiting..."
            oThreads.waitCondition(condId, mutexId)
        end
        
        item = sharedQueue[1]
        del(sharedQueue, 1)
        ? "Consumed: " + item
        
        oThreads.signalCondition(condId)
        oThreads.unlockMutex(mutexId)
        ? "Consumer: released lock"
        
        if item = 10 return ok
    end
