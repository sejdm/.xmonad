-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import XMonad
import System.Exit
import XMonad.Hooks.DynamicLog
import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen
import XMonad.Layout.Minimize
import XMonad.Layout.ResizableTile
import XMonad.Actions.WindowBringer

import Graphics.X11.ExtraTypes.XF86

import XMonad.Hooks.EwmhDesktops


import System.IO
import XMonad.Util.Run(spawnPipe)

import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import XMonad.Layout.PerWorkspace

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "st tmux 2>/dev/null"


-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
--myModMask       = mod1Mask
myModMask       = mod4Mask

-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
myNumlockMask   = mod2Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = [browserWorkspace, editingWorkspace,"3","4","5","6","7","8", experimentsWorkspace]

browserWorkspace = "1"
experimentsWorkspace = "9"
editingWorkspace = "2"

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"


myOneLiner k s = ((controlMask .|. shiftMask, k     ), spawn s)
myFnKey k s = ((0 , k     ), spawn s)
------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- Print screen
    , ((0, xK_Print), spawn "gnome-screenshot -i")

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    , ((modm , xK_g     ), gotoMenu)
    , ((modm , xK_b     ), bringMenu)
 -- sudo apt get install zenity wmctrl sdcv xsel xclip feh xcowsay qalc
    -- save a tweet in a journal
     --, ((controlMask .|. shiftMask, xK_t     ), spawn "entry=$(yad --center --entry --text 'Tweet?') && echo '**' $(date '+[%Y-%m-%d %a %H:%M]') $entry >> ~/journal.org")
     --, myOneLiner xK_t "entry=$(yad --center --entry --text 'Reminder?' --width=500) && (echo $entry | ( read first rest; sleep $((first)) && echo $rest | (yad --on-top --no-buttons --wrap --center --text-info --width=400 --fontname='inconsolata 12' --height=50; exit 0)  || xcowsay 'huh?') )"
     , myOneLiner xK_t "notify-send \"$(date)\""

    -- save clippings
    , myOneLiner xK_c "echo - $(date '+[%Y-%m-%d %a %H:%M]') $(xclip -selection 'primary' -o) >> ~/clippings.org"

    -- save listings
      , myOneLiner xK_l "entry=$(yad --center --entry --text 'Search latex' --width=500) && zsh -c \"rm -f /tmp/ramdisk/results.tex; (cat /home/shane/bin/latexPreamble.tex <(/home/shane/bin/searchlatex $entry) /home/shane/bin/latexPostamble.tex>/tmp/ramdisk/results.tex; (cd /tmp/ramdisk; (pdflatex -halt-on-error results.tex && /usr/bin/zathura results.pdf || xcowsay 'No match!' )2>/dev/null))\" "

    -- switch window by name
    , myOneLiner xK_s "wmctrl -a $(yad --center --entry --text 'Switch to?' 2>/dev/null)"

    -- save reminder
       , myOneLiner xK_r "entry=$(yad --center --entry --text 'Reminder?' --width=500) && parseddate=$(date -d\"$(echo $entry | awk -F' at ' '{print $NF}')\"  '+<%Y-%m-%d %a %H:%M>' 2>&1) && (echo \\*\\* $(echo $entry | awk -F' at ' '{for(i=1;i<=NF-1;++i)print $i}') ; echo $parseddate ) >> ~/diary.org || xcowsay $parseddate!!! ; /home/shane/bin/wallpaper ; display -window root /home/shane/cal.svg"

    -- Display reminders
       --, myOneLiner xK_r "(org2remind.pl /home/shane/diary.org ; sed 's/^DEADLINE: \\(.*\\)/\\1/' /home/shane/Dropbox/Application/applications.org | org2remind.pl - | sed 's/ MSG / MSG APP: /') | sed 's#\\[\\([0-9][0-9]*\\)/\\([0-9][0-9]*\\)\\]#(\\1 of \\2)#' | remind -c -p - | rem2ps -l -e | gv -presentation -orientation landscape -center -geometry 1090x780 -resize -"
        --, ((mod1Mask .|. shiftMask, xK_r     ), spawn "zsh -c \"weekrem\" | yad --on-top --no-buttons --wrap --center --text-info --width=635 --fontname='inconsolata 12' --height=750")

    -- execute one shell command and display the output
      , myOneLiner xK_x "entry=$(yad --center --entry --text='Command?') && zsh -c \"$entry\" | yad --on-top --no-buttons --wrap --center --text-info --width=700 --fontname='inconsolata 12' --height=750"

    -- calculate using qalc
     , myOneLiner xK_q "entry=$(yad --center --entry --text='Calculate?') && qalc \"$entry\" | yad --on-top --no-buttons --wrap --center --text-info --width=300 --height=300"

    -- check dictionary
     , myOneLiner xK_d "entry=$(yad --center --entry --text='Word?') && (dict \"$entry\" ; echo ; echo ; sdcv -n \"$entry\") | yad --on-top --no-buttons --wrap --center --text-info --width=700 --height=750"

   -- Play video
     , myOneLiner xK_o "mpv -fs \"/home/shane/Videos$(find -iname '*.mp4' | sed 's#^.##' | dmenu -i -l 20)\""

   -- Display poems
       --, myOneLiner xK_p "entry=$(yad --center --entry --text='Word?') && (cat \"/home/shane/Documents/Poems/$(ls /home/shane/Documents/Poems | grep -i \"$entry\")\") | yad --on-top --no-buttons --wrap --center --text-info --width=700 --height=750"

      --, myOneLiner xK_o "entry=$(yad --center --filename=/home/shane/Documents/Poems/ --file --width=700 --center --on-top --maximized) && (cat \"$entry\" | yad --on-top --no-buttons --wrap --center --text-info --width=700 --height=750)"
      , myOneLiner xK_p "entry=$(ls /home/shane/Documents/Poems | dmenu -i -l 20) && (cat \"/home/shane/Documents/Poems/$entry\" | yad --on-top --no-buttons --wrap --center --text-info --width=700 --height=750)"

  -- Check the weather of Pune
     , myOneLiner xK_w "wget -q -O- wttr.in/pune | sed 's/\\x1b\\[[0-9;]*m//g' | yad --on-top --no-buttons --wrap --center --text-info --width=1010 --height=750"

  -- set url as max wallpaper
     , myOneLiner xK_a "feh --bg-max $(xsel -b -o)"

     , myOneLiner xK_m "(cd ~/Music; youtube-dl -x --audio-format mp3 --add-metadata \"$(xclip -o)\" && notify-send \"Youtube music downloaded\" || notify-send \"Youtube music download FAILED\")"
     
     , myOneLiner xK_v "(cd ~/Videos; youtube-dl --add-metadata \"$(xclip -o)\" && notify-send \"Youtube video downloaded\" || notify-send \"Youtube video download FAILED\")"

     , myOneLiner xK_i "notify-send \"$(mpc current)\""

     --, myFnKey xF86XK_AudioPlay "echo 'pause'>/home/shane/mplayerfifo"
     , myFnKey xF86XK_AudioPlay "mpc toggle"
     --, myFnKey xF86XK_AudioPlay "/usr/bin/feh /home/shane/wallpaper.png"

     , myFnKey xF86XK_AudioMute "echo 'mute'>/home/shane/mplayerfifo"

     --, myFnKey xF86XK_AudioLowerVolume "echo 'volume -1'>/home/shane/mplayerfifo"
     , myFnKey xF86XK_AudioLowerVolume "mpc volume -1"

     --, myFnKey xF86XK_AudioRaiseVolume "echo 'volume +1'>/home/shane/mplayerfifo"
     , myFnKey xF86XK_AudioRaiseVolume "mpc volume +1"

     --, myFnKey xF86XK_AudioNext "echo 'pt_step 1'>/home/shane/mplayerfifo"
     , myFnKey xF86XK_AudioNext "mpc next"

     --, myFnKey xF86XK_AudioPrev "echo 'pt_step -1'>/home/shane/mplayerfifo"
     , myFnKey xF86XK_AudioPrev "mpc prev"

     , myFnKey xF86XK_MonBrightnessUp "xbacklight +1"

     , myFnKey xF86XK_MonBrightnessDown "xbacklight -1"


    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

    -- Fullscreen window
    , ((modm, xK_f), sendMessage $ Toggle FULL)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    , ((modm,               xK_a), sendMessage MirrorShrink)
    , ((modm,               xK_z), sendMessage MirrorExpand)

    -- toggle the status bar gap (used with avoidStruts from Hooks.ManageDocks)rendering a list of diagrams as separate files in haskell diagrams
    -- , ((modm , xK_b ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), restart "xmonad" True)


    , ((modm,               xK_i     ), withFocused minimizeWindow)
    , ((modm .|. shiftMask, xK_i     ), sendMessage RestoreNextMinimizedWin)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = minimize $ onWorkspaces [browserWorkspace, experimentsWorkspace] (myFull ||| myTiled ||| myMirrorTiled)
                (onWorkspace editingWorkspace editorTile myTiled ||| myMirrorTiled ||| myFull)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

     myTiled = smartBorders tiled

     myTiled' = noBorders $ smartBorders tiled

     myMirrorTiled = noBorders $ smartBorders (Mirror tiled)

     myFull = fullscreenFull $ noBorders Full

     editorTile =  noBorders $ ResizableTall 1 (1/100) (1/2) [1, 190/100]

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ -- className =? "MPlayer"        --> doFloat
      className =? "Gimp"           --> doFloat
    , className =? "Main.py"          --> doFloat
    , className =? "Guake"          --> doFloat
    , className =? "Guake!"          --> doFloat
    , className =? "guake"          --> doFloat
    , className =? "Zenity"          --> doFloat
    , className =? "GV"          --> doFloat
    , className =? "Xmessage"          --> doFloat
    , className =? "Yad"          --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True


------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--
myLogHook = return ()
myLogHook' xmproc = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppCurrent = xmobarColor "red" ""
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--myStartupHook = return ()
myStartupHook = do spawn "xmodmap /home/shane/.capsesc"
                   spawn "firefox"
                   spawn "guake"
                   spawn "/home/shane/bin/wallpaper"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
--main = xmonad =<< xmobar defaults
--main = xmonad defaults


main = do xmproc <- spawnPipe "/usr/bin/xmobar /home/shane/.xmobarrc"
          xmonad $ ewmh defaults {logHook = myLogHook' xmproc}

--main = xmonad =<< dzen defaults


-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        --numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

