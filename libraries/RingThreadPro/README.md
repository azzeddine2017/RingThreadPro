# RingThreadPro

A professional thread management library for Ring programming language.

## Quick Start

1. Include the library in your Ring program:
```ring
load "RingThreadPro.ring"
```

2. Create a ThreadManager instance:
```ring
oThreads = new ThreadManager(4)  # Create manager with 4 threads
```

3. Create and use threads:
```ring
# Create a thread
oThreads.createThread(1, "myFunction()")

# Wait for thread completion
oThreads.joinThread(1)

# Clean up
oThreads.destroy()
```

## Examples

1. Basic Thread Example:
```ring
load "ThreadExample.ring"
```

2. Advanced Threading:
```ring
load "ThreadAdvancedExample.ring"
```

3. Thread Pool:
```ring
load "ThreadPoolExample.ring"
```

## Features

- Thread creation and management
- Thread synchronization (mutexes, condition variables)
- Thread priorities and naming
- Error handling and debugging
- Resource management
- Thread pools and barriers

## Documentation

See `RingThreadPro_Documentation.md` for complete documentation.




