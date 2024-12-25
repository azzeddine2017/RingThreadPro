# The Main File

load "stdlib.ring"

func main

	? "install 'RingThreadPro' successfully" + nl

	? 'A professional thread management library for Ring programming language.

	Quick Start

	Include the library in your Ring program:
	load "RingThreadPro.ring"

	Create a ThreadManager instance:
	oThreads = new ThreadManager(4)  # Create manager with 4 threads

	Create and use threads:

	# Create a thread
	oThreads.createThread(1, "myFunction()")

	# Wait for thread completion
	oThreads.joinThread(1)

	# Clean up
	oThreads.destroy()'
