load "libui.ring"
load "sockets.ring"
load "../RingThreadPro.ring"
load "stdlib.ring"


# المتغيرات العامة
oThreads = new ThreadManager(10)
clients = []
clientNames = []
clientMutex = oThreads.createMutex(mtx_plain)
serverSocket = NULL
isRunning = false

# عناصر واجهة المستخدم
mainwin = NULL
logArea = NULL
startButton = NULL
stopButton = NULL
statusBar = NULL

# تهيئة النافذة الرئيسية
mainwin = uiNewWindow("🖥️ خادم الدردشة", 600, 500, 1)
uiWindowSetMargined(mainwin, 1)

# إنشاء التخطيط الرئيسي
vbox = uiNewVerticalBox()
uiBoxSetPadded(vbox, 1)

# مجموعة التحكم
controlGroup = uiNewGroup("⚙️ التحكم بالخادم")
uiGroupSetMargined(controlGroup, 1)
controlBox = uiNewHorizontalBox()
uiBoxSetPadded(controlBox, 1)

# مسافة في الأعلى
topSpacer = uiNewVerticalBox()
uiBoxSetPadded(topSpacer, 0)
uiBoxAppend(controlBox, topSpacer, 0)

startButton = uiNewButton("▶️ تشغيل الخادم")
uiButtonOnClicked(startButton, "startServer()")
stopButton = uiNewButton("⏹️ إيقاف الخادم")
uiButtonOnClicked(stopButton, "stopServer()")
uiControlDisable(stopButton)

uiBoxAppend(controlBox, startButton, 1)
uiBoxAppend(controlBox, stopButton, 1)
uiGroupSetChild(controlGroup, controlBox)
uiBoxAppend(vbox, controlGroup, 0)

# مسافة بين المجموعات
spacer1 = uiNewVerticalBox()
uiBoxSetPadded(spacer1, 0)
uiBoxAppend(vbox, spacer1, 0)

# مجموعة السجل
logGroup = uiNewGroup("📝 سجل الخادم")
uiGroupSetMargined(logGroup, 1)

logArea = uiNewMultilineEntry()
uiMultilineEntrySetReadOnly(logArea, 1)
uiGroupSetChild(logGroup, logArea)
uiBoxAppend(vbox, logGroup, 1)

# مسافة قبل معلومات الخادم
spacer2 = uiNewVerticalBox()
uiBoxSetPadded(spacer2, 0)
uiBoxAppend(vbox, spacer2, 0)

# شريط الحالة والمعلومات
infoGroup = uiNewGroup("ℹ️ معلومات الخادم")
uiGroupSetMargined(infoGroup, 1)
infoBox = uiNewVerticalBox()
uiBoxSetPadded(infoBox, 1)

statusBar = uiNewLabel("⭕ الخادم متوقف")
uiBoxAppend(infoBox, statusBar, 0)
uiBoxAppend(infoBox, uiNewLabel("🔌 المنفذ: 5050 | 🌐 العنوان: 127.0.0.1"), 0)

uiGroupSetChild(infoGroup, infoBox)
uiBoxAppend(vbox, infoGroup, 0)

uiWindowSetChild(mainwin, vbox)
uiControlShow(mainwin)
uiWindowOnClosing(mainwin, "onClosing()")
uiMain()

# دالة لعرض الأخطاء في الكونسول
func logError(error)
    see "[ERROR] " + error + nl
    logMessage("❌ " + error)
return

# دالة لعرض المعلومات في الكونسول
func logInfo(info)
    see "[INFO] " + info + nl
    logMessage("ℹ️ " + info)
return

func startServer
    try
        serverSocket = socket(AF_INET, SOCK_STREAM, 0)
        bind(serverSocket, "127.0.0.1", 5050)
        listen(serverSocket, 10)
        isRunning = true
        
        logInfo("Server started successfully on port 5050")
        uiLabelSetText(statusBar, "⭕ الخادم يعمل")
        
        uiControlDisable(startButton)
        uiControlEnable(stopButton)
        
        oThreads.createThread(1, "acceptClients()")
    catch
        logError("Failed to start server: " + cCatchError)
    done

func stopServer
    try
        isRunning = false
        
        # إغلاق جميع اتصالات العملاء
        oThreads.lockMutex(clientMutex)
        for client in clients
            close(client)
        next
        clients = []
        clientNames = []
        oThreads.unlockMutex(clientMutex)
        
        close(serverSocket)
        
        logInfo("Server stopped successfully")
        uiLabelSetText(statusBar, "⭕ الخادم متوقف")
        
        uiControlEnable(startButton)
        uiControlDisable(stopButton)
    catch
        logError("Error stopping server: " + cCatchError)
    done

func acceptClients
    while isRunning
        try
            clientSocket = accept(serverSocket)
            if clientSocket != NULL
                oThreads.lockMutex(clientMutex)
                add(clients, clientSocket)
                add(clientNames, "")
                threadID = len(clients)
                oThreads.unlockMutex(clientMutex)
                
                logInfo("New client connection accepted")
                oThreads.createThread(threadID + 1, "handleClient(" + threadID + ")")
            ok
        catch
            logError("Error accepting client connection: " + cCatchError)
        done
        oThreads.yieldThread()
    end

func handleClient clientID
    while isRunning
        try
            oThreads.lockMutex(clientMutex)
            clientSocket = clients[clientID]
            oThreads.unlockMutex(clientMutex)

            message = recv(clientSocket, 4096)
            if message = NULL or message = "" continue ok

            if substr(message, 1, 8) = "CONNECT:"
                username = substr(message, 9)
                oThreads.lockMutex(clientMutex)
                clientNames[clientID] = username
                oThreads.unlockMutex(clientMutex)
                logInfo("Client connected: " + username)
                broadcast("SYSTEM:" + username + " joined the chat")
            
            elseif substr(message, 1, 11) = "DISCONNECT:"
                username = substr(message, 12)
                logInfo("Client disconnected: " + username)
                broadcast("SYSTEM:" + username + " left the chat")
                removeClient(clientID)
                exit
            
            elseif substr(message, 1, 8) = "MESSAGE:"
                broadcast(message)
                parts = split(message, ":")
                if len(parts) >= 3
                    logMessage("Message from " + parts[2] + ": " + parts[3])
                ok
            
            elseif substr(message, 1, 5) = "FILE:"
                broadcast(message)
                parts = split(message, ":")
                if len(parts) >= 3
                    sender = parts[2]
                    filename = parts[3]
                    logInfo(sender + " is sending a file: " + filename)
                    
                    # إعادة توجيه محتوى الملف
                    while true
                        data = recv(clientSocket, 4096)
                        if substr(data, 1, 8) = "ENDFILE:" 
                            broadcast(data)
                            break
                        ok
                        broadcast(data)
                    end
                    
                    logInfo("File transfer completed successfully")
                ok
            ok

        catch
            logError("Error handling client " + clientID + ": " + cCatchError)
            removeClient(clientID)
            exit
        done
        oThreads.yieldThread()
    end

func broadcast message
    oThreads.lockMutex(clientMutex)
    for client in clients
        try
            send(client, message)
        catch
            logError("Error broadcasting message: " + cCatchError)
        done
    next
    oThreads.unlockMutex(clientMutex)

func logMessage text
    uiMultilineEntryAppend(logArea, text + nl)

func removeClient clientIndex
    oThreads.lockMutex(clientMutex)
    try
        username = clientNames[clientIndex]
        close(clients[clientIndex])
        del(clients, clientIndex)
        del(clientNames, clientIndex)
        logInfo("Client removed successfully: " + username)
    catch
        logError("Error removing client " + clientIndex + ": " + cCatchError)
    done
    oThreads.unlockMutex(clientMutex)

func onClosing
    stopServer()
    uiQuit()
