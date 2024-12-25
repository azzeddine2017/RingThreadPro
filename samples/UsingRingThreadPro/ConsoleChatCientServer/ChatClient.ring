load "../RingThreadPro.ring"
load "sockets.ring"

# Chat Client using ThreadManager
oThreads = new ThreadManager(2)  # One thread for receiving, one for sending

# Shared resources
clientSocket = null
isConnected = true
clientName = ""
exitSignal = false

func main
    ? "Welcome to Ring Chat Client!"
    ? "=========================="
    ? "Please enter your name:"
    Give clientName
    
    ? "Connecting to server..."
    
    try
        # Connect to server
        clientSocket = socket(AF_INET, SOCK_STREAM)
        connect(clientSocket, "127.0.0.1", 5050)
        
        ? "Successfully connected to server!"
        ? "Type your message and press Enter to send"
        ? "Type 'exit' to quit"
        ? "=========================="
        
        # Send initial connection message with client name
        send(clientSocket, "CONNECT:" + clientName)
        
        # Start receiver thread
        oThreads.createThread(1, "receiveMessages()")
        
        # Main thread handles sending messages
        while isConnected
            Give message
            
            if message = "exit"
                exitSignal = true
                isConnected = false
                send(clientSocket, "DISCONNECT:" + clientName)
                ? "Disconnecting..."
                exit
            ok
            
            if isConnected
                try
                    send(clientSocket, "MESSAGE:" + clientName + ": " + message)
                catch
                    ? "Error sending message"
                    exitSignal = true
                    isConnected = false
                    exit
                done
            ok
        end
    catch
        ? "Failed to connect to server"
        exitSignal = true
        isConnected = false
    done
    
    # Clean up
    if clientSocket != null
        close(clientSocket)
    ok
    ? "Chat client closed"
    shutdown()

func receiveMessages
    while isConnected
        if exitSignal exit ok
        
        try
            message = recv(clientSocket, 1024)
            
            if message = null or message = ""
                if not exitSignal
                    ? "Lost connection to server"
                ok
                isConnected = false
                exit
            ok
            
            # Process different message types
            if substr(message, 1, 8) = "CONNECT:"
                message = substr(message, 9) + " has joined the chat"
            but substr(message, 1, 11) = "DISCONNECT:"
                message = substr(message, 12) + " has left the chat"
            but substr(message, 1, 8) = "MESSAGE:"
                message = substr(message, 9)
            ok
            
            ? message
            
        catch
            if not exitSignal
                ? "Error receiving message"
            ok
            isConnected = false
            exit
        done
        
        oThreads.yieldThread()
    end

func shutdown
    exitSignal = true
    isConnected = false
    if clientSocket != null
        close(clientSocket)
    ok
    exit
