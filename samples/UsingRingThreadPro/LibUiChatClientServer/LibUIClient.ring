load "libui.ring"
load "sockets.ring"
load "../RingThreadPro.ring"
load "stdlib.ring"


# المتغيرات العامة
oThreads = new ThreadManager(2)
clientSocket = NULL
clientMutex = oThreads.createMutex(mtx_plain)
isConnected = false
username = ""
selectedFile = ""

# عناصر واجهة المستخدم
mainwin = NULL
chatArea = NULL
messageEntry = NULL
sendButton = NULL
connectButton = NULL
disconnectButton = NULL
usernameEntry = NULL
fileButton = NULL
statusLabel = NULL



# تهيئة النافذة الرئيسية
mainwin = uiNewWindow("💬 تطبيق الدردشة", 800, 600, 1)
uiWindowSetMargined(mainwin, 1)

# التخطيط الرئيسي
mainBox = uiNewHorizontalBox()
uiBoxSetPadded(mainBox, 1)

# القسم الأيسر (منطقة الدردشة)
leftPanel = uiNewVerticalBox()
uiBoxSetPadded(leftPanel, 1)

# مجموعة الدردشة
chatGroup = uiNewGroup("💭 الدردشة")
uiGroupSetMargined(chatGroup, 1)
chatBox = uiNewVerticalBox()
uiBoxSetPadded(chatBox, 1)

chatArea = uiNewMultilineEntry()
uiMultilineEntrySetReadOnly(chatArea, 1)
uiBoxAppend(chatBox, chatArea, 1)

# مربع إدخال الرسائل
messageBox = uiNewHorizontalBox()
uiBoxSetPadded(messageBox, 1)

messageEntry = uiNewEntry()
sendButton = uiNewButton("📤 إرسال")
uiButtonOnClicked(sendButton, "sendMessage()")
uiControlDisable(sendButton)

uiBoxAppend(messageBox, messageEntry, 1)
uiBoxAppend(messageBox, sendButton, 0)
uiBoxAppend(chatBox, messageBox, 0)

uiGroupSetChild(chatGroup, chatBox)
uiBoxAppend(leftPanel, chatGroup, 1)

# القسم الأيمن (الاتصال والملفات)
rightPanel = uiNewVerticalBox()
uiBoxSetPadded(rightPanel, 1)

# مجموعة الاتصال
connectGroup = uiNewGroup("🔌 الاتصال")
uiGroupSetMargined(connectGroup, 1)
connectBox = uiNewVerticalBox()
uiBoxSetPadded(connectBox, 1)

usernameBox = uiNewHorizontalBox()
uiBoxSetPadded(usernameBox, 1)
uiBoxAppend(usernameBox, uiNewLabel("👤 اسم المستخدم:"), 0)
usernameEntry = uiNewEntry()
uiBoxAppend(usernameBox, usernameEntry, 1)
uiBoxAppend(connectBox, usernameBox, 0)

# مسافة بين عناصر الاتصال
spacer1 = uiNewVerticalBox()
uiBoxSetPadded(spacer1, 0)
uiBoxAppend(connectBox, spacer1, 0)

buttonBox = uiNewHorizontalBox()
uiBoxSetPadded(buttonBox, 1)
connectButton = uiNewButton("🔗 اتصال")
disconnectButton = uiNewButton("❌ قطع الاتصال")
uiButtonOnClicked(connectButton, "connectToServer()")
uiButtonOnClicked(disconnectButton, "disconnect()")
uiControlDisable(disconnectButton)

uiBoxAppend(buttonBox, connectButton, 1)
uiBoxAppend(buttonBox, disconnectButton, 1)
uiBoxAppend(connectBox, buttonBox, 0)

uiGroupSetChild(connectGroup, connectBox)
uiBoxAppend(rightPanel, connectGroup, 0)

# مسافة بين المجموعات
spacer2 = uiNewVerticalBox()
uiBoxSetPadded(spacer2, 0)
uiBoxAppend(rightPanel, spacer2, 0)

# مجموعة مشاركة الملفات
fileGroup = uiNewGroup("📎 مشاركة الملفات")
uiGroupSetMargined(fileGroup, 1)
fileBox = uiNewVerticalBox()
uiBoxSetPadded(fileBox, 1)

fileButton = uiNewButton("📂 اختيار ملف")
uiButtonOnClicked(fileButton, "selectFile()")
uiControlDisable(fileButton)
uiBoxAppend(fileBox, fileButton, 0)

uiGroupSetChild(fileGroup, fileBox)
uiBoxAppend(rightPanel, fileGroup, 0)

# مسافة قبل الحالة
spacer3 = uiNewVerticalBox()
uiBoxSetPadded(spacer3, 0)
uiBoxAppend(rightPanel, spacer3, 1)

# حالة الاتصال
statusGroup = uiNewGroup("ℹ️ الحالة")
uiGroupSetMargined(statusGroup, 1)
statusBox = uiNewVerticalBox()
uiBoxSetPadded(statusBox, 1)

statusLabel = uiNewLabel("⭕ غير متصل")
uiBoxAppend(statusBox, statusLabel, 0)
uiBoxAppend(statusBox, uiNewLabel("🌐 العنوان: 127.0.0.1 | 🔌 المنفذ: 5050"), 0)

uiGroupSetChild(statusGroup, statusBox)
uiBoxAppend(rightPanel, statusGroup, 0)

# إضافة الأقسام إلى التخطيط الرئيسي
uiBoxAppend(mainBox, leftPanel, 1)
uiBoxAppend(mainBox, rightPanel, 0)

uiWindowSetChild(mainwin, mainBox)
uiControlShow(mainwin)
uiWindowOnClosing(mainwin, "onClosing()")
uiMain()


# دالة لعرض الأخطاء في الكونسول
func logError(error)
    see "[ERROR] " + error + nl
    appendChat("❌ " + error)
return

# دالة لعرض المعلومات في الكونسول
func logInfo(info)
    see "[INFO] " + info + nl
    appendChat("ℹ️ " + info)
return


func connectToServer
    if len(uiEntryText(usernameEntry)) < 3
        logError("Username must be at least 3 characters long")
        return
    ok
    
    username = uiEntryText(usernameEntry)
    
    try
        clientSocket = socket(AF_INET, SOCK_STREAM)
        connect(clientSocket, "127.0.0.1", 5050)
        isConnected = true
        
        # إرسال اسم المستخدم
        send(clientSocket, "CONNECT:" + username)
        
        logInfo("Successfully connected to server")
        uiLabelSetText(statusLabel, "متصل: " + username)
        
        # تحديث حالة عناصر الواجهة
        uiEntrySetReadOnly(usernameEntry, 1)
        uiControlDisable(connectButton)
        uiControlEnable(messageEntry)
        uiControlEnable(sendButton)
        uiControlEnable(fileButton)
        uiControlEnable(disconnectButton)
        
        # بدء استقبال الرسائل
        oThreads.createThread(1, "receiveMessages()")
    catch
        logError("Failed to connect to server: " + cCatchError)
        uiLabelSetText(statusLabel, "فشل الاتصال")
    done

func disconnect
    try
        if isConnected
            send(clientSocket, "DISCONNECT:" + username)
            isConnected = false
            close(clientSocket)
        ok
        
        logInfo("Disconnected from server")
        uiLabelSetText(statusLabel, "غير متصل")
        
        # تحديث حالة عناصر الواجهة
        uiEntrySetReadOnly(usernameEntry, 0)
        uiControlEnable(connectButton)
        uiControlDisable(messageEntry)
        uiControlDisable(sendButton)
        uiControlDisable(fileButton)
        uiControlDisable(disconnectButton)
    catch
        logError("Error during disconnection: " + cCatchError)
    done

func sendMessage
    if not isConnected return ok
    
    message = uiEntryText(messageEntry)
    if message = "" return ok
    
    try
        send(clientSocket, "MESSAGE:" + username + ":" + message)
        uiEntrySetText(messageEntry, "")
        logInfo("Message sent successfully")
    catch
        logError("Failed to send message: " + cCatchError)
        disconnect()
    done

func selectFile
    try
        selectedFile = uiOpenFile(mainwin)
        if selectedFile != ""
            logInfo("Selected file: " + selectedFile)
            sendFile()
        ok
    catch
        logError("Error selecting file: " + cCatchError)
    done

func sendFile
    if selectedFile = "" return ok
    
    try
        fp = fopen(selectedFile, "rb")
        if fp
            send(clientSocket, "FILE:" + username + ":" + justfilename(selectedFile))
            
            while not feof(fp)
                data = fread(fp, 4096)
                send(clientSocket, "DATA:" + data)
            end
            
            send(clientSocket, "ENDFILE:")
            fclose(fp)
            
            logInfo("File sent successfully: " + justfilename(selectedFile))
            selectedFile = ""
        else
            logError("Could not open file: " + selectedFile)
        ok
    catch
        logError("Error sending file: " + cCatchError)
        disconnect()
    done

func receiveFile(fileInfo)
    try
        parts = split(fileInfo, ":")
        if len(parts) >= 2
            sender = parts[1]
            filename = parts[2]
            
            # Create received files directory if it doesn't exist
            if not direxists("received_files")
                system("mkdir received_files")
            ok
            
            # Create file path
            filepath = "received_files/" + filename
            
            # Open file for writing
            fp = fopen(filepath, "wb")
            if fp
                logInfo("Started receiving file: " + filename + " from " + sender)
                appendChat("📥 Receiving file: " + filename + " from " + sender)
                
                while true
                    data = recv(clientSocket, 4096)
                    if data = NULL 
                        logError("Connection lost while receiving file")
                        fclose(fp)
                        appendChat("❌ File reception failed: Connection lost")
                        return
                    ok
                    
                    if substr(data, 1, 8) = "ENDFILE:"
                        fclose(fp)
                        logInfo("File saved successfully: " + filepath)
                        appendChat("✅ File received: " + filename + " from " + sender)
                        appendChat("💾 Saved to: " + filepath)
                        return
                    ok
                    
                    if substr(data, 1, 5) = "DATA:"
                        fileData = substr(data, 6)
                        fwrite(fp, fileData)
                    ok
                end
            else
                logError("Could not create file: " + filepath)
                appendChat("❌ Could not create file")
            ok
        else
            logError("Invalid file information received")
            appendChat("❌ Invalid file information")
        ok
    catch
        logError("Error receiving file: " + cCatchError)
        appendChat("❌ Error occurred while receiving file")
        if fp fclose(fp) ok
    done
return

func receiveMessages
    while isConnected
        try
            data = recv(clientSocket, 4096)
            if data = NULL
                logError("Connection lost")
                disconnect()
                exit
            ok
            
            if substr(data, 1, 8) = "MESSAGE:"
                msg = substr(data, 9)
                appendChat(msg)
            but substr(data, 1, 5) = "FILE:"
                msg = substr(data, 6)
                logInfo("Receiving file: " + msg)
                receiveFile(msg)
            but substr(data, 1, 7) = "SYSTEM:"
                msg = substr(data, 8)
                appendChat("🔔 " + msg)
            ok
        catch
            logError("Error receiving message: " + cCatchError)
            disconnect()
            exit
        done
    end

func appendChat text
    uiMultilineEntryAppend(chatArea, text + nl)

func onClosing
    disconnect()
    uiQuit()
