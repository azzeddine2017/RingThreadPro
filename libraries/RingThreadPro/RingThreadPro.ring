load "threads.ring"

# Thread Management Constants
class ThreadConstants
    # Version Information
    TINYCTHREAD_VERSION_MAJOR = 1
    TINYCTHREAD_VERSION_MINOR = 2
    TINYCTHREAD_VERSION = "1.2"
    
    # Thread Status Constants
    thrd_error   = 0
    thrd_success = 1
    thrd_timedout = 2
    thrd_busy    = 3
    thrd_nomem   = 4
    
    # Mutex Types
    mtx_plain    = 1
    mtx_timed    = 2
    mtx_recursive = 4
    
    # Thread States
    THREAD_READY = "ready"
    THREAD_RUNNING = "running"
    THREAD_COMPLETED = "completed"
    THREAD_ERROR = "error"
    THREAD_TERMINATED = "terminated"

class ThreadManager from ThreadConstants
    threads = []
    mutexes = []
    conditions = []
    threadStates = []    # Track thread states
    threadNames = []     # Store thread names
    threadPriorities = [] # Store thread priorities (1-10)
    threadErrors = []    # Store thread error messages
    activeThreads = 0    # Count of active threads
    debugMode = false    # Debug mode flag
    
    func init nThreads
        if nThreads > 0
            threads = list(nThreads)
            threadStates = list(nThreads)
            threadNames = list(nThreads)
            threadPriorities = list(nThreads)
            threadErrors = list(nThreads)
            for i = 1 to nThreads
                threadStates[i] = THREAD_READY
                threadNames[i] = "Thread-" + i
                threadPriorities[i] = 5  # Default priority
                threadErrors[i] = ""
            next
        ok
    
    # Debug Mode
    func enableDebug
        debugMode = true
    
    func disableDebug
        debugMode = false
    
    func debug cMessage
        if debugMode
            ? "DEBUG: " + cMessage
        ok
    
    # Enhanced Thread Creation
    func createThread nIndex, funcName
        if nIndex > 0 and nIndex <= len(threads)
            try
                threads[nIndex] = new_thrd_t()
                threadStates[nIndex] = THREAD_RUNNING
                activeThreads++
                debug("Creating thread " + threadNames[nIndex])
                return thrd_create(threads[nIndex], funcName)
            catch
                threadStates[nIndex] = THREAD_ERROR
                threadErrors[nIndex] = cCatchError
                debug("Error creating thread: " + cCatchError)
                return thrd_error
            done
        ok
        return thrd_error
    
    # Thread Priority Management
    func setThreadPriority nIndex, nPriority
        if nIndex > 0 and nIndex <= len(threads) and 
           nPriority >= 1 and nPriority <= 10
            threadPriorities[nIndex] = nPriority
            return true
        ok
        return false
    
    func getThreadPriority nIndex
        if nIndex > 0 and nIndex <= len(threads)
            return threadPriorities[nIndex]
        ok
        return 0
    
    # Thread Error Handling
    func getThreadError nIndex
        if nIndex > 0 and nIndex <= len(threads)
            return threadErrors[nIndex]
        ok
        return ""
    
    func clearThreadError nIndex
        if nIndex > 0 and nIndex <= len(threads)
            threadErrors[nIndex] = ""
            return true
        ok
        return false
    
    # Enhanced Thread Control
    func terminateThread nIndex
        if nIndex > 0 and nIndex <= len(threads)
            if threadStates[nIndex] = THREAD_RUNNING
                debug("Terminating thread " + threadNames[nIndex])
                threadStates[nIndex] = THREAD_TERMINATED
                activeThreads--
                return true
            ok
        ok
        return false
    
    func restartThread nIndex, funcName
        if nIndex > 0 and nIndex <= len(threads)
            if threadStates[nIndex] != THREAD_RUNNING
                debug("Restarting thread " + threadNames[nIndex])
                return createThread(nIndex, funcName)
            ok
        ok
        return thrd_error
    
    # Enhanced Mutex Management
    func createMutexWithTimeout nType
        mtx = new_mtx_t()
        if mtx_init(mtx, nType | mtx_timed) = thrd_success
            add(mutexes, mtx)
            return len(mutexes)
        ok
        return 0
    
    func tryLockMutexWithTimeout nIndex, nSeconds
        if nIndex > 0 and nIndex <= len(mutexes)
            ts = new_timespec()
            ts.tv_sec = nSeconds
            ts.tv_nsec = 0
            return mtx_timedlock(mutexes[nIndex], ts)
        ok
        return thrd_error
    
    # Enhanced Thread Synchronization
    func createBarrier nThreads
        if nThreads <= 0 return 0 ok
        
        mutexId = createMutex(mtx_plain)
        condId = createCondition()
        
        return [mutexId, condId, nThreads]
    
    func waitAtBarrier barrier
        if !isList(barrier) or len(barrier) != 3 return false ok
        
        mutexId = barrier[1]
        condId = barrier[2]
        threadCount = barrier[3]
        
        lockMutex(mutexId)
        threadCount--
        
        if threadCount = 0
            broadcastCondition(condId)
        else
            while threadCount > 0
                waitCondition(condId, mutexId)
            end
        ok
        
        unlockMutex(mutexId)
        return true
    
    # Thread Statistics
    func getThreadStats nIndex
        if nIndex > 0 and nIndex <= len(threads)
            return new ThreadStats {
                name = threadNames[nIndex]
                state = threadStates[nIndex]
                priority = threadPriorities[nIndex]
                error = threadErrors[nIndex]
            }
        ok
        return null
    
    func getAllThreadStats
        aStats = []
        for i = 1 to len(threads)
            add(aStats, getThreadStats(i))
        next
        return aStats
    
    # Resource Management
    func getResourceCounts
        return [
            :threads = len(threads),
            :active = activeThreads,
            :mutexes = len(mutexes),
            :conditions = len(conditions)
        ]
    
    # Enhanced Thread Information
    func dumpThreadInfo
        ? "Thread Manager Status:"
        ? "===================="
        ? "Total Threads: " + len(threads)
        ? "Active Threads: " + activeThreads
        ? "Total Mutexes: " + len(mutexes)
        ? "Total Conditions: " + len(conditions)
        ? ""
        ? "Thread Details:"
        for i = 1 to len(threads)
            ? "Thread " + i + ":"
            ? "  Name: " + threadNames[i]
            ? "  State: " + threadStates[i]
            ? "  Priority: " + threadPriorities[i]
            if threadErrors[i] != ""
                ? "  Error: " + threadErrors[i]
            ok
            ? ""
        next
    
    # Thread State Management
    func getThreadState nIndex
        if nIndex > 0 and nIndex <= len(threads)
            return threadStates[nIndex]
        ok
        return "invalid"
    
    func getThreadName nIndex
        if nIndex > 0 and nIndex <= len(threads)
            return threadNames[nIndex]
        ok
        return ""
    
    func setThreadName nIndex, name
        if nIndex > 0 and nIndex <= len(threads)
            threadNames[nIndex] = name
            return true
        ok
        return false
    
    func getActiveThreadCount
        return activeThreads
    
    func isThreadActive nIndex
        if nIndex > 0 and nIndex <= len(threads)
            return threadStates[nIndex] = THREAD_RUNNING
        ok
        return false
    
    
    # Mutex Management
    func createMutex nType
        mtx = new_mtx_t()
        if mtx_init(mtx, nType) = thrd_success
            add(mutexes, mtx)
            return len(mutexes)
        ok
        return 0
    
    func createRecursiveMutex
        return createMutex(mtx_recursive)
    
    func lockMutex nIndex
        if nIndex > 0 and nIndex <= len(mutexes)
            return mtx_lock(mutexes[nIndex])
        ok
        return thrd_error
    
    func unlockMutex nIndex
        if nIndex > 0 and nIndex <= len(mutexes)
            return mtx_unlock(mutexes[nIndex])
        ok
        return thrd_error
    
    func tryLockMutex nIndex
        if nIndex > 0 and nIndex <= len(mutexes)
            return mtx_trylock(mutexes[nIndex])
        ok
        return thrd_error
    
    # Condition Variable Management
    func createCondition
        cond = new_cnd_t()
        if cnd_init(cond) = thrd_success
            add(conditions, cond)
            return len(conditions)
        ok
        return 0
    
    func signalCondition nIndex
        if nIndex > 0 and nIndex <= len(conditions)
            return cnd_signal(conditions[nIndex])
        ok
        return thrd_error
    
    func broadcastCondition nIndex
        if nIndex > 0 and nIndex <= len(conditions)
            return cnd_broadcast(conditions[nIndex])
        ok
        return thrd_error
    
    func waitCondition nCondIndex, nMutexIndex
        if nCondIndex > 0 and nCondIndex <= len(conditions) and
           nMutexIndex > 0 and nMutexIndex <= len(mutexes)
            return cnd_wait(conditions[nCondIndex], mutexes[nMutexIndex])
        ok
        return thrd_error
    
    # Thread Control
    func joinThread nIndex
        if nIndex > 0 and nIndex <= len(threads)
            res = 0
            if thrd_join(threads[nIndex], :res) = thrd_success
                threadStates[nIndex] = THREAD_COMPLETED
                activeThreads--
                return res
            ok
        ok
        return thrd_error
    
    func joinAllThreads
        for i = 1 to len(threads)
            if threadStates[i] = THREAD_RUNNING
                joinThread(i)
            ok
        next
    
    func yieldThread
        thrd_yield()
    
    # Cleanup
    func destroy
        # First, join any running threads
        joinAllThreads()
        
        # Clean up mutexes
        for mutex in mutexes
            mtx_destroy(mutex)
        next
        
        # Clean up condition variables
        for cond in conditions
            cnd_destroy(cond)
        next
        
        # Reset all internal state
        threads = []
        mutexes = []
        conditions = []
        threadStates = []
        threadNames = []
        threadPriorities = []
        threadErrors = []
        activeThreads = 0

class ThreadStats
    name = ""
    state = ""
    priority = 0
    error = ""
