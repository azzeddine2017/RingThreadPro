load "../RingThreadPro.ring"
load "sockets.ring"

# Chat Server using ThreadManager
oThreads = new ThreadManager(10)  # Support up to 10 concurrent clients

# Shared resources
clients = []
clientNames = []
clientsMutex = oThreads.createMutex(1)
messageQueue = []
queueMutex = oThreads.createMutex(1)
activeClients = 0
isRunning = true

func main
    ? "Starting Ring Chat Server..."
    ? "=========================="
    
    try
        # Create server socket
        serverSocket = socket(AF_INET, SOCK_STREAM, 0)
        bind(serverSocket, "127.0.0.1", 5050)
        listen(serverSocket, 5)
        
        ? "Server listening on port 5050"
        ? "Waiting for clients..."
        
        # Start message broadcaster thread
        oThreads.createThread(1, "broadcastMessages()")
        
        # Accept client connections
        while isRunning
            clientSocket = accept(serverSocket)
            
            if clientSocket != null
                oThreads.lockMutex(clientsMutex)
                add(clients, clientSocket)
                add(clientNames, "")  # Will be set when client sends CONNECT message
                threadID = len(clients)
                activeClients++
                oThreads.unlockMutex(clientsMutex)
                
                ? "New client connected! Active clients: " + activeClients
                oThreads.createThread(threadID + 1, "handleClient(" + threadID + ")")
            ok
            
            oThreads.yieldThread()
        end
        
    catch
        ? "Error starting server"
    done
    
    # Cleanup
    if serverSocket != null
        close(serverSocket)
    ok
    ? "Server shutdown complete"

func handleClient n
    oThreads.lockMutex(clientsMutex)
    clientSocket = clients[n]
    oThreads.unlockMutex(clientsMutex)
    
    while isRunning
        try
            # Receive message from client
            message = recv(clientSocket, 1024)
            
            if message = null or message = ""
                exit
            ok
            
            # Process different message types
            if substr(message, 1, 8) = "CONNECT:"
                clientName = substr(message, 9)
                oThreads.lockMutex(clientsMutex)
                clientNames[n] = clientName
                oThreads.unlockMutex(clientsMutex)
                broadcastToAll(message)
            but substr(message, 1, 11) = "DISCONNECT:"
                broadcastToAll(message)
                exit
            but substr(message, 1, 8) = "MESSAGE:"
                broadcastToAll(message)
            ok
            
        catch
            ? "Error handling client " + n
            exit
        done
        
        oThreads.yieldThread()
    end
    
    # Clean up client connection
    oThreads.lockMutex(clientsMutex)
    clients[n] = null
    clientNames[n] = ""
    activeClients--
    oThreads.unlockMutex(clientsMutex)
    close(clientSocket)
    ? "Client " + n + " disconnected. Active clients: " + activeClients

func broadcastToAll message
    oThreads.lockMutex(clientsMutex)
    for i = 1 to len(clients)
        if clients[i] != null
            try
                send(clients[i], message)
            catch
                ? "Error broadcasting to client " + i
            done
        ok
    next
    oThreads.unlockMutex(clientsMutex)
    
    # Log the message
    if substr(message, 1, 8) = "MESSAGE:"
        ? "Broadcast: " + substr(message, 9)
    ok

func broadcastMessages
    while isRunning
        oThreads.lockMutex(queueMutex)
        if len(messageQueue) > 0
            message = messageQueue[1]
            del(messageQueue, 1)
            oThreads.unlockMutex(queueMutex)
            broadcastToAll(message)
        else
            oThreads.unlockMutex(queueMutex)
        ok
        oThreads.yieldThread()
    end
