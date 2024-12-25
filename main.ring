# Load required libraries
load "stdlib.ring"
load "consolecolors.ring"

# Global variables and constants
BANNER_DELAY = 0.3
LINE_DELAY = 0.1
SECTION_DELAY = 0.5
TOTAL_WIDTH = 76
Tab = char(9)

func main
    DisplayBanner()

func DisplayBanner
    system("cls")
    see nl
    see Tab + cc_print(CC_FG_GREEN | CC_BG_NONE, "╔══════════════════════════════════════════════════════════════════╗") + nl
    see Tab + cc_print(CC_FG_GREEN | CC_BG_NONE, "║           install 'RingThreadPro' successfully                   ║") + nl
    see Tab + cc_print(CC_FG_GREEN | CC_BG_NONE, "╚══════════════════════════════════════════════════════════════════╝") + nl
    see nl

    # Creative ASCII Art
    art = [
        "██████╗ ██╗███╗   ██╗ ██████╗ ████████╗██╗  ██╗██████╗ ███████╗ █████╗ ██████╗ ",
        "██╔══██╗██║████╗  ██║██╔════╝ ╚══██╔══╝██║  ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗",
        "██████╔╝██║██╔██╗ ██║██║  ███╗   ██║   ███████║██████╔╝█████╗  ███████║██║  ██║",
        "██╔══██╗██║██║╚██╗██║██║   ██║   ██║   ██╔══██║██╔══██╗██╔══╝  ██╔══██║██║  ██║",
        "██║  ██║██║██║ ╚████║╚██████╔╝   ██║   ██║  ██║██║  ██║███████╗██║  ██║██████╔╝",
        "╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝",
        "				██████╗ ██████╗  ██████╗",
        "				██╔══██╗██╔══██╗██╔═══██╗",
        "				██████╔╝██████╔╝██║   ██║",
        "				██╔═══╝ ██╔══██╗██║   ██║",
        "				██║     ██║  ██║╚██████╔╝",
        "				╚═╝     ╚═╝  ╚═╝ ╚═════╝"
    ]

    # Display ASCII Art with animation
    for line in art
        see Tab + cc_print(CC_FG_CYAN | CC_BG_NONE, line) + nl
        sleep(LINE_DELAY)
    next

    # Display subtitle with different color
    ? ""
    see Tab + cc_print(CC_FG_BLUE | CC_BG_NONE, "╔═══════ Professional Threading Library ═══════╗") + nl
    see Tab + cc_print(CC_FG_WHITE | CC_BG_NONE, "      Developed for Ring Language v1.22      ") + nl
    see Tab + cc_print(CC_FG_BLUE | CC_BG_NONE, "╚═════════════════════════════════════════════╝") + nl
    ? ""

    # Loading animation
    see Tab + "Loading: "
    for i = 1 to 20
        see cc_print(CC_FG_GREEN | CC_BG_NONE, "▓")
        sleep(0.05)
    next
    ? ""
    DisplayFeatures()

func DisplayFeatures
    features = [
        ["⚡", "Powerful Thread Management"],
        ["🔒", "Thread-Safe Operations"],
        ["🎯", "Easy-to-Use API"],
        ["📊", "Real-time Monitoring"],
        ["🔄", "Dynamic Thread Control"]
    ]

    see nl + Tab + cc_print(CC_FG_BLUE | CC_BG_NONE, "╔═══════════════ Key Features ═══════════════╗") + nl
    
    for feature in features
        see Tab + cc_print(CC_FG_CYAN | CC_BG_NONE, "  " + feature[1] + " " + feature[2]) + nl
        sleep(LINE_DELAY)
    next
    
    see Tab + cc_print(CC_FG_BLUE | CC_BG_NONE, "╚════════════════════════════════════════════╝") + nl
    
    see nl + Tab + cc_print(CC_FG_BLUE | CC_BG_NONE, "╔═══════════════ Quick Start ═══════════════╗") + nl
    
    code = '
    # Create Thread Manager
    oThreads = new ThreadManager(4)

    # Start New Thread
    oThreads.createThread(1, "myFunction()")

    # Join Thread
    oThreads.joinThread(1)

    # Clean Up
    oThreads.destroy()'
    
    see cc_print(CC_FG_WHITE | CC_BG_NONE, code) + nl
    
    see Tab + cc_print(CC_FG_BLUE | CC_BG_NONE, "╚════════════════════════════════════════════╝") + nl

func center text, width
    space = floor((width - len(text)) / 2)
    return copy(" ", space) + text
