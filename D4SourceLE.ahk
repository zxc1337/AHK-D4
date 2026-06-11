; DllImport,ahkExec,%A_AhkPath%\ahkExec,Str,,UInt,0,CDecl

GroupAdd, GameGroup, ahk_exe Last Epoch.exe
GroupAdd, GameGroup, ahk_exe Diablo IV.exe
GroupAdd, GameGroup, ahk_exe Diablo IV Retail.exe
GroupAdd, GameGroup, ahk_exe D2R.exe
;#IfWinActive ahk_group GameGroup 

/*
#Include Gdip.ahk
; Initialize Gdip
pToken := Gdip_Startup()
if !pToken {
    MsgBox, GDI+ initialization failed!
    ExitApp
}

; Release resources on script exit
OnExit("ExitFunc")
ExitFunc() {
    global pToken
    Gdip_Shutdown(pToken)
    ExitApp
}
*/

global handlePath := "handle.exe"  ; Make sure handle.exe is in the script directory
global logFile := "log.txt"
global secs := 10000  ; Wait time (milliseconds)
global commonIni := "commonSetting.ini"  ; Config file path
global mainhwnd := 0

boss_Enable=0         ; Macro master switch
other_Enable=0        ; Non-combat state detection master switch
LabelAutoCloseWin_status=0 ; Auto close window switch
dubo_Enable=0         ; Gambling variable switch
temp_Enable=0         ; Temporary switch
channel_Enable=0      ; Channel skill switch
channel2_Enable=0     ; Channel skill 2 switch
BAutoL_Enable=0      ; Left click auto press switch
BAutoR_Enable=0      ;
BAuto1_Enable=0      ;
BAuto2_Enable=0      ;
BAuto3_Enable=0      ;
BAuto4_Enable=0      ;
BAutoMouseL_Enable=0 ;
BMarco1_Enable=0      ;
BMarco2_Enable=0      ;
BMarco3_Enable=0      ;
BMarco4_Enable=0      ;
BMarco5_Enable=0      ;
channel_status=0      ; Channel status, for recovery
channel2_status=0     ; Channel status 2, for recovery
BAutoL_status=0       ; Left button status, for recovery
BAutoR_status=0      ;
BAuto1_status=0      ;
BAuto2_status=0      ;
BAuto3_status=0      ;
BAuto4_status=0      ;
BAutoMouseL_status=0 ;
real_key := ""        ; Channel key, for recovery
real_key2 := ""       ; Channel key 2, for recovery
v_Tab=0               ; Tab key control switch
SelectedFile=""       ; Config file selection variable
SelectedUserFile=""   ; User custom file selection variable
selectSkillLabelL=""  ; Left button press skill corresponding Label
selectSkillLabelR=""  ; Right button press skill corresponding Label
LoadUserCode_enable := 0  ; Whether user custom code file has been loaded
forcemove_key := "z"
forceStand_key := "."
BMoveKey := "z"
BStandKey := "."
BSkillKey1 := "1"
BSkillKey2 := "2"
BSkillKey3 := "3"
BSkillKey4 := "4"
HotKeyList := "Shift|Ctrl|space|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|1|2|3|4|5|6|7|8|9|0|-|=|`|,|.|/|\|[|]" 
send_multi_quit := 0 ; Multiple key send quit check
lastLClickTime := 0
lastRClickTime := 0
timeSinceLastClick := 0

; Left/right button custom macro loop run counter
marcoTimerCount := 0
marco1TimerCount := 0
marco2TimerCount := 0
marco3TimerCount := 0
marco4TimerCount := 0
marco5TimerCount := 0
marcoLTimerCount := 0
marcoRTimerCount := 0

; Skill key control queue, using ready state mechanism
global Skill1Pending := false
global Skill2Pending := false
global Skill3Pending := false
global Skill4Pending := false
global Skill5Pending := false
global MouseLPending := false
global MouseRPending := false
global DispatchIndex := 1

; Skill panel position
SkillSrcPos := ""
; Skill bar position
SkillDesPos := ""
; Custom hotkey
LastHotkey := ""

i := 0
loop
{
    i := i+1
    if (i >= 11)
        break
    actionArray%i% := [] ; Custom macro 1 array
actionArrayStatus%i% := [] ; Custom macro 1 array status value
actionArrayCount%i% := 40 ; Custom macro 1 array max value
actionArrayIndex%i% := 0 ; Current array index value
}

serverItem := "Diablo IV|Diablo IV|Diablo II: Resurrected|Last Epoch"
moveItem := "z|x"
standItem := ".|shift"
avoidItem := "space"
lmouseItem := "5"
horseItem := "x|z"
skillkye1Item := "1|q"
skillkye2Item := "2|w"
skillkye3Item := "3|e"
skillkye4Item := "4|r"

actionItem := "Click Key|Hold Key|Release Key|Wait Time|Send Text|Custom Statement|Pause Macro|Close Macro|Show Info|Close Info|Placeholder|Change Skill|Single Custom Statement|Continuous Skill|Stop Continuous Skill|Multiple Keys|Mouse Circle|Mouse Move Position|Random Key|Save Mouse Position|Restore Mouse Position|Loop Backpack" ; Custom macro options
actionContent := "" ; Custom option specific content
savedMousePosionX := 0
savedMousePosionY := 0

marceItem := "Custom Macro1|Custom Macro2|Custom Macro3|Custom Macro4|Custom Macro5|Custom Macro6|Custom Macro7|Custom Macro8|Custom Macro9|Custom Macro10" ; Custom macro list
marceItemS := "Custom Macro1|Custom Macro2|Custom Macro3|Custom Macro4|Custom Macro5" ; Custom macro list short
currentMarco := 0

dclickItem := "No Action|Skill1|Skill2|Skill3|Skill4|Dodge|Skill5|Custom Macro1|Custom Macro2|Custom Macro3|Custom Macro4|Custom Macro5|Custom Macro6|Custom Macro7|Custom Macro8|Custom Macro9|Custom Macro10" ; Double click left/right options
enableItem := "Disable|When Running|When Not Running|Any Time" ; Activation settings options

marcoAccessKey := "" ; Key to trigger custom macro

d2rWindows_count := 0 ; Number of D2R windows
d2rMainAccountName := "" ; D2R main account name for creating game, name shown in friends list for quick join
D2R_GamePosition := 0 ;0=in game,1=character screen

SelectedFileExtra := ""       ; Quick config temp variable

commonSettingFile := "common.ini" ; Global config file
create_d2r_toggle := 1 ; D2R window creation process switch

Hotkey3_enable=0         
Hotkey4_enable=0         
Hotkey5_enable=0         

WinUserMarco := 0 ; Custom macro1 window handle

dm_enable = 0 ; Big Desert plugin switch
hWndArray := 0 ; Bound window collection

Gosub, ShowTray

;------------------------------------------------------------------------------------GUI >
MyGUI:
{
	Gui, -MaximizeBox -MinimizeBox +ToolWindow

    ;Gui, Add, Tab3,, General Settings|Auto Settings|Shout Settings|Custom Code ;|Plugin Features
    Gui, Add, Tab3,, General Settings|D2R Settings|Config Switch ;|Plugin Features
    ;;;;;;;;;General Settings Tab Content;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Gui, Add, GroupBox, x15 y24 w690 h600, 
    
    Gui, Add, Text, x25 y50 w60 h20, Server Name:
    Gui, Add, ComboBox, x85 y47 w110 h80 choose1 vBServer, %serverItem%  ;vBServer
    
    ;Gui, Add, Text, x25 y80 w200 h20, Note: Simplified is CN server, Traditional is Asia/US server
    
    /*
    Gui, Add, Text, x25 y80 w60 h20, Auto Force Move:
	Gui, Add, CheckBox, x85 y77 w80 h20 vBFouceMove, Enable ;vBFouceMove
    */
    
    Gui, Add, Text, x25 y80 w60 h20, Channel Key 1:
    Gui, Add, CheckBox, x85 y77 h20  vBchannel, Auto Start ;vBchannel
	Gui, Add, DropDownList, x135 y77 w60 AltSubmit choose1 vBchannelKey, Right Button|Skill 1|Skill 2|Skill 3|Skill 4|Force Move|Force Stand|Skill 5  ;vBchannelKey
    
    Gui, Add, Text, x25 y110 w60 h20, Channel Key 2:
    Gui, Add, CheckBox, x85 y107 h20  vBchannel2, Auto Start ;vBchannel2
	Gui, Add, DropDownList, x135 y107 w60 AltSubmit choose1 vBchannelKey2, Right Button|Skill 1|Skill 2|Skill 3|Skill 4|Force Move|Force Stand|Skill 5  ;vBchannelKey2  
    
	Gui, Add, Text, x210 y50 w40 h20, 1:
	Gui, Add, CheckBox, x230 y47 w40 h20 vBAuto1, Auto ;vBAuto1
    Gui, Add, Edit, x275 y47 w35 h20 Limit5 Number vBDelay1, 100 ;vBDelay1
    Gui, Add, Edit, x315 y47 w35 h20 Limit5 Number vBDelay12, 0 ;vBDelay12
	Gui, Add, CheckBox, x355 y47 w40 h20 vBKeep1, Continue ;
    GuiControl, Hide, BKeep1
    
	Gui, Add, Text, x210 y80 w40 h20, 2:
	Gui, Add, CheckBox, x230 y77 w40 h20 vBAuto2, Auto ;vBAuto2
    Gui, Add, Edit, x275 y77 w35 h20 Limit5 Number vBDelay2, 100 ;vBDelay2
    Gui, Add, Edit, x315 y77 w35 h20 Limit5 Number vBDelay22, 0 ;vBDelay22
	Gui, Add, CheckBox, x355 y77 w40 h20 vBKeep2, Continue ;vBAuto2
    GuiControl, Hide, BKeep2
    
    Gui, Add, Text, x395 y50 w40 h20, 3:
	Gui, Add, CheckBox, x415 y47 w40 h20 checked vBAuto3, Auto ;vBAuto3
    Gui, Add, Edit, x460 y47 w35 h20 Limit5 Number vBDelay3, 100 ;vBDelay3
    Gui, Add, Edit, x500 y47 w35 h20 Limit5 Number vBDelay32, 0 ;vBDelay32
	Gui, Add, CheckBox, x540 y47 w40 h20  vBKeep3, Continue ;vBAuto3
    GuiControl, Hide, BKeep3
    ;Gui, Add, Text, x375 y50 w40 h20, 3:
	;Gui, Add, CheckBox, x395 y47 w40 h20 checked vBAuto3, Auto ;vBAuto3
	;Gui, Add, Edit, x440 y47 w35 h20 Limit5 Number vBDelay3, 100 ;vBDelay3
	;Gui, Add, Edit, x480 y47 w35 h20 Limit5 Number vBDelay32, 0 ;vBDelay32
    
    Gui, Add, Text, x395 y80 w40 h20, 4:
	Gui, Add, CheckBox, x415 y77 w40 h20 checked vBAuto4, Auto ;vBAuto4
    Gui, Add, Edit, x460 y77 w35 h20 Limit5 Number vBDelay4, 100 ;vBDelay4
    Gui, Add, Edit, x500 y77 w35 h20 Limit5 Number vBDelay42, 0 ;vBDelay42
	Gui, Add, CheckBox, x540 y77 w40 h20  vBKeep4, Continue ;vBAuto4
    GuiControl, Hide, BKeep4
    
	Gui, Add, Text, x210 y110 w60 h20, Left:
	Gui, Add, CheckBox, x230 y107 w40 h20 vBAutoL, Auto ;vBAutoL
    Gui, Add, Edit, x275 y107 w35 h20 Limit5 Number vBDelayL, 100 ;vBDelayL
    Gui, Add, Edit, x315 y107 w35 h20 Limit5 Number vBDelayL2, 0 ;vBDelayL2
	Gui, Add, CheckBox, x355 y107 w40 h20 vBKeepL, Continue ;vBAutoL
    GuiControl, Hide, BKeepL
    
	Gui, Add, Text, x395 y110 w60 h20, Right:
	Gui, Add, CheckBox, x415 y107 w40 h20 vBAutoR, Auto ;vBAutoR
    Gui, Add, Edit, x460 y107 w35 h20 Limit5 Number vBDelayR, 100 ;vBDelayR
    Gui, Add, Edit, x500 y107 w35 h20 Limit5 Number vBDelayR2, 0 ;vBDelayR2
	Gui, Add, CheckBox, x540 y107 w40 h20 vBKeepR, Continue ;
    GuiControl, Hide, BKeepR    
    
	Gui, Add, Text, x395 y150 w60 h20, 5:
	Gui, Add, CheckBox, x415 y147 w40 h20 vBAutoMouseL, Auto ;
    Gui, Add, Edit, x460 y147 w35 h20 Limit5 Number vBDelayMouseL, 100 ;
    Gui, Add, Edit, x500 y147 w35 h20 Limit5 Number vBDelayMouseL2, 0 ;
	Gui, Add, CheckBox, x540 y147 w40 h20 vBKeepMouseL, Continue ;
    GuiControl, Hide, BKeepMouseL  

    ;--------------------------------------------------------------------------
      
    Gui, Add, Text, x585 y50 h20, Skill 1:
    Gui, Add, ComboBox, x655 y47 w40 h80 choose1 vBSkillKey1, %skillkye1Item%
    
    Gui, Add, Text, x585 y80 h20, Skill 2:
    Gui, Add, ComboBox, x655 y77 w40 h80 choose1 vBSkillKey2, %skillkye2Item%
    
    Gui, Add, Text, x585 y110 h20, Skill 3:
    Gui, Add, ComboBox, x655 y107 w40 h80 choose1 vBSkillKey3, %skillkye3Item%
    
    Gui, Add, Text, x585 y140 h20, Skill 4:
    Gui, Add, ComboBox, x655 y137 w40 h80 choose1 vBSkillKey4, %skillkye4Item%
    
    Gui, Add, Text, x585 y170 h20, Force Move:
    Gui, Add, ComboBox, x655 y167 w40 h80 choose1 vBMoveKey, %moveItem%
    
    Gui, Add, Text, x585 y200 h20, Force Stand Still:
    Gui, Add, ComboBox, x655 y197 w40 h80 choose1 vBStandKey, %standItem%
    
    ;Gui, Add, Text, x585 y230 h20, Dodge Skill:
    ;Gui, Add, ComboBox, x655 y227 w40 h80 choose1 vBAvoidKey, %avoidItem%
    
    Gui, Add, Text, x585 y230 h20, Skill 5:
    Gui, Add, ComboBox,  x655 y227 w40 h80 choose1 vBLMouseKey, %lmouseItem%
    
    ;Gui, Add, Text, x585 y260 h20, Left Button Skill:
    ;Gui, Add, ComboBox, x655 y257 w40 h80 choose1 vBLMouseKey, %lmouseItem%
    
    Gui, Add, Text, x460 y260 h20 vBHorseLabel, Mount Skill:
    Gui, Add, ComboBox, x530 y257 w40 h80 choose1 vBHorseKey, %horseItem%
    GuiControl, Hide, BHorseLabel
    GuiControl, Hide, BHorseKey  
    ;--------------------------------------------------------------------------
    
	Gui, Add, Text, x25 y150 w60 h20, Left Button Hold
    Gui, Add, DropDownList, x80 y147 w75 gLMHSelectChange AltSubmit choose1 vBModeL, No Action|Force Move|Release Skill1|Release Skill2|Release Skill3|Release Skill4|%marceItems%|Continuous Left Click|Middle Button Switch| Dodge|Release Skill5
    Gui, Add, CheckBox, x165 y145 h20  vBStandL, Stand Still
    Gui, Add, CheckBox, x218 y145 h20 vBOnceL, Single
    
	Gui, Add, Text, x25 y180 w60 h20, Right Button Hold
	Gui, Add, DropDownList, x80 y177 w75 gRMHSelectChange AltSubmit choose1 vBModeR, No Action|Force Move|Release Skill1|Release Skill2|Release Skill3|Release Skill4|%marceItems%|Continuous Right Click|Middle Button Switch|Dodge|Release Skill5
    Gui, Add, CheckBox, x165 y175 h20 vBStandR, Stand Still
    Gui, Add, CheckBox, x218 y175 h20 vBOnceR, Single
    
	Gui, Add, Text, x270 y150 w60 h20, Left Button Release
	Gui, Add, DropDownList, x325 y147 w60 AltSubmit choose1 vBModeReleaseL, %marceItems%|No Action
    
	Gui, Add, Text, x270 y180 w60 h20, Right Button Release
	Gui, Add, DropDownList, x325 y177 w60 AltSubmit choose1 vBModeReleaseR, %marceItems%|No Action

    Gui, Add, Text, x25 y215 w60 h20, Display Mode:
    Gui, Add, DropDownList, x85 y212 AltSubmit choose1 vBDispMode, Windowed|Fullscreen  ;vBDispMode
    
    Gui, Add, Text, x25 y250 w60 h20, Left Double Click
	Gui, Add, DropDownList, x80 y247 w75 AltSubmit choose1 vBDClickL, %dclickItem%
    Gui, Add, DropDownList, x165 y247 w75 AltSubmit choose1 vBEnableDCL, %enableItem%
    
	Gui, Add, Text, x25 y280 w60 h20, Right Double Click
	Gui, Add, DropDownList, x80 y277 w75 AltSubmit choose1 vBDClickR, %dclickItem%
    Gui, Add, DropDownList, x165 y277 w75 AltSubmit choose1 vBEnableDCR, %enableItem%

    ;--------Mouse Wheel Settings--------------------------------------------------------
	Gui, Add, Text, x270 y250 w60 h20, Wheel Up
    Gui, Add, DropDownList, x325 y247 w75 AltSubmit choose1 vBWheelUp, %dclickItem%
    Gui, Add, DropDownList, x410 y247 w75 AltSubmit choose1 vBEnableWU, %enableItem%
    
	Gui, Add, Text, x270 y280 w60 h20, Wheel Down
    Gui, Add, DropDownList, x325 y277 w75 AltSubmit choose1 vBWheelDown, %dclickItem%
    Gui, Add, DropDownList, x410 y277 w75 AltSubmit choose1 vBEnableWD, %enableItem%
    ;--------------------------------------------------------------------------
    
	Gui, Add, Text, x410 y270 w60 h20 vBEnableLabel, Activation Setting
	Gui, Add, DropDownList, x465 y267 w80 AltSubmit choose1 vBEnableDoubleClick, Disable|When Running|When Not Running|Any Time
    GuiControl, Hide, BEnableLabel  
    GuiControl, Hide, BEnableDoubleClick  
    
    /*
    Gui Add, Button, x25 y197 h20 gSet_ForceMove, Force Move Settings
    Gui Add, Button, x125 y197 h20 gSet_PickUp, Continuous Pickup Settings
    */
    Gui Add, Button, x395 y177 h18 w60 gSet_ForceMove, Force Move Settings
    Gui Add, Button, x470 y177 h18 w60 gSet_PickUp, Continuous Click Settings
    ;--------------------------------------------------------------------------
    
    
    v_readme_mbutton := "Middle`r`nButton`r`nSwitch`r`nFunction`r`nSelection" 
    v_readme_mbutton := v_readme_mbutton "`r`n`"
    v_readme_mbutton := v_readme_mbutton "`r`n`"
    v_readme_mbutton := v_readme_mbutton "`r`n`"
    v_readme_mbutton := v_readme_mbutton "`r`n`"
    v_readme_mbutton := v_readme_mbutton "`r`n`"
    v_readme_mbutton := v_readme_mbutton "`r`n`"
    v_readme_mbutton := v_readme_mbutton "`r`n`  (Use Ctrl to select or deselect)"
    Gui, Add, Text, x557 y285 h20, %v_readme_mbutton%
    Gui, Add, ListBox, x575 y285 w120 h170 Multi AltSubmit choose0 vBMButton, Channel Key1 On/Off|Channel Key2 On/Off|Left Auto/Stop|Right Auto/Stop|Skill1 Auto/Stop|Skill2 Auto/Stop|Skill3 Auto/Stop|Skill4 Auto/Stop |Custom Macro1 On/Off|Custom Macro2 On/Off|Custom Macro3 On/Off|Custom Macro4 On/Off|Custom Macro5 On/Off|Skill5 On/Off
    
    Gui, Add, Text, x580 y475 h20, Middle Button Switch Mode:
    Gui, Add, DropDownList, x515 y495 W180 AltSubmit choose1 vBMButtonRelease, Click middle to switch, click again to restore|Hold middle to switch, release middle to restore
    ;--------------------------------------------------------------------------
    
    ;Gui, Add, Text, x320 y260 w60 h20, Auto Start
    Gui, Add, Text, x25 y340 w70 h20, Auto Start Macro1
    Gui, Add, CheckBox, x100 y335 h20 vBMarcoAS1,
    
    Gui, Add, Text, x130 y340 w70 h20, Auto Start Macro2
    Gui, Add, CheckBox, x205 y335 h20 vBMarcoAS2,
    
    Gui, Add, Text, x235 y340 w70 h20, Auto Start Macro3
    Gui, Add, CheckBox, x310 y335 h20 vBMarcoAS3,
    
    Gui, Add, Text, x340 y340 w70 h20, Auto Start Macro4
    Gui, Add, CheckBox, x415 y335 h20 vBMarcoAS4,
    
    Gui, Add, Text, x455 y340 w70 h20, Auto Start Macro5
    Gui, Add, CheckBox, x530 y335 h20 vBMarcoAS5,
    
    ;--------------------------------------------------------------------------
    
    Gui, Add, DropDownList, x25 y375 w80 AltSubmit choose1 vBChooseMarco, %marceItem%
    Gui Add, Button, x110 y374 h20 gSet_UserMarco, Click to Configure
    Gui, Add, Text, x200 y379 h20, Custom Hotkey. When not checked as single, press once to start, press again to stop macro
    
    ;--------------------------------------------------------------------------

    ; Hotkey input box + function dropdown + register button
    Gui Add, Text, x25 y417 w50, Hotkey:
    Gui Add, Edit, x62 y414 w40 h20 vHotkey, W          ; Hotkey input box (default F1)

    ;Gui Add, Text, x152 y12 w50, Function:
    ;Gui Add, DropDownList, x202 y10 w100 vFuncName, Function A|Function B|Function C  ; Dropdown function
    Gui, Add, DropDownList, x112 y415 w80 AltSubmit choose1 vFuncName, %marceItem%

    Gui Add, Button, x200 y414 w80 h20 gHotKeyRegister, Register Hotkey  ; Register button
    
    ;--------------------------------------------------------------------------
    tip_info_1 := "When left/right button hold is set to custom macro X, you can select custom macro Y in left/right button release to close macro X content"
    tip_info_1 := tip_info_1 "`r`n# Example: Left button hold (Macro1) opens Skill 2 continuous, left button release (Macro2) closes mouse continuous;"
    tip_info_1 := tip_info_1 "`r`n# Example: Left button custom macro presses shift, left button release (Macro2) releases shift;"
    tip_info_1 := tip_info_1 "`r`n# Example: Left button custom macro clicks Skill1, left button release can be set to no action;"
    Gui, Add, Text, x25 y455 h50, %tip_info_1%
    
    ;--------------------------------------------------------------------------
    Gui, Add, CheckBox, x225 y490 h20 vBCancelDC, Double click middle button to auto mount
    GuiControl, Hide, BCancelDC
    Gui, Add, CheckBox, x25 y490 w70 h20 vBAutoPotion, Auto Potion ;vBAutoPotion
    GuiControl, Hide, BAutoPotion
    Gui, Add, Edit, x100 y490 w35 h20 Limit5 Number vBPotionDelay1, 100 ;vBPotionDelay1
    GuiControl, Hide, BPotionDelay1
    ;Gui, Add, Text, x140 y493 h50, "Potion key is Q, lazy to make, don't use if not Q"
    
    Gui, Add, CheckBox, x25 y510 h20 vBEnableStatus gEnableStatusChange, Show Macro Running Status (for some BD not auto press, can't intuitively see if macro is running) 
    ;--------------------------------------------------------------------------
    
    ;This parameter is used for side button 2 function replacement
    Gui, Add, CheckBox, x25 y530 h20 vBEnableGreatRift, Temporarily Disabled ;Mouse side button 2 function, unchecked: left continuous pickup; checked: force move
    GuiControl, Hide, BEnableGreatRift
    ;--------------------------------------------------------------------------
    
    Gui, Add, CheckBox, x25 y550 h20 vBEnableMouseGesture, Enable Mouse Gesture (Hold right button: down then right then up slide - open map) 
    GuiControl, Hide, BEnableMouseGesture
    ;--------------------------------------------------------------------------
    
    ;Gui Add, Button, x260 y137 h20 gSet_ForceMove, Force Move Settings
    ;Gui Add, Button, x260 y167 h20 gSet_PickUp, Continuous Pickup Settings
    ;--------------------------------------------------------------------------
    
    Gui, Add, Text, x575 y523 h20, Global Mouse Delay:
    Gui, Add, Edit, x660 y520 w20 h20 Limit2 Number vBGlobalMouseDelay, 10
    ;Gui, Add, Text, x385 y280 h20, (Recommended 5)

    Gui, Add, Text, x575 y553 h20, Global Keyboard Delay:
    Gui, Add, Edit, x660 y550 w20 h20 Limit2 Number vBGlobalKeyDelay, 10
   ; Gui, Add, Text, x385 y310 h20, (Recommended 5)
    
    ;--------------------------------------------------------------------------
   
	Gui, Add, GroupBox, x15 y620 w690 h235, Detailed Instructions, Please Read Carefully!
    v_readme := "# Toggle Macro: Mouse Side Button 1" 
    v_readme := v_readme "`r`n# -------------------------------------------------------------------------------------------"
    v_readme := v_readme "`r`n# [Recommended Keys]: Set Z as force move key; [.] key as force stand still key; 1,2,3,4 correspond to 4 skills, space dodge;"
    v_readme := v_readme "`r`n# [Recommended Keys]: Each key has two positions, as long as the above key settings guarantee one of them, you can directly use author's config;"
    v_readme := v_readme "`r`n# [Recommended Keys]: Set mount/dismount key to 9, dismount to 0. (Cancel original keys, otherwise easy conflict auto dismount when mounted)"
    v_readme := v_readme "`r`n# [Default Key]: Mouse side button 2, in D4 for mount/dismount, in LE for hold ctrl+right button"
    v_readme := v_readme "`r`n# [Save Settings]: After setting in main interface must click BD Save button to take effect, close the popped secondary window to save;"
    v_readme := v_readme "`r`n# [Middle Button Function]: Middle button is channel and each skill release/stop toggle switch; Hold Ctrl to multi-select or deselect;"
    v_readme := v_readme "`r`n# -----【Left/Right Button Function】: Click once left/right button = left/right button press -> release;---------"
    v_readme := v_readme "`r`n#  * Can set to: Force Move, Continuous Pickup, Release Skill, or execute custom macro content;"
    v_readme := v_readme "`r`n#  * Stand still option means force release certain skill in place; Only effective when release skill selected;"
    v_readme := v_readme "`r`n#  * Single option means only release certain skill or custom macro content once;"
    v_readme := v_readme "`r`n# -----【Custom Macro Function】:-------------------------------------------------"
    v_readme := v_readme "`r`n#  * Complex custom statements, write in external editor then copy line by line;"
    v_readme := v_readme "`r`n# -----【Other Notes】:-----------------------------------------------------"
    v_readme := v_readme "`r`n#  * Press T, M, I, S, ENTER these function keys, or switch to other programs, will auto stop macro;"
    v_readme := v_readme "`r`n#  * Multi BD use: Copy multiple cfg files and rename, set separately, can dynamic switch;"
    ;v_readme := v_readme "`r`n# -----------------------------------------------------------------------"
    Gui, Add, Text, x25 y640 w650 h200, %v_readme%
    
    /*
    ;;;;;;;;;Auto Settings Tab Content;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    Gui, Tab, 2
    
    Gui, Add, GroupBox, x15 y24 w690 h560, 
    
    Gui, Add, Text, x25 y50 w60 h20, Display Mode:
    Gui, Add, DropDownList, x85 y47 AltSubmit choose1 vBDispMode, Windowed|Fullscreen or Window Fullscreen  ;vBDispMode
    
    Gui, Add, Text, x25 y80 w60 h20, Execution Mode:
    Gui, Add, DropDownList, x85 y77 w100 AltSubmit choose1 vBEamon, Test Position|Actual Operation  ;vBEamon
    
    Gui, Add, Text, x25 y110 w60 h20, Mouse Key Delay:
    Gui, Add, Edit, x85 y107 w40 h20 Limit3 Number vBMouseDelay, 7 ;vBMouseDelay
    
    Gui, Add, Text, x25 y150 w60 h20, Peak Adjustment:
    Gui, Add, CheckBox, x85 y146 w40 h20 vBAttributeAdjust, Enable  
    Gui, Add, Text, x25 y180 w60 h20, Main Attribute:
    Gui, Add, Edit, x85 y177 w40 h20 Limit2 Number vBMainProp, 0  
    Gui, Add, Text, x125 y180 w60 h20, (Hundred Points)
    Gui, Add, Text, x25 y210 w60 h20, Stamina Attribute:
    Gui, Add, Edit, x85 y207 w40 h20 Limit2 Number vBStam, 0  
    Gui, Add, Text, x125 y210 w60 h20, (Hundred Points)
    Gui, Add, Text, x25 y240 w60 h20, Movement Speed:
    Gui, Add, Edit, x85 y237 w40 h20 Limit2 Number vBSpeed, 0  
    Gui, Add, Text, x125 y240 w60 h20, (Points)
    Gui, Add, Text, x25 y270 w60 h20, Energy Cap:
    Gui, Add, Edit, x85 y267 w40 h20 Limit2 Number vBEnergy, 0  
    Gui, Add, Text, x125 y270 w60 h20, (Points)
    
    Gui, Add, Text, x25 y300 w60 h20, Range Damage:
    Gui, Add, CheckBox, x85 y296 w40 h20 vBRangDamage, Enable 
    
    Gui, Add, Text, x25 y340 w90 h20, Gem Upgrade Count:
    Gui, Add, Edit, x115 y337 w40 h20 Limit1 Number vBUpgradeCount, 4  
    
    Gui, Add, Text, x25 y460 h20, Decompose Area Settings
    Gui, Add, DropDownList, x95 y457 w120 AltSubmit choose1 vBSmashType, Line by Line (Single Grid)|Every Other Line (Double Grid)
    
    Gui, Add, Text, x25 y490 h20, Protection Area Settings
    Gui, Add, DropDownList, x95 y487 w120 AltSubmit choose1 vBProtectZone, Last 5 Grids|Last 4 Grids|Last 3 Grids|Last 2 Grids|Last 1 Grid|None
    
    Gui, Add, Text, x25 y520 h20, Mouse Wheel Down (or F5), Auto Decompose, Magic Box, Gambling, Gem Upgrade Town Portal, Peak Points, Enchant, Open Greater Rift etc.

    Gui, Add, Text, x25 y550 h20, Auto Close All Pop-up Windows:
    Gui, Add, CheckBox, x160 y546 w40 h20 vBAutoCloseWin, Enable  
    GuiControl, Disable, BAutoCloseWin
    
    Gui, Add, Text, x260 y50 h20, Inventory Top Left X:
    Gui, Add, Edit, x340 y47 w40 h20 Limit5 Number vBItemSX, 0.728 ;vBItemSX
    
	Gui, Add, Text, x260 y80 h20, Inventory Top Left Y:
    Gui, Add, Edit, x340 y77 w40 h20 Limit5 Number vBItemSY, 0.511 ;vBItemSY
    
    Gui, Add, Text, x260 y110 h20, Inventory Bottom Right X:
    Gui, Add, Edit, x340 y107 w40 h20 Limit5 Number vBItemEX, 0.991 ;vBItemEX
    
	Gui, Add, Text, x260 y140 h20, Inventory Bottom Right Y:
    Gui, Add, Edit, x340 y137 w40 h20 Limit5 Number vBItemEY, 0.79 ;vBItemEY
    
    Gui, Add, Text, x260 y170 h20, Legendary Decompose Coord (X/Y）:
	Gui, Add, Edit, x380 y167 w40 h20  Limit5 Number vBOrangePosX, 0.088 
    Gui, Add, Edit, x430 y167 w40 h20 Limit5 Number vBOrangePosY, 0.264 
    
	Gui, Add, Text, x260 y200 h20, White Decompose Coord (X/Y）:
	Gui, Add, Edit, x380 y197 w40 h20  Limit5 Number vBWhitePosX, 0.135 
    Gui, Add, Edit, x430 y197 w40 h20 Limit5 Number vBWhitePosY, 0.268 
    
    Gui, Add, Text, x260 y230 h20, Blue Decompose Coord (X/Y）:
	Gui, Add, Edit, x380 y227 w40 h20  Limit5 Number vBBluePosX, 0.169
    Gui, Add, Edit, x430 y227 w40 h20 Limit5 Number vBBluePosY, 0.268 
    
    Gui, Add, Text, x260 y260 h20, Rare Decompose Coord (X/Y）:
	Gui, Add, Edit, x380 y257 w40 h20  Limit5 Number vBYellowPosX, 0.203 
    Gui, Add, Edit, x430 y257 w40 h20 Limit5 Number vBYellowPosY, 0.268 
    
    Gui, Add, Text, x260 y290 h20, Put Material Coord (X/Y）:
	Gui, Add, Edit, x380 y287 w40 h20  Limit5 Number vBPutPosX, 0.374 
    Gui, Add, Edit, x430 y287 w40 h20 Limit5 Number vBPutPosY, 0.778 
    
	Gui, Add, Text, x260 y320 h20, Reshape Button Coord (X/Y）:
	Gui, Add, Edit, x380 y317 w40 h20  Limit5 Number vBRebuildPosX, 0.125 
    Gui, Add, Edit, x430 y317 w40 h20 Limit5 Number vBRebuildPosY, 0.765 
    
    Gui, Add, Text, x260 y350 h20, Previous Page Coord (X/Y）:
	Gui, Add, Edit, x380 y347 w40 h20  Limit5 Number vBPrePosX, 0.303
    Gui, Add, Edit, x430 y347 w40 h20 Limit5 Number vBPrePosY, 0.778 
    
    Gui, Add, Text, x260 y380 h20, Next Page Coord (X/Y）:
	Gui, Add, Edit, x380 y377 w40 h20  Limit5 Number vBNextPosX, 0.445 
    Gui, Add, Edit, x430 y377 w40 h20 Limit5 Number vBNextPosY, 0.778 
    
    Gui Add, Button, x480 y377 h20 gRestore_AutoSet, Click to Restore Preset Values
    
    Gui, Add, GroupBox, x15 y580 w690 h275, Detailed Instructions, Please Read Carefully!
    v_readme := "# Suitable for 16:9 resolution (standard 720P, 1080P, 2K, 4K), other resolutions can use windowed mode and stretch to similar ratio;" 
    v_readme := v_readme "`r`n# ----------------------------------------------------------------------------------------------"
    v_readme := v_readme "`r`n# [Auto]: Mouse wheel down (or F5) is one-key full auto function, must first open corresponding function interface then press"
    v_readme := v_readme "`r`n# * Auto close all pop-up windows (must set keybind -> [Close all open windows] to F10);"
    v_readme := v_readme "`r`n# * One-key full auto function includes decompose, discard, magic box, gambling, gem upgrade town portal, peak switch, enchant etc.;"
    v_readme := v_readme "`r`n# * Auto gem upgrade + town portal, select gem to upgrade, move mouse to empty space, wheel down, default click gem 4 times, can modify count;"
    v_readme := v_readme "`r`n# * Auto open Greater Rift (first time need manual select layer), mouse click rift stele, mouse wheel down;"
    v_readme := v_readme "`r`n# ----------------------------------------------------------------------------------------------"
    v_readme := v_readme "`r`n# [Manual]: If F5 auto scene recognition inaccurate, can use F9,F6,F7,F8 separately (see below);"
    v_readme := v_readme "`r`n# * F4 used to stop F5 (corresponding F9,F6,F7,F8) function midway;"
    v_readme := v_readme "`r`n# * F9 is right continuous click, used for town gambling; (original F3 function, changed to F9 to avoid conflict with navigation F3)"
    v_readme := v_readme "`r`n# * F6 is magic box function, please first switch to magic box page (supports one-key upgrade rare and convert material);"
    v_readme := v_readme "`r`n# * F7 key is one-key discard, open inventory (I), then press F7;"
    v_readme := v_readme "`r`n# * F8 key is one-key decompose, first click blacksmith, switch to decompose interface, then press F8;"
    v_readme := v_readme "`r`n# ----------------------------------------------------------------------------------------------"
    v_readme := v_readme "`r`n# [Note]:"
    v_readme := v_readme "`r`n# * Fullscreen/Window Fullscreen/Windowed, must select accurately;"
    v_readme := v_readme "`r`n# * Mouse key delay affected by network speed and hardware, recommend not lower than 2; lower value faster operation (may fail);"
    v_readme := v_readme "`r`n# * This function locates based on screen coord relative to game window ratio, can adjust yourself (not recommended); Can restore default;"
    v_readme := v_readme "`r`n# * ！！！！！Before actual operation please first test position to see if accurate, if not accurate please adjust first before use;"    
    v_readme := v_readme "`r`n# ----------------------------------------------------------------------------------------------"

    Gui, Add, Text, x25 y600 w650 h240, %v_readme%
    ;--------------------------------------------------------------------------
    */

    ;;;;;;;;;D2R Content;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    Gui, Tab, 2

    Gui, Add, GroupBox, x15 y24 w690 h560, 

    ;Gui, Add, Text, x25 y50 w60 h20, Window1:
    ;Gui, Add, Edit, x85 y47 w40 h20 Limit10 Number vBD2RWIN1, 0  
    Gui, Add, Text, x25 y50 w60 h20, Order
    Gui, Add, Text, x85 y50 w60 h20, Handle
    Gui, Add, Text, x185 y50 w60 h20, Join

    Gui, Add, Text, x25 y80 w60 h20, Window1:
    Gui, Add, Edit, x85 y77 w80 h20 Limit10 Number vBD2RWIN1, 0  
	Gui, Add, CheckBox, x185 y77 w40 h20 vBD2RJoin1, ;
  
    Gui, Add, Text, x25 y110 w60 h20, Window2:
    Gui, Add, Edit, x85 y107 w80 h20 Limit10 Number vBD2RWIN2, 0  
	Gui, Add, CheckBox, x185 y107 w40 h20 vBD2RJoin2, ;

    Gui, Add, Text, x25 y140 w60 h20, Window3:
    Gui, Add, Edit, x85 y137 w80 h20 Limit10 Number vBD2RWIN3, 0  
	Gui, Add, CheckBox, x185 y137 w40 h20 vBD2RJoin3, ;

    Gui, Add, Text, x25 y170 w60 h20, Window4:
    Gui, Add, Edit, x85 y167 w80 h20 Limit10 Number vBD2RWIN4, 0  
	Gui, Add, CheckBox, x185 y167 w40 h20 vBD2RJoin4, ;

    Gui, Add, Text, x25 y200 w60 h20, Window5:
    Gui, Add, Edit, x85 y197 w80 h20 Limit10 Number vBD2RWIN5, 0  
	Gui, Add, CheckBox, x185 y197 w40 h20 vBD2RJoin5, ;

    Gui, Add, Text, x25 y230 w60 h20, Window6:
    Gui, Add, Edit, x85 y227 w80 h20 Limit10 Number vBD2RWIN6, 0  
	Gui, Add, CheckBox, x185 y227 w40 h20 vBD2RJoin6, ;

    Gui, Add, Text, x25 y260 w60 h20, Window7:
    Gui, Add, Edit, x85 y257 w80 h20 Limit10 Number vBD2RWIN7, 0  
	Gui, Add, CheckBox, x185 y257 w40 h20 vBD2RJoin7, ;

    Gui, Add, Text, x25 y290 w60 h20, Window8:
    Gui, Add, Edit, x85 y287 w80 h20 Limit10 Number vBD2RWIN8, 0  
	Gui, Add, CheckBox, x185 y287 w40 h20 vBD2RJoin8, ;

    Gui Add, Button, x25 y325 h18 w60 gGet_D2R_WIN_ALL, Get Windows

    ;Gui Add, Button, x25 y360 h18 w120 gGet_D2R_WIN_ALL1, Run D2R Shortcut
    Gui, Add, Button, x25 y360 w100 h20 gSelectD2RShortcuts, Select Shortcuts
    Gui, Add, ListBox, x25 y390 w300 h180 vBD2RShortCutList Multi
    Gui, Add, Button, x345 y390 gD2RMoveUp, Move Up
    Gui, Add, Button, x345 y420 gD2RMoveDown, Move Down
    Gui, Add, Edit, x400 y390 w20 h20 vBD2RBroswserSetPos, 5
    Gui, Add, Text, x425 y393 w200 h20, Input default browser setting item number
    Gui, Add, Edit, x400 y420 w100 h20 vBD2RBroswserListPos, 1,2,3,4,5,6,7,8
    Gui, Add, Text, x505 y423 w200 h20, Browser order (consistent with shortcuts)
    Gui, Add, Edit, x345 y460 w320 h20 vBD2RBroswserListName, edge,chrome,firefox,360,Q
    Gui, Add, Text, x345 y485 w320 h20, (WIN11 browser specific, fill in order of shortcuts, separated by ",")
    ;/*
    Gui, Add, Button, x140 y360 w80 h20 gMultiLaunchD2R, Launch International
    Gui, Add, Button, x235 y360 w80 h20 gMultiLaunchD2RCN, Launch CN Server
    Gui, Add, Button, x330 y360 w100 h20 gMultiLaunchD2RCNW11, Launch CN Server Win11  
    ;*/
    /*
    Gui, Add, Button, x140 y360 w80 h20 gMultiLaunchD2R, Launch D2R
    Gui, Add, Button, x235 y360 w80 h20 vBMultiLaunchD2RCN gMultiLaunchD2RCN, Launch CN Server
    GuiControl, Hide, BMultiLaunchD2RCN
    Gui, Add, Button, x330 y360 w100 h20 vBMultiLaunchD2RCNW11 gMultiLaunchD2RCNW11, Launch CN Server Win11
    GuiControl, Hide, BMultiLaunchD2RCNW11
    */
    ;Gui, Add, Button, x235 y360 w80 h20 vBLaunchD2RCN gMultiLaunchD2RCN, Launch CN Server
    ;GuiControl, Hide, BLaunchD2RCN
    ;Gui, Add, Button, x330 y360 w100 h20 vBLaunchD2RCNw11 gMultiLaunchD2RCNW11, Launch CN Server Win11
    ;GuiControl, Hide, BLaunchD2RCNW11
    
    ;Gui, Add, Button, x255 y360 w100 h20 gSaveD2RShortcuts, Save Settings
    Gui, Add, Text, x345 y540 w80 h20, Launch Interval:
    Gui, Add, Edit, x405 y537 w20 h20 Limit10 vBD2RLaunchDelay,  
    Gui, Add, Text, x430 y540 w20 h20, Seconds
    Gui Add, Button, x600 y537 w80 h20 gSaveD2RShortcuts, Save Settings
    ;Gui Add, Button, x600 y507 w80 h20 gChangeBrowserChrome, Test

    Gui, Add, Text, x350 y80 w80 h20, Host Window:
    Gui, Add, DropDownList, x410 y77 w100 AltSubmit choose1 vBD2RGameHostWin, Window1|Window2|Window3|Window4|Window5|Window6|Window7|Window8 
    Gui, Add, Text, x520 y80 w80 h20, Game Difficulty:
    Gui, Add, DropDownList, x580 y77 w100 AltSubmit choose3 vBD2RGameHostLevel, Normal|Nightmare|Hell 
    Gui, Add, Text, x350 y110 w80 h20, Room Name:
    Gui, Add, Edit, x410 y107 w100 h20 vBD2RHostName,  
    Gui, Add, Text, x520 y110 w80 h20, Room Password:
    Gui, Add, Edit, x580 y107 w100 h20 vBD2RHostPW, 
    Gui, Add, Text, x520 y140 w80 h20, Wait Time:
    Gui, Add, Edit, x580 y137 w100 h20 vBD2RHostDelay, 
    Gui, Add, Text, x350 y140 w80 h20, Join Only: 
	Gui, Add, CheckBox, x410 y137 w40 h20 vBD2ROnlyJoin, ;
    ; New exit wait setting (aligned with above, height match left "switch coord")
    Gui, Add, Text, x520 y170 w80 h20, Exit Wait:
    Gui, Add, Edit, x580 y167 w100 h20 vBD2RExitDelay, 1000  ; Default 1000 milliseconds, can modify as needed

    Gui, Add, Text, x350 y170 w80 h20, Toggle Coord:
    Gui, Add, Edit, x410 y167 w45 h20 vBD2RQuickToggleX, 0.7207
    Gui, Add, Edit, x465 y167 w45 h20 vBD2RQuickToggleY, 0.0402
    Gui, Add, Text, x350 y200 w80 h20, Create Menu:
    Gui, Add, Edit, x410 y197 w45 h20 vBD2RCreateMenuX, 0.68
    Gui, Add, Edit, x465 y197 w45 h20 vBD2RCreateMenuY, 0.0777
    Gui, Add, Text, x520 y200 w80 h20, Join Menu:
    Gui, Add, Edit, x580 y197 w45 h20 vBD2JoinMenuX, 0.7686
    Gui, Add, Edit, x635 y197 w45 h20 vBD2JoinMenuY, 0.0777
    Gui, Add, Text, x350 y230 w80 h20, Create Room Name:
    Gui, Add, Edit, x410 y227 w45 h20 vBD2RCreateNameX, 0.6952
    Gui, Add, Edit, x465 y227 w45 h20 vBD2RCreateNameY, 0.1694
    Gui, Add, Text, x520 y230 w80 h20, Create Button:
    Gui, Add, Edit, x580 y227 w45 h20 vBD2RCreateButtonX, 0.7615
    Gui, Add, Edit, x635 y227 w45 h20 vBD2RCreateButtonY, 0.6166
    ;Gui, Add, Text, x520 y230 w80 h20, Create Password:
    ;Gui, Add, Edit, x580 y227 w45 h20 vBD2CreatePassX, 0.7207
    ;Gui, Add, Edit, x635 y227 w45 h20 vBD2CreatePassY, 0.0312
    Gui, Add, Text, x350 y260 w80 h20, Normal Difficulty:
    Gui, Add, Edit, x410 y257 w45 h20 vBD2RNormalX, 0.698
    Gui, Add, Edit, x465 y257 w45 h20 vBD2RNormalY, 0.3527
    Gui, Add, Text, x520 y260 w80 h20, Nightmare Difficulty:
    Gui, Add, Edit, x580 y257 w45 h20 vBD2RNightMareX, 0.7604
    Gui, Add, Edit, x635 y257 w45 h20 vBD2RNightMaresY, 0.3527
    Gui, Add, Text, x350 y290 w80 h20, Hell Difficulty:
    Gui, Add, Edit, x410 y287 w45 h20 vBD2RHellX, 0.8227
    Gui, Add, Edit, x465 y287 w45 h20 vBD2RHellY, 0.3527
    /*
    Gui, Add, Text, x520 y290 w80 h20, Create Button:
    Gui, Add, Edit, x580 y287 w45 h20 vBD2RCreateButtonX, 0.7615
    Gui, Add, Edit, x635 y287 w45 h20 vBD2RCreateButtonY, 0.6166
    */
    Gui, Add, Text, x350 y320 w80 h20, Join Room Name:
    Gui, Add, Edit, x410 y317 w45 h20 vBD2RJoinNameX, 0.6807
    Gui, Add, Edit, x465 y317 w45 h20 vBD2RJoinNameY, 0.1465
    Gui, Add, Text, x520 y320 w80 h20, Join Button:
    Gui, Add, Edit, x580 y317 w45 h20 vBD2RJoinButtonX, 0.758
    Gui, Add, Edit, x635 y317 w45 h20 vBD2RJoinButtonY, 0.6194

    Gui Add, Button, x580 y350 w100 h20 gRestore_D2RQuickJoin, Click to Restore Preset Values
    /*
    Gui, Add, Text, x520 y330 w80 h20, Join Password:
    Gui, Add, Edit, x580 y327 w45 h20 vBD2RJoinPassX, 0.7207
    Gui, Add, Edit, x635 y327 w45 h20 vBD2RJoinPassY, 0.0312
    Gui, Add, Text, x520 y360 w80 h20, Join Button:
    Gui, Add, Edit, x580 y357 w45 h20 vBD2RJoinButtonX, 0.7207
    Gui, Add, Edit, x635 y357 w45 h20 vBD2RJoinButtonY, 0.0312
    */
    
    ;Gui Add, Button, x350 y170 h18 w120 gCreate_D2R_Game, Start Create/Join


    Gui, Add, GroupBox, x15 y580 w690 h275, Detailed Instructions, Please Read Carefully!
    v_readme := "# After launching game via shortcut will auto get window handle, or click get windows button to refresh handle" 
    v_readme := v_readme "`r`n# ----------------------------------------------------------------------------------------------"
    v_readme := v_readme "`r`n# Switch window hotkeys: Alt+1, +2, +3……"
    v_readme := v_readme "`r`n# -------------------------------------------------------------------------Auto Create/Join Function as follows--"
    v_readme := v_readme "`r`n# During create/join game process, do not operate mouse/keyboard"
    v_readme := v_readme "`r`n# Default value for 2560x1440 windowed mode, same ratio resolution should work, if deviation please fine tune X/Y axis ratio of coord area, save"
    v_readme := v_readme "`r`n# Important: Must use MDK plugin, or author's integrated WILL.SD plugin pack (in file list), needs quick create/join game button in it"
    v_readme := v_readme "`r`n# Host window refers to the window used to create game room"
    v_readme := v_readme "`r`n# Window1-8 join checkboxes, checked will auto join specified name and password room"
    v_readme := v_readme "`r`n# Join Only: Do not create game, only join specified name and password room."
    v_readme := v_readme "`r`n# Important: Set room name to number, will auto +1 when create, rebuild game directly press F10, no need manual input name each time"
    v_readme := v_readme "`r`n# Create Game & Join Game Hotkey: In any D2 window press F10."
    v_readme := v_readme "`r`n# Want to use other launch method, can add in custom macro - custom statement, content: Gosub, F10"
    v_readme := v_readme "`r`n# -----------------------------------------------------------------------------Multi Window Function as follows--"
    v_readme := v_readme "`r`n# Used netizen's multi launch shortcut settings, set according to help document in [Multi Launch Shortcuts Settings] folder"
    v_readme := v_readme "`r`n# Shortcut list and launch interval (recommend 5 seconds+), need click save button"
    v_readme := v_readme "`r`n# In shortcut list hold Ctrl to multi select, multi select will launch multiple windows sequentially"
    v_readme := v_readme "`r`n# ----------------------------------------------------------------------------------------------"
    v_readme := v_readme "`r`n# Ctrl+B can quickly switch to macro interface"

    Gui, Add, Text, x25 y600 w650 h240, %v_readme%
    ;---------------------------------------------------------------------------------- 

    ;;;;;;;;;Config Switch;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    Gui, Tab, 3

    Gui, Add, GroupBox, x15 y24 w690 h560,   

    Gui Add, Button, x25 y50 w75 h23 gSelect_Config2, Quick Config 2
    Gui, Add, Text, x110 y55 W400 h23 vConfigPath2, %A_ScriptDir%\D4.sadan.cfg ;%SelectedFile2%

    Gui Add, Button, x25 y80 w75 h23 gSelect_Config3, Quick Config 3
    Gui, Add, Text, x110 y85 W400 h23 vConfigPath3, %A_ScriptDir%\D4.sadan.cfg ;%SelectedFile3%

    Gui Add, Button, x25 y110 w75 h23 gSelect_Config4, Quick Config 4
    Gui, Add, Text, x110 y115 W400 h23 vConfigPath4, %A_ScriptDir%\D4.sadan.cfg ;%SelectedFile4%

    Gui Add, Button, x25 y140 w75 h23 gSelect_Config5, Quick Config 5
    Gui, Add, Text, x110 y145 W400 h23 vConfigPath5, %A_ScriptDir%\D4.sadan.cfg ;%SelectedFil5%

    Gui Add, Button, x25 y170 w75 h23 gSelect_Config6, Quick Config 6
    Gui, Add, Text, x110 y175 W400 h23 vConfigPath6, %A_ScriptDir%\D4.sadan.cfg ;%SelectedFile6%

    Gui Add, Button, x25 y200 w75 h23 gSelect_Config7, Quick Config 7
    Gui, Add, Text, x110 y205 W400 h23 vConfigPath7, %A_ScriptDir%\D4.sadan.cfg ;%SelectedFile7%

    Gui Add, Button, x25 y230 w75 h23 gSelect_Config8, Quick Config 8
    Gui, Add, Text, x110 y235 W400 h23 vConfigPath8, %A_ScriptDir%\D4.sadan.cfg ;%SelectedFile8%


    Gui, Add, GroupBox, x15 y580 w690 h275, Detailed Instructions, Please Read Carefully!
    v_readme := "# Add multiple backup configs for quick switch" 
    v_readme := v_readme "`r`n# ----------------------------------------------------------------------------------------------"
    v_readme := v_readme "`r`n# Switch config hotkeys: Main config Ctrl+1, backup configs Ctrl+2, +3……"
    v_readme := v_readme "`r`n# When modifying/debugging config file, do not use hotkey to switch config"
    v_readme := v_readme "`r`n# Because all modified content will be saved to main config file, if forget switch back to main config when modifying, will overwrite main config cannot restore"
    v_readme := v_readme "`r`n# Ctrl+B switch to macro interface"
    v_readme := v_readme "`r`n# ----------------------------------------------------------------------------------------------"

    Gui, Add, Text, x25 y600 w650 h240, %v_readme%
    ;---------------------------------------------------------------------------------- 
    
    ;;;;;;;;;Shout Settings Tab Content;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    Gui, Tab, 9
    ;--------------------------------------------------------------------------
    Gui, Add, Text, x25 y260 h20, Custom Hotkey
    Gui, Add, Text, x160 y260 w60 h20, Enable
    Gui, Add, Text, x192 y260 w60 h20, Single
    ;Gui, Add, Text, x220 y230 w60 h20, Auto Start
    
	Gui, Add, Edit, x25 y277 w50 h20 vBHotkey3
	Gui, Add, DropDownList, x80 y277 w75 AltSubmit choose1 vBMode3, %marceItem%
    Gui, Add, CheckBox, x165 y277 h20 vBStand3, 
    Gui, Add, CheckBox, x200 y277 h20 vBOnce3, 
    ;Gui, Add, CheckBox, x225 y250 gOnCheckAS3 vBAutoStart3, 
    
	Gui, Add, Edit, x25 y307 w50 h20 vBHotkey4
	Gui, Add, DropDownList, x80 y307 w75 AltSubmit choose1 vBMode4, %marceItem%
    Gui, Add, CheckBox, x165 y307 h20 vBStand4, 
    Gui, Add, CheckBox, x200 y307 h20 vBOnce4, 
    ;Gui, Add, CheckBox, x225 y280 gOnCheckAS4 vBAutoStart4, 
    
	Gui, Add, Edit, x25 y337 w50 h20 vBHotkey5
	Gui, Add, DropDownList, x80 y337 w75 AltSubmit choose1 vBMode5, %marceItem%
    Gui, Add, CheckBox, x165 y337 h20 vBStand5, 
    Gui, Add, CheckBox, x200 y337 h20 vBOnce5, 
    ;Gui, Add, CheckBox, x225 y310 gOnCheckAS5 vBAutoStart5, 
    ;--------------------------------------------------------------------------
    
    Gui, Add, GroupBox, x15 y24 w690 h600, 
    
    Gui, Add, Text, x25 y50 h20, 【ALT+1 or Numpad1】
    Gui, Add, Edit, x135 y47 w370 h20 vBAutoEnter1
    
    Gui, Add, Text, x25 y80 h20, 【ALT+2 or Numpad2】
    Gui, Add, Edit, x135 y77 w370 h20 vBAutoEnter2
    
    Gui, Add, Text, x25 y110 h20, 【ALT+3 or Numpad3】
    Gui, Add, Edit, x135 y107 w370 h20 vBAutoEnter3
    
    Gui, Add, Text, x25 y140 h20, 【ALT+4 or Numpad4】
    Gui, Add, Edit, x135 y137 w370 h20 vBAutoEnter4
    
    Gui, Add, Text, x25 y170 h20, 【ALT+5 or Numpad5】
    Gui, Add, Edit, x135 y167 w370 h20 vBAutoEnter5
    
    Gui, Add, Text, x25 y200 h20, 【ALT+6 or Numpad6】
    Gui, Add, Edit, x135 y197 w370 h20 vBAutoEnter6
    
    Gui, Add, Text, x25 y230 h20, 【ALT+7 or Numpad7】
    Gui, Add, Edit, x135 y227 w370 h20 vBAutoEnter7
    
    Gui, Add, Text, x25 y260 h20, 【ALT+8 or Numpad8】
    Gui, Add, Edit, x135 y257 w370 h20 vBAutoEnter8
    
    Gui, Add, Text, x25 y290 h20, 【ALT+9 or Numpad9】
    Gui, Add, Edit, x135 y287 w370 h20 vBAutoEnter9
    
    Gui, Add, GroupBox, x15 y620 w690 h235, Detailed Instructions
    v_readme := "# Used for quick shout, set content yourself;" 
    v_readme := v_readme "`r`n# When macro status is on, custom shout takes effect;"
    v_readme := v_readme "`r`n# This function is paused;"
    Gui, Add, Text, x25 y640 w450 h120, %v_readme%
    
    ;;;;;;;;;Custom Code Tab Content;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    Gui, Tab, 5
    
    Gui, Add, GroupBox, x15 y24 w690 h600, 
            
    Gui, Add, Button, x25 y50 w75 h23 gSelect_UserFile, Select File
    Gui, Add, Text, x110 y55 W350 h23 vUserFilePath, After selection will reload program to load custom code
    
    Gui, Add, Edit, x25 y400 w100 h20 Multi vBTestMultiEDit, 100 
                
    i := 0
    loop
    {
        i := i+1
        if (i > 8)
            break
        
        yValue := 100 + ((i - 1) * 30)
        yValue2 := yValue - 3

        Gui, Add, Text, x25 y%yValue% h20, Hotkey%i%:
        Gui, Add, Edit, x75 y%yValue2% w80 h20 vBUserCodeHotkey%i% ;
        Gui, Add, Text, x160 y%yValue% h20, Subroutine Name:
        Gui, Add, Edit, x220 y%yValue2% w80 h20 vBUserCodeLabelName%i% ;
        Gui, Add, Button, x320 y%yValue2% h20 gLoad_UserFile vBLoadUserFile%i%, Click to Load
    }

    
    Gui, Add, GroupBox, x15 y620 w690 h235, Detailed Instructions
    v_readme := "# 【For those who don't understand AHK, please do not use this page function】" 
    v_readme := v_readme "`r`n# Open custom script file will auto load successfully."
    v_readme := v_readme "`r`n# Do not reopen, otherwise error, if modified custom file, reopen main program"
    v_readme := v_readme "`r`n# Please note naming and hotkey usage in custom script, do not conflict with main program"
    v_readme := v_readme "`r`n# If script does not write hotkey only subroutine, can use below area to specify hotkey and subroutine correspondence"
    v_readme := v_readme "`r`n# After new open program please manually open custom script file"
    v_readme := v_readme "`r`n# -------------------------------------------------------------------"
    v_readme := v_readme "`r`n# For example main program built-in F2,F5,F6,F7,F8 etc subroutines (hotkeys), can self set key to convenient use"
    v_readme := v_readme "`r`n# Can hotkey like S, correspond to subroutine F8, click load, can press S to achieve F8 function"
    v_readme := v_readme "`r`n# Can hotkey like XButton2 (mouse fifth button), correspond to subroutine F2, can replace F2"
    v_readme := v_readme "`r`n# Can hotkey like WheelUp (mouse wheel up), correspond to subroutine F5, can replace F5"
    Gui, Add, Text, x25 y640 w450 h150, %v_readme%
 
    ;Enter before first select config, if not select then default config----------------------------------------
    FileSelectFile, SelectedFile, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFile = "")
    {
        SelectedFile = %A_ScriptDir%\D4.sadan.cfg
        ;MsgBox, No config file selected, will use default config:`n%SelectedFile%
    }
    ;----------------------------------------------------------------------------------
 
    
    ;;;;;;;;Main Tab Settings;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    Gui, Tab, 1
    Gui Add, Button, x25 y580 w75 h23 gSelect_Config, Select Config
    Gui, Add, Text, x110 y585 W400 h23 vConfigPath, %SelectedFile%
    
    Gui Add, Button, x560 y580 w60 h23 gConfigDocument, BD Instructions
    Gui Add, Button, x630 y580 w60 h23 gConfigMainSave, BD Save 

	Gosub, ReadFile
    Gosub, ReadfileCommon
    Gosub, GetUserMarco
    Gosub, Get_D2R_WIN_ALL
    ;Gosub, StartInPeace\
 
	Gui, Show, w715 h860, D4.sadan

    Gosub, MyStatusGui
    
	return
}

Gosub, MyGUI

return

ShowTray:
{
	Menu, Tray, NoStandard
	Menu, Tray, Add, Settings
	Menu, Tray, Add, Exit
	Menu, Tray, Default, Settings
	Menu, Tray, Click, 1 ;Click to open tray icon
	Menu, Tray, Tip, D4.sadan
	Menu, Tray, Icon, , , 1 ;Keep unchanged
	return
}


Settings:
{
	Gui, Show,, D4.sadan
  	return
}

Exit:
{
    ;;;;;;;;;;;;;;;;;;;;;;;;Exit display image;;;;;;;;;;;;;;;;;;;;;;;
    /*
    Gdip_Shutdown(pToken)
    */
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ExitApp
	return
}

GuiClose:
{
	Gui, Submit, NoHide
	return
}
ConfigMainSave:
{
	Gui, Submit, NoHide
	Gosub, GetControlValue
	Gosub, SaveFile
    msgbox Config file saved successfully
    return
}

UserMarcoSet1GuiClose:
{
    Gui, UserMarcoSet1:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}

UserMarcoSet2GuiClose:
{
    Gui, UserMarcoSet2:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
UserMarcoSet3GuiClose:
{
    Gui, UserMarcoSet3:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
UserMarcoSet4GuiClose:
{
    Gui, UserMarcoSet4:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
UserMarcoSet5GuiClose:
{
    Gui, UserMarcoSet5:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
UserMarcoSet6GuiClose:
{
    Gui, UserMarcoSet6:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
UserMarcoSet7GuiClose:
{
    Gui, UserMarcoSet7:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
UserMarcoSet8GuiClose:
{
    Gui, UserMarcoSet8:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
UserMarcoSet9GuiClose:
{
    Gui, UserMarcoSet9:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
UserMarcoSet10GuiClose:
{
    Gui, UserMarcoSet10:Submit, NoHide
	Gosub, SaveFileUserMarco
    return
}
ForceMoveGuiClose:
{
    Gui, ForceMove:Submit, NoHide
	Gosub, SaveFileForceMove
    return
}
PickUpGuiClose:
{
    Gui, PickUp:Submit, NoHide
	Gosub, SaveFilePickUp
    return
}
ConfigDocumentWinGuiClose:
{
    Gui, ConfigDocumentWin:Submit, NoHide
	Gosub, SaveFileConfigDocumentWin
    return
}

;------------------------------------------------------------------------------------GUI >
;------------------------------------------------------------------------------------StartInPeace >
StartInPeace:
{
    SetTimer, LabelCheckInPeace, 5000
}
return
;------------------------------------------------------------------------------------StartInPeace End >
;------------------------------------------------------------------------------------Setting File >
Select_Config:
{
    FileSelectFile, SelectedFile, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFile = "")
    {
        SelectedFile = %A_ScriptDir%\D4.sadan.cfg
        ;MsgBox, No config file selected, will use default config:`n%SelectedFile%
    }
    GuiControl, , ConfigPath, %SelectedFile%
    Gosub, ReadFile
    Gosub, GetUserMarco
    return
}
Select_Config2:
{
    FileSelectFile, SelectedFileExtra, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFileExtra = "")
        SelectedFileExtra = %A_ScriptDir%\D4.sadan.cfg
    GuiControl, , ConfigPath2, %SelectedFileExtra%
    return
}
Select_Config3:
{
    FileSelectFile, SelectedFileExtra, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFileExtra = "")
        SelectedFileExtra = %A_ScriptDir%\D4.sadan.cfg
    GuiControl, , ConfigPath3, %SelectedFileExtra%
    return
}
Select_Config4:
{
    FileSelectFile, SelectedFileExtra, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFileExtra = "")
        SelectedFileExtra = %A_ScriptDir%\D4.sadan.cfg
    GuiControl, , ConfigPath4, %SelectedFileExtra%
    return
}
Select_Config5:
{
    FileSelectFile, SelectedFileExtra, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFileExtra = "")
        SelectedFileExtra = %A_ScriptDir%\D4.sadan.cfg
    GuiControl, , ConfigPath5, %SelectedFileExtra%
    return
}
Select_Config6:
{
    FileSelectFile, SelectedFileExtra, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFileExtra = "")
        SelectedFileExtra = %A_ScriptDir%\D4.sadan.cfg
    GuiControl, , ConfigPath6, %SelectedFileExtra%
    return
}
Select_Config7:
{
    FileSelectFile, SelectedFileExtra, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFileExtra = "")
        SelectedFileExtra = %A_ScriptDir%\D4.sadan.cfg
    GuiControl, , ConfigPath7, %SelectedFileExtra%
    return
}
Select_Config8:
{
    FileSelectFile, SelectedFileExtra, 3, , Open a file, Config Files (*.cfg)
    if (SelectedFileExtra = "")
        SelectedFileExtra = %A_ScriptDir%\D4.sadan.cfg
    GuiControl, , ConfigPath8, %SelectedFileExtra%
    return
}
;------------------------------------------------------------------------------------Select_UserFile >
;------------------------------------------------------------------------------------Select_UserFile >
Select_UserFile:
{
    FileSelectFile, SelectedUserFile, 3, , Open a file, AHK Files (*.ahk)
    if (SelectedUserFile = "")
    {   
        GuiControl, , UserFilePath, Please select custom AHK file
        return
    }
    else
    {
        /*
        GuiControl, , UserFilePath, %SelectedUserFile%
        FileDelete compiled.ahk
        loop read, %SelectedUserFile%
        {
            MsgBox Hotstring number %A_Index% is %A_LoopReadLine%.
            FileAppend %A_LoopReadLine%`n, compiled.ahk
        }
        reload
        */
        GuiControl, , UserFilePath, %SelectedUserFile%
        FileRead, OutputVar, %SelectedUserFile%
        ahkExec(outputvar)
        msgbox, "Load complete, custom script program can be used"
    }

    return
}
;------------------------------------------------------------------------------------Setting selectchange >
LMHSelectChange:
{
	GuiControlGet, BModeL
	if (BModeL >= 3 and BModeL <=6)
	{
		GuiControl, Enable, BStandL
	}
	else
	{
		GuiControl, Disable, BStandL
	}
    /*
    if (BModeL >= 7 and BModeL <=11)
    {
        GuiControl,,BOnceL,1
		GuiControl, Disable, BOnceL
    }
	else
	{
		GuiControl, Enable, BOnceL
	}
    */
	return
}
RMHSelectChange:
{
	GuiControlGet, BModeR
	if (BModeR >= 3 and BModeR <=6)
	{
		GuiControl, Enable, BStandR
	}
	else
	{
		GuiControl, Disable, BStandR
	}
    /*
    if (BModeR >= 7 and BModeR <=11)
    {
        GuiControl,,BOnceR,1
		GuiControl, Disable, BOnceR
    }
	else
	{
		GuiControl, Enable, BOnceR
	}
    */
	return
}
;------------------------------------------------------------------------------------Setting selectchange End>
;------------------------------------------------------------------------------------Setting AutoStartMarco >
OnCheckAS3:
{
    GuiControlGet, BAutoStart3
    if (BAutoStart3 = 0)
    {
        GuiControl, Enable, BHotkey3
        GuiControl, Enable, BStand3
        GuiControl, Enable, BOnce3
    }
    else
    {
        GuiControl, , BHotkey3,
        GuiControl, , BStand3, 0
        GuiControl, , BOnce3, 0
        GuiControl, Disable, BHotkey3
        GuiControl, Disable, BStand3
        GuiControl, Disable, BOnce3
    }
    return
}
OnCheckAS4:
{
    GuiControlGet, BAutoStart4
    if (BAutoStart4 = 0)
    {
        GuiControl, Enable, BHotkey4
        GuiControl, Enable, BStand4
        GuiControl, Enable, BOnce4
    }
    else
    {
        GuiControl, , BHotkey4, 
        GuiControl, , BStand4, 0
        GuiControl, , BOnce4, 0
        GuiControl, Disable, BHotkey4
        GuiControl, Disable, BStand4
        GuiControl, Disable, BOnce4
    }
    return
}
OnCheckAS5:
{
    GuiControlGet, BAutoStart5
    if (BAutoStart5 = 0)
    {
        GuiControl, Enable, BHotkey5
        GuiControl, Enable, BStand5
        GuiControl, Enable, BOnce5
    }
    else
    {
        GuiControl, , BHotkey5, 
        GuiControl, , BStand5, 0
        GuiControl, , BOnce5, 0
        GuiControl, Disable, BHotkey5
        GuiControl, Disable, BStand5
        GuiControl, Disable, BOnce5
    }
    return
}
;------------------------------------------------------------------------------------Setting AutoStartMarco End>
;------------------------------------------------------------------------------------Setting ForceMove >
Set_ForceMove:
{
    Gui ForceMove:New
    Gui +HwndWinForceMove    
    
    Gui, ForceMove:Add, Text, x260 y50 w60 h20, Skill1:
	Gui, ForceMove:Add, CheckBox, x320 y47 w80 h20 vBFMStopKey1, Stop Key ;
    
	Gui, ForceMove:Add, Text, x260 y80 w60 h20, Skill2:
	Gui, ForceMove:Add, CheckBox, x320 y77 w80 h20 vBFMStopKey2, Stop Key ;
    
    Gui, ForceMove:Add, Text, x260 y110 w60 h20, Skill3:
	Gui, ForceMove:Add, CheckBox, x320 y107 w80 h20 vBFMStopKey3, Stop Key ;
    
    Gui, ForceMove:Add, Text, x260 y140 w60 h20, Skill4:
	Gui, ForceMove:Add, CheckBox, x320 y137 w80 h20 vBFMStopKey4, Stop Key ;
    
    Gui, ForceMove:Add, Text, x260 y140 w60 h20, Left Skill:
	Gui, ForceMove:Add, CheckBox, x320 y137 w80 h20 vBFMStopKey5, Stop Key ;
    
	Gui, ForceMove:Add, Text, x25 y50 w60 h20, Channel Key1:
	Gui, ForceMove:Add, CheckBox, x85 y47 w80 h20 vBFMStopCH1, Stop Key ;
    
	Gui, ForceMove:Add, Text, x25 y80 w60 h20, Channel Key2:
	Gui, ForceMove:Add, CheckBox, x85 y77 w80 h20 vBFMStopCH2, Stop Key ;
    
	Gui, ForceMove:Add, Text, x25 y110 w60 h20, Left   Button:
	Gui, ForceMove:Add, CheckBox, x85 y107 w80 h20 vBFMStopLM, Stop Key ;
    
	Gui, ForceMove:Add, Text, x25 y140 w60 h20, Right   Button:
	Gui, ForceMove:Add, CheckBox, x85 y137 w80 h20 vBFMStopRM, Stop Key ;
    
    v_readme := "# When left or right button hold set to force move, which skills will stop auto release" 
    v_readme := v_readme "`r`n# When release left or right button, stopped auto release skills will resume release"

    Gui, ForceMove:Add, Text, x25 y250, %v_readme%
    
    Gosub, ReadFileForceMove
    
    Gui, ForceMove:Show, w500 h400, Force Move Settings

    return
}
;------------------------------------------------------------------------------------Setting ForceMove End >

;------------------------------------------------------------------------------------Setting PickUp >
Set_PickUp:
{
    Gui PickUp:New
    Gui +HwndWinPickUp 
    
    Gui, PickUp:Add, Text, x260 y50 w60 h20, Skill1:
	Gui, PickUp:Add, CheckBox, x320 y47 w80 h20 vBPUStopKey1, Stop Key ;
    
	Gui, PickUp:Add, Text, x260 y80 w60 h20, Skill2:
	Gui, PickUp:Add, CheckBox, x320 y77 w80 h20 vBPUStopKey2, Stop Key ;
    
    Gui, PickUp:Add, Text, x260 y110 w60 h20, Skill3:
	Gui, PickUp:Add, CheckBox, x320 y107 w80 h20 vBPUStopKey3, Stop Key ;
    
    Gui, PickUp:Add, Text, x260 y140 w60 h20, Skill4:
	Gui, PickUp:Add, CheckBox, x320 y137 w80 h20 vBPUStopKey4, Stop Key ;
    
    Gui, PickUp:Add, Text, x260 y170 w60 h20, Skill5:
	Gui, PickUp:Add, CheckBox, x320 y167 w80 h20 vBPUStopKey5, Stop Key ;
    
	Gui, PickUp:Add, Text, x25 y50 w60 h20, Channel Key1:
	Gui, PickUp:Add, CheckBox, x85 y47 w80 h20 vBPUStopCH1, Stop Key ;
    
	Gui, PickUp:Add, Text, x25 y80 w60 h20, Channel Key2:
	Gui, PickUp:Add, CheckBox, x85 y77 w80 h20 vBPUStopCH2, Stop Key ;
    
	Gui, PickUp:Add, Text, x25 y110 w60 h20, Left   Button:
	Gui, PickUp:Add, CheckBox, x85 y107 w80 h20 vBPUStopLM, Stop Key ;
    
	Gui, PickUp:Add, Text, x25 y140 w60 h20, Right   Button:
	Gui, PickUp:Add, CheckBox, x85 y137 w80 h20 vBPUStopRM, Stop Key ;
    
    v_readme := "# When left button hold set to continuous pickup, which skills will stop auto release" 
    v_readme := v_readme "`r`n# When release left button, stopped auto release skills will resume release"
    
    Gui, PickUp:Add, Text, x25 y250, %v_readme%
    
    Gosub, ReadFilePickUp
    
    Gui, PickUp:Show, w500 h400, Continuous Pickup Settings

    return
}
;------------------------------------------------------------------------------------Setting PickUp End >
;------------------------------------------------------------------------------------Setting ConfigDocument >
ConfigDocument:
{
    Gui ConfigDocumentWin:New
    Gui +HwndWinConfigDocument 
   
    Gui, ConfigDocumentWin:Add, Text, x25 y20 h20, Skill, Keybind, Build Instructions: 
    Gui, ConfigDocumentWin:Add, Edit,x25 y40 w450 h120 vBCfgDoc_Skill, 
   
    Gui, ConfigDocumentWin:Add, Text, x25 y180 h20, Operation Instructions: 
    Gui, ConfigDocumentWin:Add, Edit,x25 y200 w450 h300 vBCfgDoc_OP, 
    
    Gosub, ReadFileConfigDocument
    
    Gui, ConfigDocumentWin:Show, w500 h540, Config File Detailed Instructions
    return
}
;------------------------------------------------------------------------------------Setting ConfigDocument End>
;------------------------------------------------------------------------------------Setting UserMarco >
Set_UserMarco:
{
	GuiControlGet, BChooseMarco
    currentMarco := BChooseMarco
    marcoNum := currentMarco
    Gui UserMarcoSet%marcoNum%:New
    Gui +HwndWinUserMarco
    
    Gui UserMarcoSet%marcoNum%:Add, Button, x25 y25 w75 h23 gAdd_action1, Add Action
    Gui UserMarcoSet%marcoNum%:Add, Button, x110 y25 w75 h23 gDel_action1, Delete Action
    Gui UserMarcoSet%marcoNum%:Add, Text, x200 y20 h23 , When changing skill fill value: XY-N (e.g. 32-6) - means move skill at row 3 column 2 to below skill position 6,`r`nPress S to bring up skill selection panel, X is skill row, Y is column; N is skill bar position to replace (1-6)
    
    v_readme := "| Max actions can add:【 " actionArrayCount1 " 】"
    ;v_readme := v_readme "`r`n| All key values case insensitive"
    v_readme := v_readme "`r`n| Time unit is millisecond; 1 second = 1000"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| When click/hold/release key, fill content on right:"
    v_readme := v_readme "`r`n| 26 letters and numbers - fill directly;"
    v_readme := v_readme "`r`n| Left Button: LButton；Right Button: RButton；"
    v_readme := v_readme "`r`n| Middle Button: MButton；"
    v_readme := v_readme "`r`n| Mouse Fourth Button (Side): XButton1；"
    v_readme := v_readme "`r`n| Mouse Fifth Button (Side): XButton2；"
    v_readme := v_readme "`r`n| Mouse Wheel Down: WheelDown；"
    v_readme := v_readme "`r`n| Mouse Wheel Up: WheelUp；；"
    v_readme := v_readme "`r`n| Ctrl Key: Ctrl； Shift Key: Shift；"
    v_readme := v_readme "`r`n| Alt Key: Alt；Space: Space；Enter: Enter；"
    v_readme := v_readme "`r`n| Left Ctrl: LControl；Right Ctrl: LControl；"
    v_readme := v_readme "`r`n| Left Shift: LShift；Right Shift: RShift"
    v_readme := v_readme "`r`n| Left Alt: LAlt；Right Alt: RAlt；"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| For continuous skill or cancel, fill 1/2/3/4/L/R on right"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| Multiple keys fill: x,y,z"
    v_readme := v_readme "`r`n| x-Key;y-Interval;z-Count;"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| Mouse circle fill: x,y,z,a,b"
    v_readme := v_readme "`r`n| x-Angle;y-Distance (pixel value);z-Time interval;"
    v_readme := v_readme "`r`n| a-Key to send during circle;b-1 In place circle|2 Moving circle;"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| Mouse move fill: a,b,c"
    v_readme := v_readme "`r`n| a-X axis ratio/pixel value;y-Y axis ratio/pixel;"
    v_readme := v_readme "`r`n| c-1 Ratio|2 Pixel;"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| Force move key fill: %BMoveKey% Stand still key fill: %BStandKey%"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| Custom statement simple example:"
    ;v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| Skill1 macro name: Label1；"
    v_readme := v_readme "`r`n|    -> Delay value: BDelay1，BDelay12；"
    v_readme := v_readme "`r`n| Skill2 macro name: Label2；"
    v_readme := v_readme "`r`n|    -> Delay value: BDelay2，BDelay22；"
    v_readme := v_readme "`r`n| Skill3 macro name: Label3；"
    v_readme := v_readme "`r`n|    -> Delay value: BDelay3，BDelay32；"
    v_readme := v_readme "`r`n| Skill4 macro name: Label4；"
    v_readme := v_readme "`r`n|    -> Delay value: BDelay4，BDelay42；"
    v_readme := v_readme "`r`n| Left button macro name: MouseLButton；"
    v_readme := v_readme "`r`n|    -> Delay value: BDelayL，BDelayL2；"
    v_readme := v_readme "`r`n| Right button macro name: MouseRButton；"
    v_readme := v_readme "`r`n|    -> Delay value: BDelayR，BDelayR2；"
    v_readme := v_readme "`r`n| Middle button macro name: ~MButton；"
    v_readme := v_readme "`r`n| Skill5 macro name: LabelMouseL；"
    v_readme := v_readme "`r`n|    -> Delay value: BDelayMouseL，BDelayMouseL2；"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| SetTimer, Label1, 50"
    v_readme := v_readme "`r`n| -> Skill1 press every 50ms"
    v_readme := v_readme "`r`n| SetTimer, Label1, %BDelay1%"
    v_readme := v_readme "`r`n| -> Every interval (left box value) press once"
    v_readme := v_readme "`r`n| SetTimer, Label1, %BDelay12%"
    v_readme := v_readme "`r`n| -> Every interval (right box value) press once"
    v_readme := v_readme "`r`n| SetTimer, Label1, off"
    v_readme := v_readme "`r`n| -> Close Skill1 auto press"
    v_readme := v_readme "`r`n| GoSub MbuttonChangeStatus"
    v_readme := v_readme "`r`n| -> Equivalent to click middle button once"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| Wait time max not exceed 20 seconds(200000)"
    v_readme := v_readme "`r`n| ---------------------------"
    v_readme := v_readme "`r`n| After show info remember to close info correspondingly"
    Gui, UserMarcoSet%marcoNum%:Add, Text, x480 y60, %v_readme%
    
    Gui, UserMarcoSet%marcoNum%:Show, w780 h800, Custom Macro%marcoNum% Settings
    
    Gosub, ReadFileUserMarco

    return
}
;------------------------------------------------------------------------------------Setting UserMarco End >

;------------------------------------------------------------------------------------Restore_AutoSet >
Restore_AutoSet:
{
    GuiControl, , BItemSX, 0.728
    GuiControl, , BItemSY, 0.511
    GuiControl, , BItemEX, 0.991
    GuiControl, , BItemEY, 0.79
    GuiControl, , BOrangePosX, 0.088
    GuiControl, , BOrangePosY, 0.264
    GuiControl, , BWhitePosX, 0.135
    GuiControl, , BWhitePosY, 0.268
    GuiControl, , BBluePosX, 0.169
    GuiControl, , BBluePosY, 0.268
    GuiControl, , BYellowPosX, 0.203
    GuiControl, , BYellowPosY, 0.268
    GuiControl, , BPutPosX, 0.374
    GuiControl, , BPutPosY, 0.778
    GuiControl, , BRebuildPosX, 0.125
    GuiControl, , BRebuildPosY, 0.765
    GuiControl, , BPrePosX, 0.303
    GuiControl, , BPrePosY, 0.778
    GuiControl, , BNextPosX, 0.445
    GuiControl, , BNextPosY, 0.778

    return
}
;------------------------------------------------------------------------------------Restore_AutoSet End >

;------------------------------------------------------------------------------------Load_UserFile >
Load_UserFile:
{
    t_control := A_GuiControl
    i_index := substr(t_control, strlen(t_control), 1)
    GuiControlGet, BUserCodeHotkey%i_index%
    GuiControlGet, BUserCodeLabelName%i_index%

    t_key := BUserCodeHotkey%i_index%
    t_name := BUserCodeLabelName%i_index%
    if (IsLabel(t_name))
    {
        Hotkey, %t_key%, %t_name%
    	GuiControl, , %t_control%, Bind Success
        GuiControl, Disable,  %t_control%
        GuiControl, Disable,  BUserCodeHotkey%i_index%
        GuiControl, Disable,  BUserCodeLabelName%i_index%
    }
    else
    {
        Msgbox, "Not valid subroutine name, please check and input"
        return
    }

    return
}
;------------------------------------------------------------------------------------Load_UserFile End >


;------------------------------------------------------------------------------------Get_D2R_WIN_ALL >
Get_D2R_WIN_ALL:
{ 
    D2RWindows := GetD2RWindowsByCreationTime()
    ;D2RWindows := GetD2RWindowsByTaskbarOrder()
    d2rWindows_count := D2RWindows.MaxIndex()
    ;Msgbox, %d2rWindows_count%

    for index, hwnd in D2RWindows
    {
        WinGetTitle, title, ahk_id %hwnd%
        ;MsgBox, Window order %index%: Handle %hwnd%`nTitle: %title%
        GuiControl, , BD2RWIN%index%, %hwnd%
        GuiControl, , BD2RJoin%index%, 1
    }

    if (index = "")
        start_id := 0
    Else
        start_id := index

    while(start_id <= 8)
    {
        start_id := start_id + 1
        GuiControl, , BD2RWIN%start_id%, 0
        GuiControl, , BD2RJoin%start_id%, 0
    }

    return
}
GetD2RWindowsByCreationTime()
{
    WinGet, hwndList, List, Diablo II: Resurrected
    windows := []

    ; Get each window process creation time
    Loop, %hwndList%
    {
        hwnd := hwndList%A_Index%
        WinGet, pid, PID, ahk_id %hwnd%
        hProcess := DllCall("OpenProcess", "UInt", 0x1000, "Int", 0, "UInt", pid)
        if !hProcess
            continue

        ; Get process creation timestamp
        DllCall("GetProcessTimes", "Ptr", hProcess, "Int64*", creationTime, "Int64*", 0, "Int64*", 0, "Int64*", 0)
        DllCall("CloseHandle", "Ptr", hProcess)
        windows.Push({hwnd: hwnd, time: creationTime})
    }

    ; Sort by creation time (small to large)
    sorted := []
    for i, obj in windows
    {
        inserted := false
        for j, sortedObj in sorted
        {
            if (obj.time < sortedObj.time)
            {
                sorted.InsertAt(j, obj)
                inserted := true
                break
            }
        }
        if !inserted
            sorted.Push(obj)
    }

    ; Extract sorted handles
    result := []
    for i, obj in sorted
        result.Push(obj.hwnd)

    return result
}
GetD2RWindowsByTaskbarOrder()
{
    result := []

    ; Find taskbar
    WinGet, hTaskbar, ID, ahk_class Shell_TrayWnd
    if (!hTaskbar)
        return result

    ; Find ToolbarWindow32 in taskbar
    hToolbar := FindTaskbarToolbar(hTaskbar)
    if (!hToolbar)
        return result

    ; Toolbar button count
    SendMessage, 0x418, 0, 0,, ahk_id %hToolbar%  ; TB_BUTTONCOUNT
    btnCount := ErrorLevel

    VarSetCapacity(btn, 32, 0)

    Loop % btnCount
    {
        ; TB_GETBUTTON
        SendMessage, 0x417, A_Index-1, &btn,, ahk_id %hToolbar%
        if (ErrorLevel = 0)
            continue

        ; dwData usually stores HWND
        hwnd := NumGet(btn, A_PtrSize * 2, "Ptr")
        if (!hwnd)
            continue

        WinGet, exe, ProcessName, ahk_id %hwnd%
        if (exe != "Diablo II.exe")
            continue

        result.Push(hwnd)
    }

    return result
}
FindTaskbarToolbar(hTaskbar)
{
    WinGet, hRebar, ControlListHwnd, ahk_id %hTaskbar%

    Loop, Parse, hRebar, `n
    {
        hCtrl := A_LoopField
        WinGetClass, cls, ahk_id %hCtrl%

        if (cls = "ReBarWindow32")
        {
            ; ReBar below find Toolbar
            WinGet, childs, ControlListHwnd, ahk_id %hCtrl%
            Loop, Parse, childs, `n
            {
                h := A_LoopField
                WinGetClass, c, ahk_id %h%
                if (c = "ToolbarWindow32")
                    return h
            }
        }
    }
    return 0
}
;------------------------------------------------------------------------------------Get_D2R_WIN_ALL End >

;------------------------------------------------------------------------------------Restore_D2RQuickJoin >
Restore_D2RQuickJoin:
{
    GuiControl, , BD2RQuickToggleX, 0.7207
    GuiControl, , BD2RQuickToggleY, 0.0402
    GuiControl, , BD2RCreateMenuX, 0.68
    GuiControl, , BD2RCreateMenuY, 0.0777
    GuiControl, , BD2JoinMenuX, 0.7686
    GuiControl, , BD2JoinMenuY, 0.0777
    GuiControl, , BD2RCreateNameX, 0.6952
    GuiControl, , BD2RCreateNameY, 0.1694
    GuiControl, , BD2RCreateButtonX, 0.7615
    GuiControl, , BD2RCreateButtonY, 0.6166
    GuiControl, , BD2RNormalX, 0.698
    GuiControl, , BD2RNormalY, 0.3527
    GuiControl, , BD2RNightMareX, 0.7604
    GuiControl, , BD2RNightMaresY, 0.3527
    GuiControl, , BD2RHellX, 0.8227
    GuiControl, , BD2RHellY, 0.3527
    GuiControl, , BD2RJoinNameX, 0.6807
    GuiControl, , BD2RJoinNameY, 0.1465
    GuiControl, , BD2RJoinButtonX, 0.758
    GuiControl, , BD2RJoinButtonY, 0.6194

    return
}
;------------------------------------------------------------------------------------Restore_D2RQuickJoin End >

D2R_Check_GamePosition:
{
    /*
    0=in game；1=character screen；2=lobby screen
    PixelSearch, x, y, 0,0,A_ScreenWidth,A_ScreenHeight, 0x00FF00
    Judge left top：0.8359 0.9028
    Judge right bottom：0.8680 0.95

    Judge color1:  521818
    Judge color2： CFB277

    Create button： 0.5980 0.0403
    Join button： 0.6883 0.0403

    */
    global BServer, boss_Enable, D2R_GamePosition
    IfWinNotActive,%BServer%
    {
        return
    }

    WinGetPos, X, Y, current_Width, current_Height, %BServer%
    sysget titlebar_height, 4, %BServer%
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }

    ; Judge if lobby screen
    /*
    check_pos1x := current_Width*0.4857
    check_pos1y := (current_Height - titlebar_height)*0.1139
    check_pos2x := current_Width*0.5205
    check_pos2y := (current_Height - titlebar_height)*0.1639
    PixelSearch, x, y, check_pos1x,check_pos1y,check_pos2x,check_pos2y,0x71180C,3,Fast RGB 
    if !ErrorLevel 
    {
        D2R_GamePosition := 2
        Return
    }
    */
    
    /*
    0.0848 0.6870 
    0.1050 0.7250 
    0xD7BA7C

    0.3448 0.0546 0x0xC39757
    0.3562 0.0759 0x0x372B22
    0x72A9B8
    */
    ;/*
    check_pos1x := current_Width*0.0848
    check_pos1y := (current_Height - titlebar_height)*0.6870
    check_pos2x := current_Width*0.1050
    check_pos2y := (current_Height - titlebar_height)*0.7250
    PixelSearch, x, y, check_pos1x,check_pos1y,check_pos2x,check_pos2y,0xD7BA7C,3,Fast RGB
    if !ErrorLevel 
    {
        D2R_GamePosition := 2
        Return
    }
    ;*/

    ; Judge if character screen
    check_pos1x := current_Width*0.8359
    check_pos1y := (current_Height - titlebar_height)*0.9028
    check_pos2x := current_Width*0.8680
    check_pos2y := (current_Height - titlebar_height)*0.95
    PixelSearch, x, y, check_pos1x,check_pos1y,check_pos2x,check_pos2y,0x521818,3,Fast RGB 
    if !ErrorLevel 
    {
        PixelSearch, x, y, check_pos1x,check_pos1y,check_pos2x,check_pos2y,0x493218,3,Fast RGB 
        if !ErrorLevel 
        {
            D2R_GamePosition := 1
        }
        Else
        {
            D2R_GamePosition := 0
        }
    }
    Else
        D2R_GamePosition := 0
    
    Return
}
;------------------------------------------------------------------------------------Create_D2R_Game >
Create_D2R_Game111:
{
    ;Global create_d2r_toggle := 1
    GuiControlGet, BD2RGameHostWin 
    GuiControlGet, BD2RGameHostLevel
    GuiControlGet, BD2RHostName
    GuiControlGet, BD2RHostPW
    if (Strlen(BD2RHostName) < 3)
    {
        MsgBox, Room name must be more than two characters
        Return
    }
    GuiControlGet, BD2ROnlyJoin
    ;Wait host create time BD2RHostDelay
    GuiControlGet, BD2RHostDelay
    If (BD2RHostDelay is not Number)
        BD2RHostDelay := 500
    Else if (BD2RHostDelay < 300)
        BD2RHostDelay := 300
    Else if (BD2RHostDelay > 2000)
        BD2RHostDelay := 1000
    i := 1
    While (i <= 8) 
    {
        GuiControlGet, BD2RJoin%i%
        GuiControlGet, BD2RWIN%i%
        i := i+1
    }
    if (BD2ROnlyJoin != 1)
    {
        host_pid := ""
        if (BD2RGameHostWin = 1)
        {
            host_pid := BD2RWIN1
            WinActivate, ahk_id %BD2RWIN1%
        }
        if (BD2RGameHostWin = 2)
        {
            host_pid := BD2RWIN2
            WinActivate, ahk_id %BD2RWIN2%
        }
        if (BD2RGameHostWin = 3)
        {
            host_pid := BD2RWIN3
            WinActivate, ahk_id %BD2RWIN3%
        }
        if (BD2RGameHostWin = 4)
        {
            host_pid := BD2RWIN4
            WinActivate, ahk_id %BD2RWIN4%
        }
        if (BD2RGameHostWin = 5)
        {
            host_pid := BD2RWIN5
            WinActivate, ahk_id %BD2RWIN5%
        }
        if (BD2RGameHostWin = 6)
        {
            host_pid := BD2RWIN6
            WinActivate, ahk_id %BD2RWIN6%
        }
        if (BD2RGameHostWin = 7)
        {
            host_pid := BD2RWIN7
            WinActivate, ahk_id %BD2RWIN7%
        }
        if (BD2RGameHostWin = 8)
        {
            host_pid := BD2RWIN8
            WinActivate, ahk_id %BD2RWIN8%
        }
        Sleep, 100 ;Ensure window switched

        if WinExist("ahk_id " host_pid)
        {
            ;Handle create game
            ;Press space close window
            Send {Space}
            Sleep, 100

            D2R_GamePosition := 0
            Gosub D2R_Check_GamePosition
            ;Detect if quick menu already opened
            if (D2R_GamePosition = 0)
            {
                MoveYourMouse(BD2RQuickToggleX, BD2RQuickToggleY, 1)
                Sleep, 100
                MouseClick, L
                Sleep, 100
            }

            ;Click left right left sequentially
            if (D2R_GamePosition = 0)
            {
                MoveYourMouse(BD2RCreateMenuX, BD2RCreateMenuY, 1)
            }
            Else
            {
                MoveYourMouse(0.5980, 0.0403, 1)
            }
            Sleep, 100
            MouseClick, L
            Sleep, 100


            ;Game name
            if BD2RHostName is Number
            {
                BD2RHostName++
                GuiControl, , BD2RHostName, %BD2RHostName%
            }
            MoveYourMouse(BD2RCreateNameX, BD2RCreateNameY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            Send, ^a
            Sleep, 100
            Send, {Delete} 
            Sleep, 100
            Clipboard := ""
            Clipboard := BD2RHostName
            ClipWait, 1
            Sleep, 100
            Send, ^v
            Sleep, 100

            Send, {Tab}
            ;Game password
            if (StrLen(BD2RHostPW) > 0)
            {
                Sleep, 100
                Send, ^a
                Sleep, 100
                Send, {Delete} 
                Sleep, 100
                Clipboard := ""
                Clipboard := BD2RHostPW
                ClipWait, 2
                Send, ^v
            }
            Sleep, 100

            ;Select difficulty
            if (BD2RGameHostLevel = 1)
                MoveYourMouse(BD2RNormalX, BD2RNormalY, 1)
            if (BD2RGameHostLevel = 2)
                MoveYourMouse(BD2RNightMareX, BD2RNightMaresY, 1)
            if (BD2RGameHostLevel = 3)
                MoveYourMouse(BD2RHellX, BD2RHellY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            
            ;Start create
            Send, {Enter}
            Sleep, 300
        }
        Else
        {
            MsgBox, Host window not exist, PID: %host_pid%
            Return ;If host window not exist, stop create
        }
        
        Sleep, %BD2RHostDelay% ;After create, wait a bit to avoid join fail
    }
    i := 1
    While (i <= 8) 
    {
        if (create_d2r_toggle = 0)
            Return
        if (BD2RJoin%i% = 1)
        {
            ;Process, Exist, BD2RWIN%i%
            join_pid := BD2RWIN%i%
            if (join_pid = host_pid and BD2ROnlyJoin != 1)
            {
                i := i+1
                Continue
            }
            if WinExist("ahk_id " join_pid)
            {
                WinActivate, ahk_id %join_pid%
                Sleep, 100
                ;Handle join game111
                ;Press space close window
                Send {Space}
                Sleep, 100
                
                D2R_GamePosition := 0
                Gosub D2R_Check_GamePosition
                ;Detect if quick menu already opened
                if (D2R_GamePosition = 0)
                {
                    MoveYourMouse(BD2RQuickToggleX, BD2RQuickToggleY, 1)
                    Sleep, 100
                    MouseClick, L
                    Sleep, 100
                }

                ;Click right left right sequentially
                if (D2R_GamePosition = 0)
                    MoveYourMouse(BD2JoinMenuX, BD2JoinMenuY, 1)
                Else
                    MoveYourMouse(0.6883, 0.0403, 1)
                Sleep, 100
                MouseClick, L
                Sleep, 100

                ;Game name
                MoveYourMouse(BD2RJoinNameX, BD2RJoinNameY, 1)
                Sleep, 100
                MouseClick, L
                Sleep, 100
                Send, ^a
                Sleep, 100
                Send, {Delete} 
                Sleep, 100
                Clipboard := BD2RHostName
                ClipWait, 1
                Sleep, 100
                Send, ^v
                Sleep, 100
    
                Send, {Tab}
                ;Game password
                if (StrLen(BD2RHostPW) > 0)
                {
                    Sleep, 100
                    Send, ^a
                    Sleep, 100
                    Send, {Delete} 
                    Sleep, 100
                    Clipboard := BD2RHostPW
                    ClipWait, 1
                    Send, ^v
                }
                Sleep, 100

                Send, {Enter}
                Sleep, 200
            }
        }
        i := i+1
    }

    if (BD2ROnlyJoin != 1)
    {
        if WinExist("ahk_id " host_pid)
        {
            Sleep, 100
            WinActivate, ahk_id %host_pid%
        }
    }

    Return
}
;------------------------------------------------------------------------------------Create_D2R_Game End >

;------------------------------------------------------------------------------------Create_D2R_Game_DC >
Create_D2R_Game_DC111:
{
    GuiControlGet, BD2RGameHostWin 
    GuiControlGet, BD2RGameHostLevel
    GuiControlGet, BD2RHostName
    ;BD2RHostName := "DC-"
    GuiControlGet, BD2RHostPW
    GuiControlGet, BD2ROnlyJoin
    i := 1
    While (i <= 8) 
    {
        GuiControlGet, BD2RJoin%i%
        GuiControlGet, BD2RWIN%i%
        i := i+1
    }

    i := 1
    While (i <= 8) 
    {
        join_pid := BD2RWIN%i%
        if WinExist("ahk_id " join_pid)
        {
            WinActivate, ahk_id %join_pid%
            Sleep, 100
            ;Handle join game111
            ;Press space close window
            Send {Space}
            Sleep, 100
            
            D2R_GamePosition := 0
            Gosub D2R_Check_GamePosition
            ;Detect if quick menu already opened
            if (D2R_GamePosition = 0)
            {
                MoveYourMouse(BD2RQuickToggleX, BD2RQuickToggleY, 1)
                Sleep, 100
                MouseClick, L
                Sleep, 100
            }

            ;Click left right left sequentially
            if (D2R_GamePosition = 0)
                MoveYourMouse(BD2RCreateMenuX, BD2RCreateMenuY, 1)
            Else
                MoveYourMouse(0.5980, 0.0403, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            /*
            MoveYourMouse(BD2JoinMenuX, BD2JoinMenuY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            MoveYourMouse(BD2RCreateMenuX, BD2RCreateMenuY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            */

            ;Game name
            if BD2RHostName is Number
            {
                BD2RHostName++
                GuiControl, , BD2RHostName, %BD2RHostName%
            }
            Else
                BD2RHostName .= "1"
            /*
            Loop 5 {
                Random, digit, 0, 9
                rand .= digit
            }
            BD2RHostName .= rand
            */
            MoveYourMouse(BD2RCreateNameX, BD2RCreateNameY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            Send, ^a
            Sleep, 100
            Send, {Delete} 
            Sleep, 100
            Clipboard := BD2RHostName
            ClipWait, 1
            Send, ^v
            Sleep, 100

            Send, {Tab}
            ;Game password
            if (StrLen(BD2RHostPW) > 0)
            {
                Sleep, 100
                Send, ^a
                Sleep, 100
                Send, {Delete} 
                Sleep, 100
                Clipboard := BD2RHostPW
                ClipWait, 1
                Send, ^v
            }
            Sleep, 100

            ;Select difficulty
            if (BD2RGameHostLevel = 1)
                MoveYourMouse(BD2RNormalX, BD2RNormalY, 1)
            if (BD2RGameHostLevel = 2)
                MoveYourMouse(BD2RNightMareX, BD2RNightMaresY, 1)
            if (BD2RGameHostLevel = 3)
                MoveYourMouse(BD2RHellX, BD2RHellY, 1)
            Sleep, 50
            MouseClick, L
            Sleep, 100

            ;Start create
            Send, {Enter}
            Sleep, 300
            /*
            MoveYourMouse(BD2RCreateButtonX, BD2RCreateButtonY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            */
        }
        i := i+1
    }
    Return
}
;------------------------------------------------------------------------------------Create_D2R_Game_DC End >
;------------------------------------------------------------------------------------Create_D2R_Game_DC >
Create_D2R_Game_DC:
{
    GuiControlGet, BD2RGameHostWin 
    GuiControlGet, BD2RGameHostLevel
    GuiControlGet, BD2RHostName
    ;BD2RHostName := "DC-"
    GuiControlGet, BD2RHostPW
    GuiControlGet, BD2ROnlyJoin
    i := 1
    While (i <= 8) 
    {
        GuiControlGet, BD2RJoin%i%
        GuiControlGet, BD2RWIN%i%
        i := i+1
    }
    GuiControlGet, CurrentExitDelay,, BD2RExitDelay
    ; Judge if number and ≥2000
    if CurrentExitDelay is not number
    {
        CurrentExitDelay := 2000
    }
    if (CurrentExitDelay < 2000)
    {
        CurrentExitDelay := 2000
    }
    

    i := 1
    While (i <= 8) 
    {
        join_pid := BD2RWIN%i%
        if WinExist("ahk_id " join_pid)
        {
            WinActivate, ahk_id %join_pid%
            Sleep, 100
            ;Handle join game111
            ;Press space close window
            Send {Space}
            Sleep, 100
            
            D2R_GamePosition := 0
            Gosub D2R_Check_GamePosition
            ;D2R_GamePosition=0 in game =1 character screen =2 lobby screen
            if (D2R_GamePosition = 0)
            {
                Send {Esc}
                Sleep, 50
                MoveYourMouse(0.5013, 0.4389, 1) 
                Sleep, 50
                MouseClick, L
                Sleep, %CurrentExitDelay%
                Gosub D2R_Check_GamePosition
            }
            
            if (D2R_GamePosition = 1)
            {
                MoveYourMouse(0.5861, 0.8991, 1) 
                Sleep, 50
                MouseClick, L
                Sleep, 2000
                Gosub D2R_Check_GamePosition
            }

            if (D2R_GamePosition != 2) ;If not successfully exit to lobby screen, exit process
            {
                i := i+1
                Continue
            }

            MoveYourMouse(BD2RCreateMenuX, BD2RCreateMenuY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100

            ;Game name
            if BD2RHostName is Number
            {
                BD2RHostName++
                GuiControl, , BD2RHostName, %BD2RHostName%
            }
            Else
                BD2RHostName .= "1"
            /*
            Loop 5 {
                Random, digit, 0, 9
                rand .= digit
            }
            BD2RHostName .= rand
            */
            MoveYourMouse(BD2RCreateNameX, BD2RCreateNameY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            Send, ^a
            Sleep, 100
            Send, {Delete} 
            Sleep, 100
            Clipboard := BD2RHostName
            ClipWait, 1
            Send, ^v
            Sleep, 100

            Send, {Tab}
            ;Game password
            if (StrLen(BD2RHostPW) > 0)
            {
                Sleep, 100
                Send, ^a
                Sleep, 100
                Send, {Delete} 
                Sleep, 100
                Clipboard := BD2RHostPW
                ClipWait, 1
                Send, ^v
            }
            Sleep, 100

            ;Select difficulty
            if (BD2RGameHostLevel = 1)
                MoveYourMouse(BD2RNormalX, BD2RNormalY, 1)
            if (BD2RGameHostLevel = 2)
                MoveYourMouse(BD2RNightMareX, BD2RNightMaresY, 1)
            if (BD2RGameHostLevel = 3)
                MoveYourMouse(BD2RHellX, BD2RHellY, 1)
            Sleep, 50
            MouseClick, L
            Sleep, 100

            ;Start create
            Send, {Enter}
            Sleep, 300
        }
        i := i+1
    }
    Return
}
;------------------------------------------------------------------------------------Create_D2R_Game_DC End >
;------------------------------------------------------------------------------------Create_D2R_Lobby >
Create_D2R_Game:
{
    ;Global create_d2r_toggle := 1
    GuiControlGet, BD2RGameHostWin 
    GuiControlGet, BD2RGameHostLevel
    GuiControlGet, BD2RHostName
    GuiControlGet, BD2RHostPW
    if (Strlen(BD2RHostName) < 3)
    {
        MsgBox, Room name must be more than two characters
        Return
    }
    GuiControlGet, BD2ROnlyJoin
    ;Wait host create time BD2RHostDelay
    GuiControlGet, BD2RHostDelay
    If (BD2RHostDelay is not Number)
        BD2RHostDelay := 500
    Else if (BD2RHostDelay < 300)
        BD2RHostDelay := 300
    Else if (BD2RHostDelay > 2000)
        BD2RHostDelay := 1000
    GuiControlGet, CurrentExitDelay,, BD2RExitDelay
    ; Judge if number and ≥2000
    if CurrentExitDelay is not number
    {
        CurrentExitDelay := 2000
    }
    if (CurrentExitDelay < 2000)
    {
        CurrentExitDelay := 2000
    }
        
    i := 1
    While (i <= 8) 
    {
        GuiControlGet, BD2RJoin%i%
        GuiControlGet, BD2RWIN%i%
        i := i+1
    }
    if (BD2ROnlyJoin != 1)
    {
        host_pid := ""
        if (BD2RGameHostWin = 1)
        {
            host_pid := BD2RWIN1
            WinActivate, ahk_id %BD2RWIN1%
        }
        if (BD2RGameHostWin = 2)
        {
            host_pid := BD2RWIN2
            WinActivate, ahk_id %BD2RWIN2%
        }
        if (BD2RGameHostWin = 3)
        {
            host_pid := BD2RWIN3
            WinActivate, ahk_id %BD2RWIN3%
        }
        if (BD2RGameHostWin = 4)
        {
            host_pid := BD2RWIN4
            WinActivate, ahk_id %BD2RWIN4%
        }
        if (BD2RGameHostWin = 5)
        {
            host_pid := BD2RWIN5
            WinActivate, ahk_id %BD2RWIN5%
        }
        if (BD2RGameHostWin = 6)
        {
            host_pid := BD2RWIN6
            WinActivate, ahk_id %BD2RWIN6%
        }
        if (BD2RGameHostWin = 7)
        {
            host_pid := BD2RWIN7
            WinActivate, ahk_id %BD2RWIN7%
        }
        if (BD2RGameHostWin = 8)
        {
            host_pid := BD2RWIN8
            WinActivate, ahk_id %BD2RWIN8%
        }
        Sleep, 100 ;Ensure window switched

        if WinExist("ahk_id " host_pid)
        {
            ;Handle create game
            ;Press space close window
            Send {Space}
            Sleep, 100

            D2R_GamePosition := 0
            Gosub D2R_Check_GamePosition
            ;D2R_GamePosition=0 in game =1 character screen =2 lobby screen
            if (D2R_GamePosition = 0)
            {
                Send {Esc}
                Sleep, 50
                MoveYourMouse(0.5013, 0.4389, 1) 
                Sleep, 50
                MouseClick, L
                Sleep, %CurrentExitDelay%
                Gosub D2R_Check_GamePosition
            }
            
            if (D2R_GamePosition = 1)
            {
                MoveYourMouse(0.5861, 0.8991, 1) 
                Sleep, 50
                MouseClick, L
                Sleep, 2000
                Gosub D2R_Check_GamePosition
            }

            if (D2R_GamePosition != 2) ;If not successfully exit to lobby screen, exit process
                Return

            MoveYourMouse(BD2RCreateMenuX, BD2RCreateMenuY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100

            ;Game name
            if BD2RHostName is Number
            {
                BD2RHostName++
                GuiControl, , BD2RHostName, %BD2RHostName%
            }
            MoveYourMouse(BD2RCreateNameX, BD2RCreateNameY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            Send, ^a
            Sleep, 100
            Send, {Delete} 
            Sleep, 100
            Clipboard := ""
            Clipboard := BD2RHostName
            ClipWait, 1
            Sleep, 100
            Send, ^v
            Sleep, 100

            Send, {Tab}
            ;Game password
            if (StrLen(BD2RHostPW) > 0)
            {
                Sleep, 100
                Send, ^a
                Sleep, 100
                Send, {Delete} 
                Sleep, 100
                Clipboard := ""
                Clipboard := BD2RHostPW
                ClipWait, 2
                Send, ^v
            }
            Sleep, 100

            ;Select difficulty
            if (BD2RGameHostLevel = 1)
                MoveYourMouse(BD2RNormalX, BD2RNormalY, 1)
            if (BD2RGameHostLevel = 2)
                MoveYourMouse(BD2RNightMareX, BD2RNightMaresY, 1)
            if (BD2RGameHostLevel = 3)
                MoveYourMouse(BD2RHellX, BD2RHellY, 1)
            Sleep, 100
            MouseClick, L
            Sleep, 100
            
            ;Start create
            Send, {Enter}
            Sleep, 300
        }
        Else
        {
            MsgBox, Host window not exist, PID: %host_pid%
            Return ;If host window not exist, stop create
        }
        
        Sleep, %BD2RHostDelay% ;After create, wait a bit to avoid join fail
    }
    i := 1
    While (i <= 8) 
    {
        if (create_d2r_toggle = 0)
            Return
        if (BD2RJoin%i% = 1)
        {
            ;Process, Exist, BD2RWIN%i%
            join_pid := BD2RWIN%i%
            if (join_pid = host_pid and BD2ROnlyJoin != 1)
            {
                i := i+1
                Continue
            }
            if WinExist("ahk_id " join_pid)
            {
                WinActivate, ahk_id %join_pid%
                Sleep, 100
                ;Handle join game111
                ;Press space close window
                Send {Space}
                Sleep, 100
                
                D2R_GamePosition := 0
                Gosub D2R_Check_GamePosition
                ;D2R_GamePosition=0 in game =1 character screen =2 lobby screen
                if (D2R_GamePosition = 0)
                {
                    Send {Esc}
                    Sleep, 50
                    MoveYourMouse(0.5013, 0.4389, 1) 
                    Sleep, 50
                    MouseClick, L
                    Sleep, %CurrentExitDelay%
                    Gosub D2R_Check_GamePosition
                }
                
                if (D2R_GamePosition = 1)
                {
                    MoveYourMouse(0.5861, 0.8991, 1) 
                    Sleep, 50
                    MouseClick, L
                    Sleep, 500
                    Gosub D2R_Check_GamePosition
                }
    
                if (D2R_GamePosition != 2) ;If not successfully exit to lobby screen, skip this window process
                {
                    i := i+1
                    Continue
                }

                MoveYourMouse(BD2JoinMenuX, BD2JoinMenuY, 1)
                Sleep, 100
                MouseClick, L
                Sleep, 100

                ;Game name
                MoveYourMouse(BD2RJoinNameX, BD2RJoinNameY, 1)
                Sleep, 100
                MouseClick, L
                Sleep, 100
                Send, ^a
                Sleep, 100
                Send, {Delete} 
                Sleep, 100
                Clipboard := BD2RHostName
                ClipWait, 1
                Sleep, 100
                Send, ^v
                Sleep, 100
    
                Send, {Tab}
                ;Game password
                if (StrLen(BD2RHostPW) > 0)
                {
                    Sleep, 100
                    Send, ^a
                    Sleep, 100
                    Send, {Delete} 
                    Sleep, 100
                    Clipboard := BD2RHostPW
                    ClipWait, 1
                    Send, ^v
                }
                Sleep, 100

                Send, {Enter}
                Sleep, 200
            }
        }
        i := i+1
    }

    if (BD2ROnlyJoin != 1)
    {
        if WinExist("ahk_id " host_pid)
        {
            Sleep, 100
            WinActivate, ahk_id %host_pid%
        }
    }

    Return
}
;------------------------------------------------------------------------------------Create_D2R_Lobby End >

SelectD2RShortcuts:
    FileSelectFile, files, M3, , Select Diablo2 Shortcuts, Shortcuts (*.lnk)
    if (files = "")
        return

    ; Handle multi select result
    listItems := ""
    baseDir := ""
    Loop, Parse, files, `n
    {
        if (A_Index = 1) {
            baseDir := A_LoopField
            continue
        }
        fullPath := baseDir "\" A_LoopField
        if FileExist(fullPath) {
            listItems .= fullPath "|"
            ;Gosub, saveFileCommon
        }
    }
    GuiControl, , BD2RShortCutList, |%listItems%
return

; Move up selected item
D2RMoveUp:
    ; Get currently selected item
    GuiControlGet, selectedItem,, BD2RShortCutList

    ; If no item selected, return directly
    if (selectedItem = "")
        return

    ; Get ListBox ClassNN
    GuiControlGet, ListBoxHwnd, Hwnd, BD2RShortCutList
    ; Get all items content in ListBox
    ControlGet, allItems, List,,, ahk_id %ListBoxHwnd%

    ; Split content by newline to array
    itemsArray := StrSplit(allItems, "`n")

    ; Find selected item index
    selectedIndex := 0
    for index, item in itemsArray {
        if (item = selectedItem) {
            selectedIndex := index
            break
        }
    }

    ; If selected item is already first item, return directly
    if (selectedIndex <= 1)
        return

    ; Swap selected item and previous item position
    temp := itemsArray[selectedIndex]
    itemsArray[selectedIndex] := itemsArray[selectedIndex - 1]
    itemsArray[selectedIndex - 1] := temp

    ; Rejoin array to string
    newItems := ""
    for index, item in itemsArray {
        newItems .= item . "`n"
    }
    newItems := Trim(newItems, "`n")

    ; Update ListBox content
    GuiControl,, BD2RShortCutList, % "|" . StrReplace(newItems, "`n", "|")
return

; Move down selected item
D2RMoveDown:
    ; Get currently selected item
    GuiControlGet, selectedItem,, BD2RShortCutList

    ; If no item selected, return directly
    if (selectedItem = "")
        return

    ; Get ListBox ClassNN
    GuiControlGet, ListBoxHwnd, Hwnd, BD2RShortCutList
    ; Get all items content in ListBox
    ControlGet, allItems, List,,, ahk_id %ListBoxHwnd%

    ; Split content by newline to array
    itemsArray := StrSplit(allItems, "`n")

    ; Find selected item index
    selectedIndex := 0
    for index, item in itemsArray {
        if (item = selectedItem) {
            selectedIndex := index
            break
        }
    }

    ; If selected item is already last item, return directly
    if (selectedIndex >= itemsArray.Length())
        return

    ; Swap selected item and next item position
    temp := itemsArray[selectedIndex]
    itemsArray[selectedIndex] := itemsArray[selectedIndex + 1]
    itemsArray[selectedIndex + 1] := temp

    ; Rejoin array to string
    newItems := ""
    for index, item in itemsArray {
        newItems .= item . "`n"
    }
    newItems := Trim(newItems, "`n")

    ; Update ListBox content
    GuiControl,, BD2RShortCutList, % "|" . StrReplace(newItems, "`n", "|")
return

SaveD2RShortcuts:
{
    Gui, Submit, NoHide
    Gosub, saveFileCommon
    Return
}

;--------------------------------------------------------------------------------------------------------------------------
ChangeBrowserChrome(pos1, pos2)
{
    Run ms-settings:defaultapps
    Sleep 1200
    Send {Tab %pos1%}
    Sleep 200
    Send {Enter} ; Highlight Default Browser + Select
    Sleep 1000

    Send {Tab %pos2%} ; Highlight desired browser (e.g., Chrome) + Select
    Sleep 200
    Send +{Tab} ; Highlight desired browser (e.g., Chrome) + SelectOnly
    Sleep 200
    Send {Enter} ; Select

    Sleep 500
    if WinExist("ahk_class ApplicationFrameWindow") {
        WinClose
    }

    Return
}
SetBrowserChrome(browser_name)
{
    Run ms-settings:defaultapps
    Sleep 1000

    MoveYourMouseAnyway(0.3711, 0.3398, 1)
    Sleep 100
    MouseClick, L
    Sleep 100

    Clipboard := ""
    Clipboard := browser_name
    ClipWait, 2
    Send, ^v
    Sleep 200

    MoveYourMouseAnyway(0.4133, 0.4016, 1)
    Sleep 100
    MouseClick, L
    Sleep 500

    MoveYourMouseAnyway(0.8328, 0.139, 1)
    Sleep 100
    MouseClick, L

    Sleep 500
    if WinExist("ahk_class ApplicationFrameWindow") {
        WinClose
    }

    Return
}
;--------------------------------------------------------------------------------------------------------------------------
MultiLaunchD2RCNW11:
    GuiControlGet, selectedItems, , BD2RShortCutList
    if (selectedItems = "") {
        MsgBox Please select at least one shortcut first！
        return
    }

    ; Convert list to array
    paths := []
    count := 0
    Loop, Parse, selectedItems, |
    {
        if (A_LoopField != "")
        {   
            paths.Push(A_LoopField)
            count++
        }
    }
    if (count > 1) {
        MsgBox CN server can only launch one instance each time, please do not select multiple shortcuts！
        return
    }

    ;Get launch instance position--------------------------------------------------------
    instance_pos := 1 ; Current launch is which instance
    ; Use GuiControlGet to get handle
    GuiControlGet, hList, Hwnd, BD2RShortCutList    
    SendMessage, 0x188, 0, 0, , ahk_id %hList%  ; LB_GETCURSEL
    instance_pos := (ErrorLevel + 1)

    ;MsgBox Start launch, do not click button repeatedly！
    MsgBox, 1, Launch Game, Start launch, click OK to continue, do not click button repeatedly
    IfMsgBox Cancel
        Return

    ;Get instance position corresponding browser number------------------------------------------------
    GuiControlGet, BD2RBroswserListName
    pos2str := BD2RBroswserListName
    if (pos2str = "")
    {
        pos2 := "EDGE"
    }
    Else
    {
        array := StrSplit(pos2str, ",")  
        pos2 := array[instance_pos]  ; Get xth value, index from 1
        if (pos2 = "")
            pos2 := "EDGE"
    }

    SetBrowserChrome(pos2)

    ; Execute batch operation
    RunAsAdmin()
    BatchLaunch(paths)

    ; After launch get window handle list once
    Sleep, 1000
    Gosub, Get_D2R_WIN_ALL
return

MultiLaunchD2RCN:
    GuiControlGet, selectedItems, , BD2RShortCutList
    if (selectedItems = "") {
        MsgBox Please select at least one shortcut first！
        return
    }

    ; Convert list to array
    paths := []
    count := 0
    Loop, Parse, selectedItems, |
    {
        if (A_LoopField != "")
        {   
            paths.Push(A_LoopField)
            count++
        }
    }
    if (count > 1) {
        MsgBox CN server can only launch one instance each time, please do not select multiple shortcuts！
        return
    }

    ;Get launch instance position--------------------------------------------------------
    instance_pos := 1 ; Current launch is which instance
    ; Use GuiControlGet to get handle
    GuiControlGet, hList, Hwnd, BD2RShortCutList    
    SendMessage, 0x188, 0, 0, , ahk_id %hList%  ; LB_GETCURSEL
    instance_pos := (ErrorLevel + 1)

    ;MsgBox Start launch, do not click button repeatedly！
    MsgBox, 1, Launch Game, Start launch, click OK to continue, do not click button repeatedly
    IfMsgBox Cancel
        Return

    ;Get instance position corresponding browser number------------------------------------------------
    pos1 := 5
    pos2 := 1
    GuiControlGet, BD2RBroswserSetPos
    GuiControlGet, BD2RBroswserListPos
    pos1 := BD2RBroswserSetPos
    if (pos1 = "")
        pos1 := 5
    pos2str := BD2RBroswserListPos
    if (pos2str = "")
    {
        pos2 := 1
    }
    Else
    {
        array := StrSplit(pos2str, ",")  
        pos2 := array[instance_pos]  ; Get xth value, index from 1
        if (pos2 = "")
            pos2 := 1
    }

    ChangeBrowserChrome(pos1, pos2)

    ; Execute batch operation
    RunAsAdmin()
    BatchLaunch(paths)

    ; After launch get window handle list once
    Sleep, 1000
    Gosub, Get_D2R_WIN_ALL
return

MultiLaunchD2R:
    GuiControlGet, selectedItems, , BD2RShortCutList
    if (selectedItems = "") {
        MsgBox Please select at least one shortcut first！
        return
    }

    ; Convert list to array
    paths := []
    Loop, Parse, selectedItems, |
    {
        if (A_LoopField != "")
            paths.Push(A_LoopField)
    }

    ;MsgBox Start launch, do not click button repeatedly！
    MsgBox, 1, Launch Game, Start launch, click OK to continue, do not click button repeatedly
    IfMsgBox Cancel
        Return

    ; Execute batch operation
    RunAsAdmin()
    BatchLaunch(paths)

    ; After launch get window handle list once
    Sleep, 1000
    Gosub, Get_D2R_WIN_ALL
return

/*
BatchLaunch(paths) {
    global
    
    FileDelete, %logFile%
    
    if BD2RLaunchDelay is not number
        BD2RLaunchDelay := 10
    sleepTimeInMilliseconds := BD2RLaunchDelay * 1000
    if (sleepTimeInMilliseconds > 20000)
        sleepTimeInMilliseconds := 20000
    
    ; Create temporary job object to manage child processes
    hJob := DllCall("CreateJobObject", "Ptr", 0, "Str", "TempJob", "Ptr")
    if (hJob) {
        ; Configure job object: terminate all child processes when job object closes
        VarSetCapacity(info, 24, 0)
        NumPut(24, info, 0, "UInt")
        NumPut(0x2000, info, 16, "UInt") ; JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
        DllCall("SetInformationJobObject", "Ptr", hJob, "Int", 5, "Ptr", &info, "UInt", 24)
    }
    
    for index, currentLNK in paths
    {
        currentDir := A_ScriptDir
        handleCmd = "%handlePath%" -a "Check For Other Instances" -nobanner
        
        ; Add command process to job object
        Run, %ComSpec% /c cd /d "%currentDir%" && %handleCmd% > Handle.txt, , Hide, cmdPID
        if (hJob && cmdPID) {
            hProcess := DllCall("OpenProcess", "UInt", 0x0200 | 0x0400, "Int", 0, "UInt", cmdPID, "Ptr")
            if (hProcess) {
                DllCall("AssignProcessToJobObject", "Ptr", hJob, "Ptr", hProcess)
                DllCall("CloseHandle", "Ptr", hProcess)
            }
        }
        
        ; Wait command complete
        Process, WaitClose, %cmdPID%
        
        FileRead, rawOutput, Handle.txt
        Log("【Handle raw output】`n" rawOutput)
        
        CloseAllInstances()
        
        if FileExist(currentLNK) {
            ; Launch game and add to job object
            Run, "%currentLNK%", , , gamePID
            Log("Launch success: PID " gamePID " - " currentLNK)
            
            if (hJob && gamePID) {
                hProcess := DllCall("OpenProcess", "UInt", 0x0200 | 0x0400, "Int", 0, "UInt", gamePID, "Ptr")
                if (hProcess) {
                    DllCall("AssignProcessToJobObject", "Ptr", hJob, "Ptr", hProcess)
                    DllCall("CloseHandle", "Ptr", hProcess)
                }
            }
            
            WinWait, Diablo II, , % (secs//1000)
            if ErrorLevel
                Log("Window wait timeout")
            
            Sleep, %sleepTimeInMilliseconds%
        }
    }
    
    ; Final cleanup
    Run, %ComSpec% /c cd /d "%A_ScriptDir%" && "%handlePath%" -a "Check For Other Instances" -nobanner > Handle.txt, , Hide, finalCmdPID
    if (hJob && finalCmdPID) {
        hProcess := DllCall("OpenProcess", "UInt", 0x0200 | 0x0400, "Int", 0, "UInt", finalCmdPID, "Ptr")
        if (hProcess) {
            DllCall("AssignProcessToJobObject", "Ptr", hJob, "Ptr", hProcess)
            DllCall("CloseHandle", "Ptr", hProcess)
        }
    }
    Process, WaitClose, %finalCmdPID%
    CloseAllInstances()
    
    ; Close job object, terminate all associated processes
    if (hJob) {
        DllCall("CloseHandle", "Ptr", hJob)
    }
}

CloseAllInstances() {
    global handlePath
    
    ; Directly process Handle.txt
    FileRead, handleOutput, Handle.txt
    
    Loop, Parse, handleOutput, `n, `r
    {
        if RegExMatch(A_LoopField, "pid: (\d+).*handle: (\w+)", match) {
            Run, %ComSpec% /c "%handlePath%" -p %match1% -c %match2% -y, , Hide, handlePID
            Process, WaitClose, %handlePID%
        }
    }
    
    FileDelete, Handle.txt
}
*/

BatchLaunch(paths) {
    global
    
    FileDelete, %logFile%
    
    if BD2RLaunchDelay is not number
        BD2RLaunchDelay := 10
    sleepTimeInMilliseconds := BD2RLaunchDelay * 1000
    if (sleepTimeInMilliseconds > 20000)
        sleepTimeInMilliseconds := 20000
    for index, currentLNK in paths
    {
        ; █ Key fix1: Explicitly specify working directory
        currentDir := A_ScriptDir
        handleCmd = "%handlePath%" -a "Check For Other Instances" -nobanner
        
        ; █ Key fix2: Use full CMD call
        RunWait, %ComSpec% /c cd /d "%currentDir%" && %handleCmd% > Handle.txt, , Hide
        
        ; █ Debug: Directly record raw output
        FileRead, rawOutput, Handle.txt
        Log("【Handle raw output】`n" rawOutput)  ; Check if contains valid content here
        
        CloseAllInstances()
        
        if FileExist(currentLNK) {
            ; █ Key fix3: Standardize path handling
            Run, "%currentLNK%", , , PID
            Log("Launch success: PID " PID " - " currentLNK)
            
            WinWait, Diablo II, , % (secs//1000)
            if ErrorLevel
                Log("Window wait timeout")
            
            ;Sleep 10000  
            Sleep, %sleepTimeInMilliseconds%
        }
    }
    
    ; Final cleanup
    RunWait, %ComSpec% /c cd /d "%A_ScriptDir%" && "%handlePath%" -a "Check For Other Instances" -nobanner > Handle.txt, , Hide
    CloseAllInstances()
}

CloseAllInstances() {
    global
    
    ; ███ Define BAT file content ███
    batContent := "@echo off`r`n"
    batContent .= "for /f ""tokens=3,6 delims= "" %%a in (Handle.txt) do handle.exe -p %%a -c %%b -y >>log.txt`r`n"
    
    ; ███ Write BAT content to temp file ███
    batFile := A_Temp "\CloseHandles.bat"
    FileDelete, %batFile%
    FileAppend, %batContent%, %batFile%
    
    ; ███ Execute BAT file ███
    RunWait, %ComSpec% /c "%batFile%", , Hide
    
    ; ███ Cleanup temp files ███
    FileDelete, %batFile%
    FileDelete, handle.txt
}

RunAsAdmin() {
    if !A_IsAdmin {
        try {
            Run *RunAs "%A_ScriptFullPath%"
            ExitApp
        }
        MsgBox Need administrator permission to run！
        ExitApp
    }
}

Log(message) {
    global logFile
    FormatTime, timestamp, , yyyy-MM-dd HH:mm:ss
    FileAppend, [%timestamp%] %message%`n, %logFile%
}

;------------------------------------------------------------------------------------Join_D2R_Game >
JoinD2RGameByAccount:
{
    Return
}
;------------------------------------------------------------------------------------Join_D2R_Game >


GetControlValue:
{
    ;;;;;Save original hotkeys, to compare if changed, custom hotkeys when changed to new hotkey first restore original function;;;;
    tempHotkey3 := BHotkey3
    tempHotkey4 := BHotkey4
    tempHotkey5 := BHotkey5
    ;Hotkey, %BHotkey3%, off ,off 
    ;Hotkey, %BHotkey4%, off ,off 
    ;Hotkey, %BHotkey5%, off ,off 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GuiControlGet, BServer
    GuiControlGet, BMoveKey
    GuiControlGet, BStandKey
    GuiControlGet, BAvoidKey
    GuiControlGet, BLMouseKey
    GuiControlGet, BHorseKey
    GuiControlGet, BSkillKey1
    GuiControlGet, BSkillKey2
    GuiControlGet, BSkillKey3
    GuiControlGet, BSkillKey4
    GuiControlGet, BFouceMove
    GuiControlGet, BMButton
	GuiControlGet, BAuto1
	GuiControlGet, BAuto2
	GuiControlGet, BAuto3
	GuiControlGet, BAuto4
	GuiControlGet, BAutoL
	GuiControlGet, BAutoR
	GuiControlGet, BAutoMouseL
	GuiControlGet, BAutoPotion
	GuiControlGet, BExitL
	GuiControlGet, BDelay1
	GuiControlGet, BDelay2
	GuiControlGet, BDelay3
	GuiControlGet, BDelay4
	GuiControlGet, BDelayL
	GuiControlGet, BDelayR
	GuiControlGet, BDelayMouseL
	GuiControlGet, BPotionDelay1
	GuiControlGet, BDelay12
	GuiControlGet, BDelay22
	GuiControlGet, BDelay32
	GuiControlGet, BDelay42
	GuiControlGet, BDelayL2
	GuiControlGet, BDelayR2
	GuiControlGet, BDelayMouseL2
	GuiControlGet, BKeep1
	GuiControlGet, BKeep2
	GuiControlGet, BKeep3
	GuiControlGet, BKeep4
	GuiControlGet, BKeepL
	GuiControlGet, BKeepR
	GuiControlGet, BKeepMouseL
	GuiControlGet, BHotkey3
	GuiControlGet, BHotkey4
	GuiControlGet, BHotkey5
	GuiControlGet, BModeL
	GuiControlGet, BModeR
	GuiControlGet, BModeReleaseL
	GuiControlGet, BModeReleaseR
	GuiControlGet, BDClickL
	GuiControlGet, BDClickR
	GuiControlGet, BWheelUp
	GuiControlGet, BWheelDown
	GuiControlGet, BMode3
	GuiControlGet, BMode4
	GuiControlGet, BMode5
	GuiControlGet, BForceMove
	GuiControlGet, Bchannel
    GuiControlGet, BchannelKey
	GuiControlGet, Bchannel2
    GuiControlGet, BchannelKey2
    GuiControlGet, BEamon
    GuiControlGet, BSmashType
    GuiControlGet, BProtectZone
    GuiControlGet, BDispMode
    GuiControlGet, BMouseDelay
    GuiControlGet, BGlobalMouseDelay
    GuiControlGet, BGlobalKeyDelay
    GuiControlGet, BStandL
    GuiControlGet, BStandR
    GuiControlGet, BStand3
    GuiControlGet, BStand4
    GuiControlGet, BStand5
    GuiControlGet, BOnceL
    GuiControlGet, BOnceR
    GuiControlGet, BOnce3
    GuiControlGet, BOnce4
    GuiControlGet, BOnce5
    GuiControlGet, BAutoStart3
    GuiControlGet, BAutoStart4
    GuiControlGet, BAutoStart5
    GuiControlGet, BMarcoAS1
    GuiControlGet, BMarcoAS2
    GuiControlGet, BMarcoAS3
    GuiControlGet, BMarcoAS4
    GuiControlGet, BMarcoAS5
    GuiControlGet, BAutoEnter1
    GuiControlGet, BAutoEnter2
    GuiControlGet, BAutoEnter3
    GuiControlGet, BAutoEnter4
    GuiControlGet, BAutoEnter5
    GuiControlGet, BAutoEnter6
    GuiControlGet, BAutoEnter7
    GuiControlGet, BAutoEnter8
    GuiControlGet, BAutoEnter9
    GuiControlGet, BEnableDoubleClick
    GuiControlGet, BEnableDCL
    GuiControlGet, BEnableDCR
    GuiControlGet, BEnableWU
    GuiControlGet, BEnableWD
    GuiControlGet, BEnableMouseGesture
    GuiControlGet, BEnableGreatRift
    GuiControlGet, BEnableStatus
    GuiControlGet, BCancelDC
    GuiControlGet, BMButtonRelease
 
    GuiControlGet, BItemSX
    GuiControlGet, BItemSY
    GuiControlGet, BItemEX
    GuiControlGet, BItemEY
    GuiControlGet, BOrangePosX
    GuiControlGet, BOrangePosY
    GuiControlGet, BWhitePosX
    GuiControlGet, BWhitePosY
    GuiControlGet, BBluePosX
    GuiControlGet, BBluePosY
    GuiControlGet, BYellowPosX
    GuiControlGet, BYellowPosY
    GuiControlGet, BPutPosX
    GuiControlGet, BPutPosY
    GuiControlGet, BRebuildPosX
    GuiControlGet, BRebuildPosY
    GuiControlGet, BPrePosX
    GuiControlGet, BPrePosY
    GuiControlGet, BNextPosX
    GuiControlGet, BNextPosY
    GuiControlGet, BAttributeAdjust
    GuiControlGet, BMainProp
    GuiControlGet, BStam
    GuiControlGet, BSpeed
    GuiControlGet, BEnergy
    GuiControlGet, BRangDamage
    GuiControlGet, BAutoCloseWin
    GuiControlGet, BUpgradeCount
    
    if BGlobalMouseDelay is not integer
    {
        BGlobalMouseDelay := 10
    }
    if BGlobalKeyDelay is not integer
    {
        BGlobalKeyDelay := 10
    }
    if BMouseDelay is not integer
    {
        BMouseDelay := 5
    }
    SetKeyDelay,%BGlobalMouseDelay%
    SetMouseDelay,%BGlobalKeyDelay%
    
    ;If hotkey changed, first disable original
    if (tempHotkey3 != BHotkey3)
        Hotkey, %tempHotkey3%, RunHotkey3, off
    if (tempHotkey4 != BHotkey4)
        Hotkey, %tempHotkey4%, RunHotkey4, off
    if (tempHotkey5 != BHotkey5)
        Hotkey, %tempHotkey5%, RunHotkey5, off
        
    ;Hotkey, IfWinActive, ahk_class %BServer%
    if (BStand3 = 1)
    {
        if(BHotkey3)
            Hotkey, %BHotkey3%, RunHotkey3
    }
    if (BStand4 = 1)
    {
        if(BHotkey4)
            Hotkey, %BHotkey4%, RunHotkey4
    }
    if (BStand5 = 1)
    {
        if(BHotkey5)
            Hotkey, %BHotkey5%, RunHotkey5
    }
	return
}

SaveFileCommon:
{
    if !FileExist( commonIni )
        Return

    ; Get ListBox ClassNN
    GuiControlGet, ListBoxHwnd, Hwnd, BD2RShortCutList
    ; Get all items content in ListBox
    ControlGet, ListBoxContent, List,,, ahk_id %ListBoxHwnd%
    ListBoxContent := StrReplace(ListBoxContent, "`n", ",")
    IniWrite, %listBoxContent%, %commonIni%, D2R, cfgBD2RShortCutList
    MsgBox, Save D2R settings success!

    GuiControlGet, BD2RLaunchDelay
    IniWrite, %BD2RLaunchDelay%, %commonIni%, D2R, cfgBD2RLaunchDelay
    GuiControlGet, BD2RHostDelay
    IniWrite, %BD2RHostDelay%, %commonIni%, D2R, cfgBD2RHostDelay
    ; Save exit wait
    GuiControlGet, BD2RExitDelay
    IniWrite, %BD2RExitDelay%, %commonIni%, D2R, cfgBD2RExitDelay

    GuiControlGet, BD2RQuickToggleX
    IniWrite, %BD2RQuickToggleX%, %commonIni%, D2R, cfgBD2RQuickToggleX
    GuiControlGet, BD2RQuickToggleY
    IniWrite, %BD2RQuickToggleY%, %commonIni%, D2R, cfgBD2RQuickToggleY
    GuiControlGet, BD2RCreateMenuX
    IniWrite, %BD2RCreateMenuX%, %commonIni%, D2R, cfgBD2RCreateMenuX
    GuiControlGet, BD2RCreateMenuY
    IniWrite, %BD2RCreateMenuY%, %commonIni%, D2R, cfgBD2RCreateMenuY
    GuiControlGet, BD2JoinMenuX
    IniWrite, %BD2JoinMenuX%, %commonIni%, D2R, cfgBD2JoinMenuX
    GuiControlGet, BD2JoinMenuY
    IniWrite, %BD2JoinMenuY%, %commonIni%, D2R, cfgBD2JoinMenuY
    GuiControlGet, BD2RCreateNameX
    IniWrite, %BD2RCreateNameX%, %commonIni%, D2R, cfgBD2RCreateNameX
    GuiControlGet, BD2RCreateNameY
    IniWrite, %BD2RCreateNameY%, %commonIni%, D2R, cfgBD2RCreateNameY
    GuiControlGet, BD2RCreateButtonX
    IniWrite, %BD2RCreateButtonX%, %commonIni%, D2R, cfgBD2RCreateButtonX
    GuiControlGet, BD2RCreateButtonY
    IniWrite, %BD2RCreateButtonY%, %commonIni%, D2R, cfgBD2RCreateButtonY
    GuiControlGet, BD2RNormalX
    IniWrite, %BD2RNormalX%, %commonIni%, D2R, cfgBD2RNormalX
    GuiControlGet, BD2RNormalY
    IniWrite, %BD2RNormalY%, %commonIni%, D2R, cfgBD2RNormalY
    GuiControlGet, BD2RNightMareX
    IniWrite, %BD2RNightMareX%, %commonIni%, D2R, cfgBD2RNightMareX
    GuiControlGet, BD2RNightMaresY
    IniWrite, %BD2RNightMaresY%, %commonIni%, D2R, cfgBD2RNightMaresY
    GuiControlGet, BD2RHellX
    IniWrite, %BD2RHellX%, %commonIni%, D2R, cfgBD2RHellX
    GuiControlGet, BD2RHellY
    IniWrite, %BD2RHellY%, %commonIni%, D2R, cfgBD2RHellY
    GuiControlGet, BD2RJoinNameX
    IniWrite, %BD2RJoinNameX%, %commonIni%, D2R, cfgBD2RJoinNameX
    GuiControlGet, BD2RJoinNameY
    IniWrite, %BD2RJoinNameY%, %commonIni%, D2R, cfgBD2RJoinNameY
    GuiControlGet, BD2RJoinButtonX
    IniWrite, %BD2RJoinButtonX%, %commonIni%, D2R, cfgBD2RJoinButtonX
    GuiControlGet, BD2RJoinButtonY
    IniWrite, %BD2RJoinButtonY%, %commonIni%, D2R, cfgBD2RJoinButtonY
    
    GuiControlGet, BD2RBroswserSetPos
    IniWrite, %BD2RBroswserSetPos%, %commonIni%, D2R, cfgBD2RBroswserSetPos
    GuiControlGet, BD2RBroswserListPos
    IniWrite, %BD2RBroswserListPos%, %commonIni%, D2R, cfgBD2RBroswserListPos
    GuiControlGet, BD2RBroswserListName
    IniWrite, %BD2RBroswserListName%, %commonIni%, D2R, cfgBD2RBroswserListName

    return
}

SaveFile:
{
	Gui, Submit, NoHide
	m_FileText=
	(
[Settings]
cfgBServer=%BServer%
cfgBMoveKey=%BMoveKey%
cfgBStandKey=%BStandKey%
cfgBAvoidKey=%BAvoidKey%
cfgBLMouseKey=%BLMouseKey%
cfgBHorseKey=%BHorseKey%
cfgBSkillKey1=%BSkillKey1%
cfgBSkillKey2=%BSkillKey2%
cfgBSkillKey3=%BSkillKey3%
cfgBSkillKey4=%BSkillKey4%
cfgBFouceMove=%BFouceMove%
cfgBMButton=%BMButton%
cfgBAuto1=%BAuto1%
cfgBAuto2=%BAuto2%
cfgBAuto3=%BAuto3%
cfgBAuto4=%BAuto4%
cfgBAutoL=%BAutoL%
cfgBAutoR=%BAutoR%
cfgBAutoMouseL=%BAutoMouseL%
cfgBAutoPotion=%BAutoPotion%
cfgBExitL=%BExitL%     
cfgBDelay1=%BDelay1%
cfgBDelay2=%BDelay2%
cfgBDelay3=%BDelay3%
cfgBDelay4=%BDelay4%
cfgBDelayL=%BDelayL%
cfgBDelayR=%BDelayR%
cfgBDelayMouseL=%BDelayMouseL%
cfgBPotionDelay1=%BPotionDelay1%
cfgBDelay12=%BDelay12%
cfgBDelay22=%BDelay22%
cfgBDelay32=%BDelay32%
cfgBDelay42=%BDelay42%
cfgBDelayL2=%BDelayL2%
cfgBDelayR2=%BDelayR2%
cfgBDelayMouseL2=%BDelayMouseL2%
cfgBKeep1=%BKeep1%
cfgBKeep2=%BKeep2%
cfgBKeep3=%BKeep3%
cfgBKeep4=%BKeep4%
cfgBKeepL=%BKeepL%
cfgBKeepR=%BKeepR%
cfgBKeepMouseL=%BKeepMouseL%
cfgBHotkey3=%BHotkey3%
cfgBHotkey4=%BHotkey4%
cfgBHotkey5=%BHotkey5%
cfgBModeL=%BModeL%
cfgBModeR=%BModeR%
cfgBModeReleaseL=%BModeReleaseL%
cfgBModeReleaseR=%BModeReleaseR%
cfgBDClickL=%BDClickL%
cfgBDClickR=%BDClickR%
cfgBWheelUp=%BWheelUp%
cfgBWheelDown=%BWheelDown%
cfgBMode3=%BMode3%
cfgBMode4=%BMode4%
cfgBMode5=%BMode5%
cfgBForceMove=%BForceMove%
cfgBchannel=%Bchannel%
cfgBchannelKey=%BchannelKey%
cfgBchannel2=%Bchannel2%
cfgBchannelKey2=%BchannelKey2%
cfgBEamon=%BEamon%
cfgBSmashType=%BSmashType%
cfgBProtectZone=%BProtectZone%
cfgBDispMode=%BDispMode%
cfgBMouseDelay=%BMouseDelay%
cfgBGlobalMouseDelay=%BGlobalMouseDelay%
cfgBGlobalKeyDelay=%BGlobalKeyDelay%
cfgBStandL=%BStandL%
cfgBStandR=%BStandR%
cfgBStand3=%BStand3%
cfgBStand4=%BStand4%
cfgBStand5=%BStand5%
cfgBAutoStart3=%BAutoStart3%
cfgBAutoStart4=%BAutoStart4%
cfgBAutoStart5=%BAutoStart5%
cfgBMarcoAS1=%BMarcoAS1%
cfgBMarcoAS2=%BMarcoAS2%
cfgBMarcoAS3=%BMarcoAS3%
cfgBMarcoAS4=%BMarcoAS4%
cfgBMarcoAS5=%BMarcoAS5%
cfgBOnceL=%BOnceL%
cfgBOnceR=%BOnceR%
cfgBOnce3=%BOnce3%
cfgBOnce4=%BOnce4%
cfgBOnce5=%BOnce5%
cfgBAutoEnter1=%BAutoEnter1%
cfgBAutoEnter2=%BAutoEnter2%
cfgBAutoEnter3=%BAutoEnter3%
cfgBAutoEnter4=%BAutoEnter4%
cfgBAutoEnter5=%BAutoEnter5%
cfgBAutoEnter6=%BAutoEnter6%
cfgBAutoEnter7=%BAutoEnter7%
cfgBAutoEnter8=%BAutoEnter8%
cfgBAutoEnter9=%BAutoEnter9%
cfgBItemSX=%BItemSX%
cfgBItemSY=%BItemSY%
cfgBItemEX=%BItemEX%
cfgBItemEY=%BItemEY%
cfgBOrangePosX=%BOrangePosX%
cfgBOrangePosY=%BOrangePosY%
cfgBWhitePosX=%BWhitePosX%
cfgBWhitePosY=%BWhitePosY%
cfgBBluePosX=%BBluePosX%
cfgBBluePosY=%BBluePosY%
cfgBYellowPosX=%BYellowPosX%
cfgBYellowPosY=%BYellowPosY%
cfgBPutPosX=%BPutPosX%
cfgBPutPosY=%BPutPosY%
cfgBRebuildPosX=%BRebuildPosX%
cfgBRebuildPosY=%BRebuildPosY%
cfgBPrePosX=%BPrePosX%
cfgBPrePosY=%BPrePosY%
cfgBNextPosX=%BNextPosX%
cfgBAttributeAdjust=%BAttributeAdjust%
cfgBMainProp=%BMainProp%
cfgBStam=%BStam%
cfgBSpeed=%BSpeed%
cfgBEnergy=%BEnergy%
cfgBRangDamage=%BRangDamage%
cfgBAutoCloseWin=%BAutoCloseWin%
cfgBUpgradeCount=%BUpgradeCount%
cfgBEnableDoubleClick=%BEnableDoubleClick%
cfgBEnableDCL=%BEnableDCL%
cfgBEnableDCR=%BEnableDCR%
cfgBEnableWU=%BEnableWU%
cfgBEnableWD=%BEnableWD%
cfgBEnableMouseGesture=%BEnableMouseGesture%
cfgBEnableGreatRift=%BEnableGreatRift%
cfgBEnableStatus=%BEnableStatus%
cfgBCancelDC=%BCancelDC%
cfgBMButtonRelease=%BMButtonRelease%
	)
    m_FileText := m_FileText . "`r`n"
    
    m_SettingFile = %SelectedFile%
	if FileExist( m_SettingFile )
    {
        IniDelete, %SelectedFile%, Settings
    }
	FileAppend, %m_FileText%, %SelectedFile%
	FileSetAttrib, +H, %SelectedFile%
	return
}

SaveFileUserMarco:
{
    Global currentMarco
    marcoNum := currentMarco
    actionArray%marcoNum% := []
    Gui, UserMarcoSet%marcoNum%:Submit
    ;Msgbox %marcoNum%
    m_FileText  = 
    (
        [UserMarco%marcoNum%]
    )
    i := 0, y := 0
    loop
    {
        if (i >= actionArrayCount%marcoNum%)
            break
        i := i + 1
        GuiControlGet, status_str, UserMarcoSet%marcoNum%: ,BActionArrayIndex%marcoNum%%i%
        if (ErrorLevel = 1) ;Control not exist or error
            break
        
        if (actionArrayStatus%marcoNum%[i] = 1)
        {
            GuiControlGet, item_str, UserMarcoSet%marcoNum%:, BActionArrayItem%marcoNum%%i%
            GuiControlGet, content_str, UserMarcoSet%marcoNum%:, BActionArrayContent%marcoNum%%i%, Text
            t_strMarco := StrReplace(content_str, "`n", "||")
            
            arry_str := item_str . "," . t_strMarco
            y := y + 1
            m_FileText := m_FileText . "`r`ncfgAction" . y . "=" . arry_str
            contentArray := []
            contentArray[1] := item_str
            contentArray[2] := content_str
            actionArray%marcoNum%[y] := contentArray
            
            ActionArrayIndex%marcoNum% := y
        }
    }
    m_FileText := m_FileText . "`r`n"
    
    m_SettingFile = %SelectedFile%
	if FileExist( m_SettingFile )
    {
        IniDelete, %SelectedFile%, UserMarco%marcoNum%
    }
    FileAppend, %m_FileText%, %SelectedFile%
	FileSetAttrib, +H, %SelectedFile%
	return
}

SaveFileForceMove:
{
    Gui, ForceMove:Submit
    
    GuiControlGet, t_str, ForceMove:, BFMStopLM
    GuiControlGet, t_str, ForceMove:, BFMStopRM
    GuiControlGet, t_str, ForceMove:, BFMStopCH1
    GuiControlGet, t_str, ForceMove:, BFMStopCH2
    GuiControlGet, t_str, ForceMove:, BFMStopKey1
    GuiControlGet, t_str, ForceMove:, BFMStopKey2
    GuiControlGet, t_str, ForceMove:, BFMStopKey3
    GuiControlGet, t_str, ForceMove:, BFMStopKey4
    GuiControlGet, t_str, ForceMove:, BFMStopKey5
    
    m_FileText  = 
    (
        [ForceMove]
    )    
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopLM" . "=" . BFMStopLM
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopRM" . "=" . BFMStopRM
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopCH1" . "=" . BFMStopCH1
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopCH2" . "=" . BFMStopCH2
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopKey1" . "=" . BFMStopKey1
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopKey2" . "=" . BFMStopKey2
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopKey3" . "=" . BFMStopKey3
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopKey4" . "=" . BFMStopKey4
    m_FileText := m_FileText . "`r`n" . "cfg" . "BFMStopKey5" . "=" . BFMStopKey5
    
    m_SettingFile = %SelectedFile%
	if FileExist( m_SettingFile )
    {
        IniDelete, %SelectedFile%, ForceMove
    }
    FileAppend, %m_FileText%, %SelectedFile%
	FileSetAttrib, +H, %SelectedFile%
    return
}

SaveFilePickUp:
{
    Gui, PickUp:Submit
    
    GuiControlGet, t_str, PickUp:, BPUStopLM
    GuiControlGet, t_str, PickUp:, BPUStopRM
    GuiControlGet, t_str, PickUp:, BPUStopCH1
    GuiControlGet, t_str, PickUp:, BPUStopCH2
    GuiControlGet, t_str, PickUp:, BPUStopKey1
    GuiControlGet, t_str, PickUp:, BPUStopKey2
    GuiControlGet, t_str, PickUp:, BPUStopKey3
    GuiControlGet, t_str, PickUp:, BPUStopKey4
    GuiControlGet, t_str, PickUp:, BPUStopKey5
    
    m_FileText  = 
    (
        [PickUp]
    )    
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopLM" . "=" . BPUStopLM
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopRM" . "=" . BPUStopRM
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopCH1" . "=" . BPUStopCH1
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopCH2" . "=" . BPUStopCH2
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopKey1" . "=" . BPUStopKey1
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopKey2" . "=" . BPUStopKey2
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopKey3" . "=" . BPUStopKey3
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopKey4" . "=" . BPUStopKey4
    m_FileText := m_FileText . "`r`n" . "cfg" . "BPUStopKey5" . "=" . BPUStopKey5
    
    m_SettingFile = %SelectedFile%
	if FileExist( m_SettingFile )
    {
        IniDelete, %SelectedFile%, PickUp
    }
    FileAppend, %m_FileText%, %SelectedFile%
	FileSetAttrib, +H, %SelectedFile%
    return
}

SaveFileConfigDocumentWin:
{
    Gui, ConfigDocumentWin:Submit
    
    GuiControlGet, t_str, ConfigDocumentWin:, BCfgDoc_Skill
    GuiControlGet, t_str, ConfigDocumentWin:, BCfgDoc_OP
    BCfgDoc_Skill := StrReplace(BCfgDoc_Skill, "`n", "||")
    BCfgDoc_OP := StrReplace(BCfgDoc_OP, "`n", "||")
    
    m_FileText  = 
    (
        [ConfigDocument]
    )    
    m_FileText := m_FileText . "`r`n" . "cfg" . "BCfgDoc_Skill" . "=" . BCfgDoc_Skill
    m_FileText := m_FileText . "`r`n" . "cfg" . "BCfgDoc_OP" . "=" . BCfgDoc_OP
    
    m_SettingFile = %SelectedFile%
	if FileExist( m_SettingFile )
    {
        IniDelete, %SelectedFile%, ConfigDocument
    }
    FileAppend, %m_FileText%, %SelectedFile%
	FileSetAttrib, +H, %SelectedFile%
    return
}

ReadFileCommon:
{
    if !FileExist( commonIni )
        Return

    ; Read cfgBD2RShortCutList parameter in [D2R] section of commonSetting.ini
    IniRead, cfgBD2RShortCutList, %commonIni%, D2R, cfgBD2RShortCutList, Please select shortcuts
    ; Split read content by comma and fill into ListBox
    GuiControl,, BD2RShortCutList, % "|" . StrReplace(cfgBD2RShortCutList, ",", "|")
   
    IniRead, BD2RLaunchDelay, %commonIni%, D2R, cfgBD2RLaunchDelay, 5
    GuiControl, , BD2RLaunchDelay, %BD2RLaunchDelay%
    IniRead, BD2RHostDelay, %commonIni%, D2R, cfgBD2RHostDelay, 300
    GuiControl, , BD2RHostDelay, %BD2RHostDelay%
    ;IniRead, BD2RShortCutList, %commonIni%, D2R, cfgBD2RShortCutList
    ;GuiControl, , BD2RShortCutList, %BD2RShortCutList%
    ; Save exit wait
    IniRead, BD2RExitDelay, %commonIni%, D2R, cfgBD2RExitDelay, 2000
    GuiControl, , BD2RExitDelay, %BD2RExitDelay%

    IniRead, BD2RQuickToggleX, %commonIni%, D2R, cfgBD2RQuickToggleX, 0.7207
    GuiControl, , BD2RQuickToggleX, %BD2RQuickToggleX%
    IniRead, BD2RQuickToggleY, %commonIni%, D2R, cfgBD2RQuickToggleY, 0.0402
    GuiControl, , BD2RQuickToggleY, %BD2RQuickToggleY%
    IniRead, BD2RCreateMenuX, %commonIni%, D2R, cfgBD2RCreateMenuX, 0.68
    GuiControl, , BD2RCreateMenuX, %BD2RCreateMenuX%
    IniRead, BD2RCreateMenuY, %commonIni%, D2R, cfgBD2RCreateMenuY, 0.0777
    GuiControl, , BD2RCreateMenuY, %BD2RCreateMenuY%
    IniRead, BD2JoinMenuX, %commonIni%, D2R, cfgBD2JoinMenuX, 0.7686
    GuiControl, , BD2JoinMenuX, %BD2JoinMenuX%
    IniRead, BD2JoinMenuY, %commonIni%, D2R, cfgBD2JoinMenuY, 0.0777
    GuiControl, , BD2JoinMenuY, %BD2JoinMenuY%
    IniRead, BD2RCreateNameX, %commonIni%, D2R, cfgBD2RCreateNameX, 0.6952
    GuiControl, , BD2RCreateNameX, %BD2RCreateNameX%
    IniRead, BD2RCreateNameY, %commonIni%, D2R, cfgBD2RCreateNameY, 0.1694
    GuiControl, , BD2RCreateNameY, %BD2RCreateNameY%
    IniRead, BD2RCreateButtonX, %commonIni%, D2R, cfgBD2RCreateButtonX, 0.7615
    GuiControl, , BD2RCreateButtonX, %BD2RCreateButtonX%
    IniRead, BD2RCreateButtonY, %commonIni%, D2R, cfgBD2RCreateButtonY, 0.6166
    GuiControl, , BD2RCreateButtonY, %BD2RCreateButtonY%
    IniRead, BD2RNormalX, %commonIni%, D2R, cfgBD2RNormalX, 0.698
    GuiControl, , BD2RNormalX, %BD2RNormalX%
    IniRead, BD2RNormalY, %commonIni%, D2R, cfgBD2RNormalY, 0.3527
    GuiControl, , BD2RNormalY, %BD2RNormalY%
    IniRead, BD2RNightMareX, %commonIni%, D2R, cfgBD2RNightMareX, 0.7604
    GuiControl, , BD2RNightMareX, %BD2RNightMareX%
    IniRead, BD2RNightMaresY, %commonIni%, D2R, cfgBD2RNightMaresY, 0.3527
    GuiControl, , BD2RNightMaresY, %BD2RNightMaresY%
    IniRead, BD2RHellX, %commonIni%, D2R, cfgBD2RHellX, 0.8227
    GuiControl, , BD2RHellX, %BD2RHellX%
    IniRead, BD2RHellY, %commonIni%, D2R, cfgBD2RHellY, 0.3527
    GuiControl, , BD2RHellY, %BD2RHellY%
    IniRead, BD2RJoinNameX, %commonIni%, D2R, cfgBD2RJoinNameX, 0.6807
    GuiControl, , BD2RJoinNameX, %BD2RJoinNameX%
    IniRead, BD2RJoinNameY, %commonIni%, D2R, cfgBD2RJoinNameY, 0.1465
    GuiControl, , BD2RJoinNameY, %BD2RJoinNameY%
    IniRead, BD2RJoinButtonX, %commonIni%, D2R, cfgBD2RJoinButtonX, 0.758
    GuiControl, , BD2RJoinButtonX, %BD2RJoinButtonX%
    IniRead, BD2RJoinButtonY, %commonIni%, D2R, cfgBD2RJoinButtonY, 0.6194
    GuiControl, , BD2RJoinButtonY, %BD2RJoinButtonY%
    
    IniRead, BD2RBroswserSetPos, %commonIni%, D2R, cfgBD2RBroswserSetPos, 5
    GuiControl, , BD2RBroswserSetPos, %BD2RBroswserSetPos%
    IniRead, BD2RBroswserListPos, %commonIni%, D2R, cfgBD2RBroswserListPos, 1,2,3,4,5
    GuiControl, , BD2RBroswserListPos, %BD2RBroswserListPos%
    IniRead, BD2RBroswserListName, %commonIni%, D2R, cfgBD2RBroswserListName, edge,chrome,firefox,360,Q
    GuiControl, , BD2RBroswserListName, %BD2RBroswserListName%

    Return
}

ReadFile:
{
    ;Before select config, if original hotkey exist, disable original hotkey
    if (BHotkey3)
        Hotkey, %BHotkey3%, RunHotkey3, off 
    if (BHotkey4)
        Hotkey, %BHotkey4%, RunHotkey4, off 
    if (BHotkey5)
        Hotkey, %BHotkey5%, RunHotkey5, off 
        
	m_SettingFile = %SelectedFile%
	if FileExist( m_SettingFile )
	{
    	IniRead, BServer, %SelectedFile%, Settings, cfgBServer
    	IniRead, BMoveKey, %SelectedFile%, Settings, cfgBMoveKey, z
    	IniRead, BStandKey, %SelectedFile%, Settings, cfgBStandKey, .
    	IniRead, BAvoidKey, %SelectedFile%, Settings, cfgBAvoidKey, space
    	IniRead, BLMouseKey, %SelectedFile%, Settings, cfgBLMouseKey, space
    	IniRead, BHorseKey, %SelectedFile%, Settings, cfgBHorseKey, x
    	IniRead, BSkillKey1, %SelectedFile%, Settings, cfgBSkillKey1, 1
    	IniRead, BSkillKey2, %SelectedFile%, Settings, cfgBSkillKey2, 2
    	IniRead, BSkillKey3, %SelectedFile%, Settings, cfgBSkillKey3, 3
    	IniRead, BSkillKey4, %SelectedFile%, Settings, cfgBSkillKey4, 4
        
    	IniRead, BFouceMove, %SelectedFile%, Settings, cfgBFouceMove, 0
    	IniRead, BMButton, %SelectedFile%, Settings, cfgBMButton, ""
    	IniRead, BAuto1, %SelectedFile%, Settings, cfgBAuto1, 0
    	IniRead, BAuto2, %SelectedFile%, Settings, cfgBAuto2, 0
    	IniRead, BAuto3, %SelectedFile%, Settings, cfgBAuto3, 0
    	IniRead, BAuto4, %SelectedFile%, Settings, cfgBAuto4, 0
    	IniRead, BAutoL, %SelectedFile%, Settings, cfgBAutoL, 0
    	IniRead, BAutoR, %SelectedFile%, Settings, cfgBAutoR, 0
    	IniRead, BAutoMouseL, %SelectedFile%, Settings, cfgBAutoMouseL, 0
    	IniRead, BAutoPotion, %SelectedFile%, Settings, cfgBAutoPotion, 0
    	IniRead, BExitL, %SelectedFile%, Settings, cfgBExitL, 0 
    	IniRead, BDelay1, %SelectedFile%, Settings, cfgBDelay1, 100
    	IniRead, BDelay2, %SelectedFile%, Settings, cfgBDelay2, 100
    	IniRead, BDelay3, %SelectedFile%, Settings, cfgBDelay3, 100
    	IniRead, BDelay4, %SelectedFile%, Settings, cfgBDelay4, 100
    	IniRead, BDelayL, %SelectedFile%, Settings, cfgBDelayL, 100
    	IniRead, BDelayR, %SelectedFile%, Settings, cfgBDelayR, 100
    	IniRead, BDelayMouseL, %SelectedFile%, Settings, cfgBDelayMouseL, 100
    	IniRead, BPotionDelay1, %SelectedFile%, Settings, cfgBPotionDelay1, 100
    	IniRead, BDelay12, %SelectedFile%, Settings, cfgBDelay12, 0
    	IniRead, BDelay22, %SelectedFile%, Settings, cfgBDelay22, 0
    	IniRead, BDelay32, %SelectedFile%, Settings, cfgBDelay32, 0
    	IniRead, BDelay42, %SelectedFile%, Settings, cfgBDelay42, 0
    	IniRead, BDelayL2, %SelectedFile%, Settings, cfgBDelayL2, 0
    	IniRead, BDelayR2, %SelectedFile%, Settings, cfgBDelayR2, 0
    	IniRead, BDelayMouseL2, %SelectedFile%, Settings, cfgBDelayMouseL2, 0
        
    	IniRead, BKeep1, %SelectedFile%, Settings, cfgBKeep1, 0
    	IniRead, BKeep2, %SelectedFile%, Settings, cfgBKeep2, 0
    	IniRead, BKeep3, %SelectedFile%, Settings, cfgBKeep3, 0
    	IniRead, BKeep4, %SelectedFile%, Settings, cfgBKeep4, 0
    	IniRead, BKeepL, %SelectedFile%, Settings, cfgBKeepL, 0
    	IniRead, BKeepR, %SelectedFile%, Settings, cfgBKeepR, 0
    	IniRead, BKeepMouseL, %SelectedFile%, Settings, cfgBKeepMouseL, 0
        
    	IniRead, BHotkey3, %SelectedFile%, Settings, cfgBHotkey3, 
    	IniRead, BHotkey4, %SelectedFile%, Settings, cfgBHotkey4, 
    	IniRead, BHotkey5, %SelectedFile%, Settings, cfgBHotkey5, 
    	IniRead, BModeL, %SelectedFile%, Settings, cfgBModeL
    	IniRead, BModeR, %SelectedFile%, Settings, cfgBModeR        
    	IniRead, BModeReleaseL, %SelectedFile%, Settings, cfgBModeReleaseL, 6
    	IniRead, BModeReleaseR, %SelectedFile%, Settings, cfgBModeReleaseR, 6
    	IniRead, BDClickL, %SelectedFile%, Settings, cfgBDClickL, 1
    	IniRead, BDClickR, %SelectedFile%, Settings, cfgBDClickR, 1
    	IniRead, BWheelUp, %SelectedFile%, Settings, cfgBWheelUp, 1
    	IniRead, BWheelDown, %SelectedFile%, Settings, cfgBWheelDown, 1
    	IniRead, BMode3, %SelectedFile%, Settings, cfgBMode3
    	IniRead, BMode4, %SelectedFile%, Settings, cfgBMode4
    	IniRead, BMode5, %SelectedFile%, Settings, cfgBMode5
    	IniRead, BForceMove, %SelectedFile%, Settings, cfgBForceMove, 1
    	IniRead, Bchannel, %SelectedFile%, Settings, cfgBchannel, 0
    	IniRead, BchannelKey, %SelectedFile%, Settings, cfgBchannelKey, 1
    	IniRead, Bchannel2, %SelectedFile%, Settings, cfgBchannel2, 0
    	IniRead, BchannelKey2, %SelectedFile%, Settings, cfgBchannelKey2, 1
    	IniRead, BEamon, %SelectedFile%, Settings, cfgBEamon, 1
    	IniRead, BSmashType, %SelectedFile%, Settings, cfgBSmashType, 1
    	IniRead, BProtectZone, %SelectedFile%, Settings, cfgBProtectZone, 1
    	IniRead, BDispMode, %SelectedFile%, Settings, cfgBDispMode
    	IniRead, BMouseDelay, %SelectedFile%, Settings, cfgBMouseDelay, 5
    	IniRead, BGlobalMouseDelay, %SelectedFile%, Settings, cfgBGlobalMouseDelay, 5
    	IniRead, BGlobalKeyDelay, %SelectedFile%, Settings, cfgBGlobalKeyDelay, 5
    	IniRead, BStandL, %SelectedFile%, Settings, cfgBStandL, 0
    	IniRead, BStandR, %SelectedFile%, Settings, cfgBStandR, 0
    	IniRead, BStand3, %SelectedFile%, Settings, cfgBStand3, 0
    	IniRead, BStand4, %SelectedFile%, Settings, cfgBStand4, 0
    	IniRead, BStand5, %SelectedFile%, Settings, cfgBStand5, 0
    	IniRead, BOnceL, %SelectedFile%, Settings, cfgBOnceL, 0
    	IniRead, BOnceR, %SelectedFile%, Settings, cfgBOnceR, 0
    	IniRead, BOnce3, %SelectedFile%, Settings, cfgBOnce3, 0
    	IniRead, BOnce4, %SelectedFile%, Settings, cfgBOnce4, 0
    	IniRead, BOnce5, %SelectedFile%, Settings, cfgBOnce5, 0
    	IniRead, BMarcoAS1, %SelectedFile%, Settings, cfgBMarcoAS1, 0
    	IniRead, BMarcoAS2, %SelectedFile%, Settings, cfgBMarcoAS2, 0
    	IniRead, BMarcoAS3, %SelectedFile%, Settings, cfgBMarcoAS3, 0
    	IniRead, BMarcoAS4, %SelectedFile%, Settings, cfgBMarcoAS4, 0
    	IniRead, BMarcoAS5, %SelectedFile%, Settings, cfgBMarcoAS5, 0
    	IniRead, BAutoStart3, %SelectedFile%, Settings, cfgBAutoStart3, 0
    	IniRead, BAutoStart4, %SelectedFile%, Settings, cfgBAutoStart4, 0
    	IniRead, BAutoStart5, %SelectedFile%, Settings, cfgBAutoStart5, 0
    	IniRead, BAutoEnter1, %SelectedFile%, Settings, cfgBAutoEnter1, 333
    	IniRead, BAutoEnter2, %SelectedFile%, Settings, cfgBAutoEnter2, 333
    	IniRead, BAutoEnter3, %SelectedFile%, Settings, cfgBAutoEnter3, 333
    	IniRead, BAutoEnter4, %SelectedFile%, Settings, cfgBAutoEnter4, 333
    	IniRead, BAutoEnter5, %SelectedFile%, Settings, cfgBAutoEnter5, 333
    	IniRead, BAutoEnter6, %SelectedFile%, Settings, cfgBAutoEnter6, 333
    	IniRead, BAutoEnter7, %SelectedFile%, Settings, cfgBAutoEnter7, 333
    	IniRead, BAutoEnter8, %SelectedFile%, Settings, cfgBAutoEnter8, 333
    	IniRead, BAutoEnter9, %SelectedFile%, Settings, cfgBAutoEnter9, 333
    	IniRead, BEnableDoubleClick, %SelectedFile%, Settings, cfgBEnableDoubleClick, 1
    	IniRead, BEnableDCL, %SelectedFile%, Settings, cfgBEnableDCL, 1
    	IniRead, BEnableDCR, %SelectedFile%, Settings, cfgBEnableDCR, 1
    	IniRead, BEnableWU, %SelectedFile%, Settings, cfgBEnableWU, 1
    	IniRead, BEnableWD, %SelectedFile%, Settings, cfgBEnableWD, 1
    	IniRead, BEnableMouseGesture, %SelectedFile%, Settings, cfgBEnableMouseGesture, 0
    	IniRead, BEnableGreatRift, %SelectedFile%, Settings, cfgBEnableGreatRift, 0
    	IniRead, BEnableStatus, %SelectedFile%, Settings, cfgBEnableStatus, 0
    	IniRead, BCancelDC, %SelectedFile%, Settings, cfgBCancelDC, 0
    	IniRead, BMButtonRelease, %SelectedFile%, Settings, cfgBMButtonRelease, 1
             
    	IniRead, BItemSX, %SelectedFile%, Settings, cfgBItemSX, 0.728
    	IniRead, BItemSY, %SelectedFile%, Settings, cfgBItemSY, 0.511
    	IniRead, BItemEX, %SelectedFile%, Settings, cfgBItemEX, 0.991
    	IniRead, BItemEY, %SelectedFile%, Settings, cfgBItemEY, 0.79
    	IniRead, BOrangePosX, %SelectedFile%, Settings, cfgBOrangePosX, 0.088
    	IniRead, BOrangePosY, %SelectedFile%, Settings, cfgBOrangePosY, 0.264
    	IniRead, BWhitePosX, %SelectedFile%, Settings, cfgBWhitePosX, 0.135
    	IniRead, BWhitePosY, %SelectedFile%, Settings, cfgBWhitePosY, 0.268
    	IniRead, BBluePosX, %SelectedFile%, Settings, cfgBBluePosX, 0.169
    	IniRead, BBluePosY, %SelectedFile%, Settings, cfgBBluePosY, 0.268
    	IniRead, BYellowPosX, %SelectedFile%, Settings, cfgBYellowPosX, 0.203
    	IniRead, BYellowPosY, %SelectedFile%, Settings, cfgBYellowPosY, 0.268
    	IniRead, BPutPosX, %SelectedFile%, Settings, cfgBPutPosX, 0.374
    	IniRead, BPutPosY, %SelectedFile%, Settings, cfgBPutPosY, 0.778 
    	IniRead, BRebuildPosX, %SelectedFile%, Settings, cfgBRebuildPosX, 0.125
    	IniRead, BRebuildPosY, %SelectedFile%, Settings, cfgBRebuildPosY, 0.765
    	IniRead, BPrePosX, %SelectedFile%, Settings, cfgBPrePosX, 0.303
    	IniRead, BPrePosY, %SelectedFile%, Settings, cfgBPrePosY, 0.778
    	IniRead, BNextPosX, %SelectedFile%, Settings, cfgBNextPosX, 0.445
    	IniRead, BNextPosY, %SelectedFile%, Settings, cfgBNextPosY, 0.778
        
    	IniRead, BAttributeAdjust, %SelectedFile%, Settings, cfgBAttributeAdjust, 0
    	IniRead, BMainProp, %SelectedFile%, Settings, cfgBMainProp, 0
    	IniRead, BStam, %SelectedFile%, Settings, cfgBStam, 2
    	IniRead, BSpeed, %SelectedFile%, Settings, cfgBSpeed, 50
    	IniRead, BEnergy, %SelectedFile%, Settings, cfgBEnergy, 50
    	IniRead, BRangDamage, %SelectedFile%, Settings, cfgBRangDamage, 1
    	IniRead, BAutoCloseWin, %SelectedFile%, Settings, cfgBAutoCloseWin, 0
    	IniRead, BUpgradeCount, %SelectedFile%, Settings, cfgBUpgradeCount, 4
        
    	IniRead, BFMStopKey1, %SelectedFile%, ForceMove, cfgBFMStopKey1, 0
    	IniRead, BFMStopKey2, %SelectedFile%, ForceMove, cfgBFMStopKey2, 0
    	IniRead, BFMStopKey3, %SelectedFile%, ForceMove, cfgBFMStopKey3, 0
    	IniRead, BFMStopKey4, %SelectedFile%, ForceMove, cfgBFMStopKey4, 0
    	IniRead, BFMStopKey5, %SelectedFile%, ForceMove, cfgBFMStopKey5, 0
    	IniRead, BFMStopLM, %SelectedFile%, ForceMove, cfgBFMStopLM, 0
    	IniRead, BFMStopRM, %SelectedFile%, ForceMove, cfgBFMStopRM, 0
    	IniRead, BFMStopCH1, %SelectedFile%, ForceMove, cfgBFMStopCH1, 0
    	IniRead, BFMStopCH2, %SelectedFile%, ForceMove, cfgBFMStopCH2, 0
        
    	IniRead, BPUStopKey1, %SelectedFile%, PickUp, cfgBPUStopKey1, 0
    	IniRead, BPUStopKey2, %SelectedFile%, PickUp, cfgBPUStopKey2, 0
    	IniRead, BPUStopKey3, %SelectedFile%, PickUp, cfgBPUStopKey3, 0
    	IniRead, BPUStopKey4, %SelectedFile%, PickUp, cfgBPUStopKey4, 0
    	IniRead, BPUStopKey5, %SelectedFile%, PickUp, cfgBPUStopKey5, 0
    	IniRead, BPUStopLM, %SelectedFile%, PickUp, cfgBPUStopLM, 0
    	IniRead, BPUStopRM, %SelectedFile%, PickUp, cfgBPUStopRM, 0
    	IniRead, BPUStopCH1, %SelectedFile%, PickUp, cfgBPUStopCH1, 0
    	IniRead, BPUStopCH2, %SelectedFile%, PickUp, cfgBPUStopCH2, 0
    	IniRead, BCfgDoc_Skill, %SelectedFile%, ConfigDocument, CfgBCfgDoc_Skill, ...
    	IniRead, BCfgDoc_OP, %SelectedFile%, ConfigDocument, CfgBCfgDoc_OP, ...
        BCfgDoc_Skill := StrReplace(BCfgDoc_Skill, "||", "`n")
        BCfgDoc_OP := StrReplace(BCfgDoc_OP, "||", "`n")

        if BGlobalMouseDelay is not integer
        {
            BGlobalMouseDelay := 10
        }
        else
        {
            if (BGlobalMouseDelay < 5)
                BGlobalMouseDelay := 5
        }
        if BGlobalKeyDelay is not integer
        {
            BGlobalKeyDelay := 10
        }
        else
        {
            if (BGlobalKeyDelay < 5)
                BGlobalKeyDelay := 5
        }
        SetKeyDelay,%BGlobalMouseDelay%
        SetMouseDelay,%BGlobalKeyDelay%
        
        ;Hotkey, IfWinActive, ahk_class %BServer%
        if (BStand3 = 1)
        {
            if (BHotkey3)
                Hotkey, %BHotkey3%, RunHotkey3
        }
        if (BStand4 = 1)
        {
            if (BHotkey4)
                Hotkey, %BHotkey4%, RunHotkey4
        }
        if (BStand5 = 1)
        {
            if (BHotkey5)
                Hotkey, %BHotkey5%, RunHotkey5
        }

        /*
    	GuiControl, choose, BServer, %BServer%
    	GuiControl, choose, BMoveKey, %BMoveKey%
    	GuiControl, choose, BStandKey, %BStandKey%
    	GuiControl, choose, BSkillKey1, %BSkillKey1%
    	GuiControl, choose, BSkillKey2, %BSkillKey2%
    	GuiControl, choose, BSkillKey3, %BSkillKey3%
    	GuiControl, choose, BSkillKey4, %BSkillKey4%
        */
        if (Instr(serverItem , BServer) = 0)
            GuiControl,, BServer, %BServer%
    	GuiControl, ChooseString, BServer, %BServer%
        
        if (Instr(moveItem , BMoveKey) = 0)
            GuiControl,, BMoveKey, %BMoveKey%
    	GuiControl, ChooseString, BMoveKey, %BMoveKey%
        
        if (Instr(standItem , BStandKey) = 0)
            GuiControl,, BStandKey, %BStandKey%
    	GuiControl, ChooseString, BStandKey, %BStandKey%
        
        if (Instr(avoidItem , BAvoidKey) = 0)
            GuiControl,, BAvoidKey, %BAvoidKey%
    	GuiControl, ChooseString, BAvoidKey, %BAvoidKey%
        
        if (Instr(lmouseItem , BLMouseKey) = 0)
            GuiControl,, BLMouseKey, %BLMouseKey%
    	GuiControl, ChooseString, BLMouseKey, %BLMouseKey%
        
        if (Instr(horseItem , BHorseKey) = 0)
            GuiControl,, BHorseKey, %BHorseKey%
    	GuiControl, ChooseString, BHorseKey, %BHorseKey%
        
        if (Instr(skillkye1Item , BSkillKey1) = 0)
            GuiControl,, BSkillKey1, %BSkillKey1%
    	GuiControl, ChooseString, BSkillKey1, %BSkillKey1%
        
        if (Instr(skillkye2Item , BSkillKey2) = 0)
            GuiControl,, BSkillKey2, %BSkillKey2%
    	GuiControl, ChooseString, BSkillKey2, %BSkillKey2%
        
        if (Instr(skillkye3Item , BSkillKey3) = 0)
            GuiControl,, BSkillKey3, %BSkillKey3%
    	GuiControl, ChooseString, BSkillKey3, %BSkillKey3%
        
        if (Instr(skillkye4Item , BSkillKey4) = 0)
            GuiControl,, BSkillKey4, %BSkillKey4%
    	GuiControl, ChooseString, BSkillKey4, %BSkillKey4%
        
    	GuiControl, choose, BFouceMove, %BFouceMove%
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        GuiControl, choose, BMButton, 0
        cfg_str := "A|" . BMButton . "|"
        if(Instr(cfg_str, "|1|") > 0)
            GuiControl, choose, BMButton, 1
        if(Instr(cfg_str, "|2|") > 0)
            GuiControl, choose, BMButton, 2
        if(Instr(cfg_str, "|3|") > 0)
            GuiControl, choose, BMButton, 3
        if(Instr(cfg_str, "|4|") > 0)
            GuiControl, choose, BMButton, 4
        if(Instr(cfg_str, "|5|") > 0)
            GuiControl, choose, BMButton, 5
        if(Instr(cfg_str, "|6|") > 0)
            GuiControl, choose, BMButton, 6
        if(Instr(cfg_str, "|7|") > 0)
            GuiControl, choose, BMButton, 7
        if(Instr(cfg_str, "|8|") > 0)
            GuiControl, choose, BMButton, 8
        if(Instr(cfg_str, "|9|") > 0)
            GuiControl, choose, BMButton, 9
        if(Instr(cfg_str, "|10|") > 0)
            GuiControl, choose, BMButton, 10
        if(Instr(cfg_str, "|11|") > 0)
            GuiControl, choose, BMButton, 11
        if(Instr(cfg_str, "|12|") > 0)
            GuiControl, choose, BMButton, 12
        if(Instr(cfg_str, "|13|") > 0)
            GuiControl, choose, BMButton, 13
        if(Instr(cfg_str, "|14|") > 0)
            GuiControl, choose, BMButton, 14
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    	GuiControl, , BAuto1, %BAuto1%
    	GuiControl, , BAuto2, %BAuto2%
    	GuiControl, , BAuto3, %BAuto3%
    	GuiControl, , BAuto4, %BAuto4%
    	GuiControl, , BAutoL, %BAutoL%
    	GuiControl, , BAutoR, %BAutoR%
    	GuiControl, , BAutoMouseL, %BAutoMouseL%
    	GuiControl, , BAutoPotion, %BAutoPotion%
    	GuiControl, , BExitL, %BExitL%
    	GuiControl, , BDelay1, %BDelay1%
    	GuiControl, , BDelay2, %BDelay2%
    	GuiControl, , BDelay3, %BDelay3%
    	GuiControl, , BDelay4, %BDelay4%
    	GuiControl, , BDelayL, %BDelayL%
    	GuiControl, , BDelayR, %BDelayR%
    	GuiControl, , BDelayMouseL, %BDelayMouseL%
    	GuiControl, , BPotionDelay1, %BPotionDelay1%
    	GuiControl, , BDelay12, %BDelay12%
    	GuiControl, , BDelay22, %BDelay22%
    	GuiControl, , BDelay32, %BDelay32%
    	GuiControl, , BDelay42, %BDelay42%
    	GuiControl, , BDelayL2, %BDelayL2%
    	GuiControl, , BDelayR2, %BDelayR2%
    	GuiControl, , BDelayMouseL2, %BDelayMouseL2%
    	GuiControl, , BKeep1, %BKeep1%
    	GuiControl, , BKeep2, %BKeep2%
    	GuiControl, , BKeep3, %BKeep3%
    	GuiControl, , BKeep4, %BKeep4%
    	GuiControl, , BKeepL, %BKeepL%
    	GuiControl, , BKeepR, %BKeepR%
    	GuiControl, , BKeepMouseL, %BKeepMouseL%
    	GuiControl, , BHotkey3, %BHotkey3%
    	GuiControl, , BHotkey4, %BHotkey4%
    	GuiControl, , BHotkey5, %BHotkey5%
    	GuiControl, choose, BModeL, %BModeL%
    	GuiControl, choose, BModeR, %BModeR%
    	GuiControl, choose, BModeReleaseL, %BModeReleaseL%
    	GuiControl, choose, BModeReleaseR, %BModeReleaseR%
    	GuiControl, choose, BDClickL, %BDClickL%
    	GuiControl, choose, BDClickR, %BDClickR%
    	GuiControl, choose, BWheelUp, %BWheelUp%
    	GuiControl, choose, BWheelDown, %BWheelDown%
        if (BModeL >= 3 and BModeL <=6)
        {
            GuiControl, Enable, BStandL
        }
        else
        {
            GuiControl, Disable, BStandL
        }
        if (BModeR >= 3 and BModeR <=6)
        {
            GuiControl, Enable, BStandR
        }
        else
        {
            GuiControl, Disable, BStandR
        }
    	GuiControl, choose, BMode3, %BMode3%
    	GuiControl, choose, BMode4, %BMode4%
    	GuiControl, choose, BMode5, %BMode5%
    	GuiControl, , BForceMove, %BForceMove%
    	GuiControl, , Bchannel, %Bchannel%
    	GuiControl, choose, BchannelKey, %BchannelKey%
    	GuiControl, , Bchannel2, %Bchannel2%
    	GuiControl, choose, BchannelKey2, %BchannelKey2%
        GuiControl, choose, BEamon, %BEamon%
        GuiControl, choose, BSmashType, %BSmashType%
        GuiControl, choose, BProtectZone, %BProtectZone%
        GuiControl, choose, BDispMode, %BDispMode%
        GuiControl, , BMouseDelay, %BMouseDelay%
        GuiControl, , BGlobalMouseDelay, %BGlobalMouseDelay%
        GuiControl, , BGlobalKeyDelay, %BGlobalKeyDelay%
    	GuiControl, , BStandL, %BStandL%
    	GuiControl, , BStandR, %BStandR%
    	GuiControl, , BStand3, %BStand3%
    	GuiControl, , BStand4, %BStand4%
    	GuiControl, , BStand5, %BStand5%
    	GuiControl, , BOnceL, %BOnceL%
    	GuiControl, , BOnceR, %BOnceR%
    	GuiControl, , BOnce3, %BOnce3%
    	GuiControl, , BOnce4, %BOnce4%
    	GuiControl, , BOnce5, %BOnce5%
    	GuiControl, , BMarcoAS1, %BMarcoAS1%
    	GuiControl, , BMarcoAS2, %BMarcoAS2%
    	GuiControl, , BMarcoAS3, %BMarcoAS3%
    	GuiControl, , BMarcoAS4, %BMarcoAS4%
    	GuiControl, , BMarcoAS5, %BMarcoAS5%
    	GuiControl, , BAutoStart3, %BAutoStart3%
    	GuiControl, , BAutoStart4, %BAutoStart4%
    	GuiControl, , BAutoStart5, %BAutoStart5%
    	GuiControl, , BAutoEnter1, %BAutoEnter1%
    	GuiControl, , BAutoEnter2, %BAutoEnter2%
    	GuiControl, , BAutoEnter3, %BAutoEnter3%
    	GuiControl, , BAutoEnter4, %BAutoEnter4%
    	GuiControl, , BAutoEnter5, %BAutoEnter5%
    	GuiControl, , BAutoEnter6, %BAutoEnter6%
    	GuiControl, , BAutoEnter7, %BAutoEnter7%
    	GuiControl, , BAutoEnter8, %BAutoEnter8%
    	GuiControl, , BAutoEnter9, %BAutoEnter9%
    	;GuiControl, , BEnableDoubleClick, %BEnableDoubleClick%
    	GuiControl, choose, BEnableDoubleClick, %BEnableDoubleClick%
    	GuiControl, choose, BEnableDCL, %BEnableDCL%
    	GuiControl, choose, BEnableDCR, %BEnableDCR%
    	GuiControl, choose, BEnableWU, %BEnableWU%
    	GuiControl, choose, BEnableWD, %BEnableWD%
    	GuiControl, , BEnableMouseGesture, %BEnableMouseGesture%
    	GuiControl, , BEnableGreatRift, %BEnableGreatRift%
    	GuiControl, , BEnableStatus, %BEnableStatus%
    	GuiControl, , BCancelDC, %BCancelDC%
    	GuiControl, choose, BMButtonRelease, %BMButtonRelease%
        
    	GuiControl, , BItemSX, %BItemSX%
    	GuiControl, , BItemSY, %BItemSY%
    	GuiControl, , BItemEX, %BItemEX%
    	GuiControl, , BItemEY, %BItemEY%
    	GuiControl, , BOrangePosX, %BOrangePosX%
    	GuiControl, , BOrangePosY, %BOrangePosY%
    	GuiControl, , BWhitePosX, %BWhitePosX%
    	GuiControl, , BWhitePosY, %BWhitePosY%
    	GuiControl, , BBluePosX, %BBluePosX%
    	GuiControl, , BBluePosY, %BBluePosY%
    	GuiControl, , BYellowPosX, %BYellowPosX%
    	GuiControl, , BYellowPosY, %BYellowPosY%
    	GuiControl, , BPutPosX, %BPutPosX%
    	GuiControl, , BPutPosY, %BPutPosY%
    	GuiControl, , BRebuildPosX, %BRebuildPosX%
    	GuiControl, , BRebuildPosY, %BRebuildPosY%
    	GuiControl, , BPrePosX, %BPrePosX%
    	GuiControl, , BPrePosY, %BPrePosY%
    	GuiControl, , BNextPosX, %BNextPosX%
    	GuiControl, , BNextPosY, %BNextPosY%
        
    	GuiControl, , BAttributeAdjust, %BAttributeAdjust%
    	GuiControl, , BMainProp, %BMainProp%
    	GuiControl, , BStam, %BStam%
    	GuiControl, , BSpeed, %BSpeed%
    	GuiControl, , BEnergy, %BEnergy%
    	GuiControl, , BRangDamage, %BRangDamage%
    	GuiControl, , BAutoCloseWin, %BAutoCloseWin%
    	GuiControl, , BUpgradeCount, %BUpgradeCount%
  	}
    else
    {
        SelectedFile = %A_ScriptDir%\D4.sadan.cfg
        GuiControl, , ConfigPath, %SelectedFile%
        msgbox "Read config file failed"
    }
	return
}

ReadFileUserMarco:
{
    m_SettingFile = %SelectedFile%
	if FileExist( m_SettingFile )
	{
            Global currentMarco
            marcoNum := currentMarco
            ActionArrayIndex%marcoNum%  := 0
            i := 0
            loop
            {
                if (i >= actionArrayCount%marcoNum%)
                    break
                i := i + 1
                IniRead, actionStr, %SelectedFile%, UserMarco%marcoNum%, cfgAction%i%
                if (actionStr != "ERROR")
                {
                    Array := StrSplit(actionStr, ",", ,2)
                    item_st := array[1]
                    content_st := array[2]
                    
                    yValue := 60 + ((i - 1) * 20)
                    
                    Gui, UserMarcoSet%marcoNum%:Add, CheckBox, x25 y%yValue% h20 vBActionArrayIndex%marcoNum%%i%, Step%i%:
                    
                    Gui, UserMarcoSet%marcoNum%:Add, DropDownList, x90 y%yValue% w100 AltSubmit vBActionArrayItem%marcoNum%%i%, %actionItem%
                    GuiControl, UserMarcoSet%marcoNum%:choose, BActionArrayItem%marcoNum%%i%, %item_st%
                    
                    Gui, UserMarcoSet%marcoNum%:Add, Edit, x200 y%yValue% w250 h20 Multi vBActionArrayContent%marcoNum%%i%      
                    t_strMarco := StrReplace(content_st, "||", "`n")
                    GuiControl, UserMarcoSet%marcoNum%:Text, BActionArrayContent%marcoNum%%i%, %t_strMarco%
                    
                    ActionArrayIndex%marcoNum% := i
                    actionArrayStatus%marcoNum%[i] := 1
                }
                else
                {
                    break
                }

            }
    }
}
return

ReadFileForceMove:
{
   GuiControl, ForceMove:, BFMStopLM, %BFMStopLM%
   GuiControl, ForceMove:, BFMStopRM, %BFMStopRM%
   GuiControl, ForceMove:, BFMStopCH1, %BFMStopCH1%
   GuiControl, ForceMove:, BFMStopCH2, %BFMStopCH2%
   GuiControl, ForceMove:, BFMStopKey1, %BFMStopKey1%
   GuiControl, ForceMove:, BFMStopKey2, %BFMStopKey2%
   GuiControl, ForceMove:, BFMStopKey3, %BFMStopKey3%
   GuiControl, ForceMove:, BFMStopKey4, %BFMStopKey4%
   GuiControl, ForceMove:, BFMStopKey5, %BFMStopKey5%
}
return

ReadFilePickUp:
{
   GuiControl, PickUp:, BPUStopLM, %BPUStopLM%
   GuiControl, PickUp:, BPUStopRM, %BPUStopRM%
   GuiControl, PickUp:, BPUStopCH1, %BPUStopCH1%
   GuiControl, PickUp:, BPUStopCH2, %BPUStopCH2%
   GuiControl, PickUp:, BPUStopKey1, %BPUStopKey1%
   GuiControl, PickUp:, BPUStopKey2, %BPUStopKey2%
   GuiControl, PickUp:, BPUStopKey3, %BPUStopKey3%
   GuiControl, PickUp:, BPUStopKey4, %BPUStopKey4%
   GuiControl, PickUp:, BPUStopKey5, %BPUStopKey5%
}
return

ReadFileConfigDocument:
{
    BCfgDoc_Skill := StrReplace(BCfgDoc_Skill, "||", "`n")
    BCfgDoc_OP := StrReplace(BCfgDoc_OP, "||", "`n")
    GuiControl, ConfigDocumentWin:, BCfgDoc_Skill, %BCfgDoc_Skill%
    GuiControl, ConfigDocumentWin:, BCfgDoc_OP, %BCfgDoc_OP%
}
return

;-----------------------------Show Macro Running Status--------------------------------------------------
MyStatusGui:
{
    global status_window_title = status_title
    Gui statusGui:new, , %status_window_title%
    CustomColor := "FF0000" ; Can be any RGB color (will be set transparent below).
    Gui statusGui: +LastFound +AlwaysOnTop -Caption +ToolWindow ; +ToolWindow avoids taskbar button and alt-tab menu
    Gui, statusGui: Color, %CustomColor%
    Gui, statusGui: Font, s20 ; Select font size
    Gui, statusGui: Add, Text, vStatusText cLime , XXXXXXXXXX YY ; XX & YY used for auto adjust window size  
    WinSet, TransColor, %CustomColor% 150, %status_window_title% ;Make specified color pixels transparent, and font transparency 150
    WinSet, ExStyle, ^0x20, %status_window_title% 
    ;SetTimer, UpdateMarcoStatus, 1000
    if (BEnableStatus = 1)
    {
        SetTimer, UpdateMarcoStatus, 1000
    }
    else
    {
        SetTimer, UpdateMarcoStatus, off
    }    
    
    global info_window_title = info_title
    Gui infoGui:new, , %info_window_title%
    CustomColor_Info := "FF0000" ; Can be any RGB color (will be set transparent below).
    Gui infoGui: +LastFound +AlwaysOnTop -Caption +ToolWindow ; +ToolWindow avoids taskbar button and alt-tab menu
    Gui, infoGui: Color, %CustomColor_Info%
    Gui, infoGui: Font, s20 ; Select font size
    Gui, infoGui: Add, Text, vinfoText cLime , XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX YY ; XX & YY used for auto adjust window size  
    WinSet, TransColor, %CustomColor_Info% 150, %info_window_title% ;Make specified color pixels transparent, and font transparency 150
    WinSet, ExStyle, ^0x20, %info_window_title%   
    
    global op_window_title = op_title
    Gui opGui:new, , %op_window_title%
    CustomColor_Info := "FF0000" ; Can be any RGB color (will be set transparent below).
    Gui opGui: +LastFound +AlwaysOnTop -Caption +ToolWindow ; +ToolWindow avoids taskbar button and alt-tab menu
    Gui, opGui: Color, %CustomColor_Info%
    Gui, opGui: Font, s20 ; Select font size
    Gui, opGui: Add, Text, vopText cLime , XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX YY ; XX & YY used for auto adjust window size  
    WinSet, TransColor, %CustomColor_Info% 150, %op_window_title% ;Make specified color pixels transparent, and font transparency 150
    WinSet, ExStyle, ^0x20, %op_window_title% 
    
    
    return
}

EnableStatusChange:
{
    GuiControlGet, BEnableStatus
    if (BEnableStatus = 1)
    {
        SetTimer, UpdateMarcoStatus, 1000
    }
    else
    {
        SetTimer, UpdateMarcoStatus, off
    }
    return
}

UpdateMarcoStatus:
{
    if (BEnableStatus = 1)
    {
        IfWinActive, %BServer%
        {
            WinGetPos, X, Y, current_Width, current_Height, %BServer%
            sysget titlebar_height, 4, %BServer%
            if (BDispMode = 2)
            {
                titlebar_height := 0
            }
            status_x := X + current_Width*4/9
            status_y := Y + (current_Height - titlebar_height)*1/1000+titlebar_height
            if (boss_Enable = 0)
            {
                GuiControl, statusGui:, StatusText, Macro not running
            }
            else
            {
                GuiControl, statusGui:, StatusText, Macro is running
            }
            WinSet,Redraw,,%status_window_title%
            Gui, statusGui:Show, x%status_x% y%status_y% AutoSize NoActivate ; Do not activate window to avoid changing current active window
            
        }
        else
        {
            Gui, statusGui:hide
        }
    }
    else
    {
        Sleep 100
    }
    return
}

DisplayInfo(text)
{
    global BServer, BDispMode, infoGui, info_window_title, infoText
    IfWinActive, %BServer%
    {
        WinGetPos, X, Y, current_Width, current_Height, %BServer%
        sysget titlebar_height, 4, %BServer%
        if (BDispMode = 2)
        {
            titlebar_height := 0
        }
        disp_x := X + current_Width*4/9
        disp_y := Y + (current_Height - titlebar_height)*1/2+titlebar_height
        ; Set font
        Gui, infoGui:Font, s14 CYellow, Arial  ; Set font size 10, font Arial
        ; Refresh control font style
        GuiControl, infoGui:Font, infoText  ; Reapply font setting
        GuiControl, infoGui:, infoText, %text%
        WinSet,Redraw,,%info_window_title%
        Gui, infoGui:Show, x%disp_x% y%disp_y% AutoSize NoActivate ; Do not activate window to avoid changing current active window
    }
    else
    {
        Gui, infoGui:hide
    } 
}

DisplayInfoClose()
{
    Gui, infoGui:hide
}

DisplayOPInfo(text)
{
    global BServer, BDispMode, opGui, op_window_title, opText
    IfWinActive, %BServer%
    {
        WinGetPos, X, Y, current_Width, current_Height, %BServer%
        sysget titlebar_height, 4, %BServer%
        if (BDispMode = 2)
        {
            titlebar_height := 0
        }
        disp_x := current_Width*4/9
        disp_y := (current_Height - titlebar_height)*1/4+titlebar_height
        GuiControl, opGui:, opText, %text%
        WinSet,Redraw,,%op_window_title%
        Gui, opGui:Show, x%disp_x% y%disp_y% AutoSize NoActivate ; Do not activate window to avoid changing current active window
    }
    else
    {
        Gui, opGui:hide
    } 
}

DisplayOPInfoClose()
{
    Gui, opGui:hide
}
;----------------------------------------------------------------------------------------------



;---------------Window Hotkeys-----------------------------------------------------
#IfWinActive ahk_group GameGroup

XButton1::                            
{       
    boss_Enable:=!boss_Enable      
    If (boss_Enable=0)                   
    {
        EndFunc()
    }
    Else                                        
    {
        EndFunc()
        Gosub StartMarco
    }
}
Return

F10::                            
{       
    Gosub Create_D2R_Game
}
Return


F11::                            
{       
    Gosub Create_D2R_Game_DC
}
Return

'::
F12::                            
{       
    create_d2r_toggle := 0
}
Return

~*XButton2::                           
{       
    t_server := "Last Epoch"
    if (BServer = t_server)
    {
        Send {shift down}
        Sleep 200
        setTimer, MouseRButton, %BDelayR%
    }
    else
        send {x}
}
Return

*XButton2 up::                           
{       
    t_server := "Last Epoch"
    if (BServer = t_server)
    {
        setTimer, MouseRButton, off
        Send {shift up}
    }
}
Return

^!m:: ; Hotkey: Ctrl + Alt + M
{
    ; Get current active window handle
    WinGet, hWnd, ID, A
    if !hWnd {
        return
    }

    ; Restore window state (if maximized)
    WinRestore, ahk_id %hWnd%
    Sleep, 50

    ; Get work area (excluding taskbar)
    VarSetCapacity(RECT, 16, 0)
    DllCall("SystemParametersInfo", UInt, 0x0030, UInt, 0, Ptr, &RECT)

    WorkLeft   := NumGet(RECT, 0, "Int")
    WorkTop    := NumGet(RECT, 4, "Int")
    WorkRight  := NumGet(RECT, 8, "Int")
    WorkBottom := NumGet(RECT, 12, "Int")

    WorkWidth  := WorkRight - WorkLeft
    WorkHeight := WorkBottom - WorkTop

    ; Get window size
    WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %hWnd%

    ; Calculate new position (align bottom left)
    NewX := WorkLeft
    NewY := WorkHeight - WinHeight

    ; Limit min to 0
    NewX := (NewX < 0) ? 0 : NewX
    NewY := (NewY < 0) ? 0 : NewY

    ; Move window
    WinMove, ahk_id %hWnd%, , %NewX%, %NewY%
}
return

^!/:: ; Hotkey: Ctrl + Alt + /
{
    ; Get current active window handle
    WinGet, hWnd, ID, A
    if !hWnd {
        return
    }

    ; Restore window state (if maximized)
    WinRestore, ahk_id %hWnd%
    Sleep, 50

    ; Get work area (excluding taskbar)
    VarSetCapacity(RECT, 16, 0)
    DllCall("SystemParametersInfo", UInt, 0x0030, UInt, 0, Ptr, &RECT)

    WorkLeft   := NumGet(RECT, 0, "Int")
    WorkTop    := NumGet(RECT, 4, "Int")
    WorkRight  := NumGet(RECT, 8, "Int")
    WorkBottom := NumGet(RECT, 12, "Int")

    WorkWidth  := WorkRight - WorkLeft
    WorkHeight := WorkBottom - WorkTop

    ; Get window size
    WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %hWnd%

    ; Calculate new position (align bottom right)
    NewX := WorkWidth - WinWidth
    NewY := WorkHeight - WinHeight

    ; Limit min to 0
    NewX := (NewX < 0) ? 0 : NewX
    NewY := (NewY < 0) ? 0 : NewY

    ; Move window
    WinMove, ahk_id %hWnd%, , %NewX%, %NewY%
}
return

/*
F12::
{
    EndFunc() 
    boss_Enable=0
}
return
*/

~Tab::
{
    /*
    If (boss_Enable=1) 
    {
        v_Tab:=!v_Tab
        ;Suspend Toggle
        If (v_Tab)
        { 
            if (BAutoL = 1)
            {
                SetTimer, MouseLButton, off
            }  
            if (BAutoR = 1)
            {
                SetTimer, MouseRButton, off
            }  
        }
        Else 
        { 
            if (BAutoL = 1)
            {
                SetTimer, MouseLButton, %BDelayL%
            }
            if (BAutoR = 1)
            {
                SetTimer, MouseRButton, %BDelayR%
            }
        }
    }   
    */
}
Return


;;;;;;;;Left Button Press;;;;;;;;;;;;;;
~*LButton:: 
; Get current time (milliseconds)
currentTime := A_TickCount
; Calculate time interval since last left button press
timeSinceLastClick := currentTime - lastLClickTime    
lastLClickTime := A_TickCount 
   
If (boss_Enable=0) 
{
    if (BEnableDCL = 3 or BEnableDCL = 4)
    {
        intInterval := 150 ; If two clicks in this interval, consider double click.
        if (A_PriorKey = "LButton" and A_TimeSincePriorHotkey < intInterval) ; 
        ;if (timeSinceLastClick < intInterval) ; 
        {
            if (BDClickL = 2)
            {
                send {%BSkillKey1%}
            }
            if (BDClickL = 3)
            {
                send {%BSkillKey2%}
            }
            if (BDClickL = 4)
            {
                send {%BSkillKey3%}
            }
            if (BDClickL = 5)
            {
                send {%BSkillKey4%}
            }
            if (BDClickL = 6)
            {
                send {%BAvoidKey%}
            }
            if (BDClickL = 7)
            {
                send {%BLMouseKey%}
            }
            if (BDClickL = 8) ;Custom macro1
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco1
            }
            if (BDClickL = 9)
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco2
            }
            if (BDClickL = 10)
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco3
            }
            if (BDClickL = 11)
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco4
            }
            if (BDClickL = 12)
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco5
            }
            if (BDClickL >= 13 and BDClickL <= 17)
            {
                marcoAccessKey := "dClickL"
                RunUserMarcoX(BDClickL-7)
            }
        }
    }
}
If (boss_Enable=1)                      
{
    if (BEnableDCL = 2 or BEnableDCL = 4)
    {
        intInterval := 200 ; If two clicks in this interval, consider double click.
        ;if (timeSinceLastClick < intInterval)
        if (A_PriorKey = "LButton" and A_TimeSincePriorHotkey < intInterval) ; 
        {
            if (BDClickL = 2)
            {
                send {%BSkillKey1%}
            }
            if (BDClickL = 3)
            {
                send {%BSkillKey2%}
            }
            if (BDClickL = 4)
            {
                send {%BSkillKey3%}
            }
            if (BDClickL = 5)
            {
                send {%BSkillKey4%}
            }
            if (BDClickL = 6)
            {
                send {%BAvoidKey%}
            }
            if (BDClickL = 7)
            {
                send {%BLMouseKey%}
            }
            if (BDClickL = 8) ;Custom macro1
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco1
            }
            if (BDClickL = 9)
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco2
            }
            if (BDClickL = 10)
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco3
            }
            if (BDClickL = 11)
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco4
            }
            if (BDClickL = 12)
            {
                marcoAccessKey := "dClickL"
                Gosub RunUserMarco5
            }
            if (BDClickL >= 13 and BDClickL <= 17)
            {
                marcoAccessKey := "dClickL"
                RunUserMarcoX(BDClickL-7)
            }
            return
        }
    }

    if (bModeL = 2)
    {
        Gosub StartForceMove
        send {%BMoveKey% down}
    }
    if ((bModeL >=3 and bModeL <=11) or (bModeL = 15))
    {
        if (BStandL = 1 and bModeL >=3 and bModeL <=6)
        {
            send {%BStandKey% down}
        }
        if (BStandL = 1 and bModeL = 15)
        {
            send {%BStandKey% down}
        }

        if (bModeL >=7 and bModeL <=11)
            marcoLMouseHold := 1
        if (BOnceL = 1)
        {
            if (bModeL = 3)
                send {%BSkillKey1%}
            if (bModeL = 4)
                send {%BSkillKey2%}
            if (bModeL = 5)
                send {%BSkillKey3%}
            if (bModeL = 6)
                send {%BSkillKey4%}
            ;-----------------------------------------
            if (bModeL = 7)
                Gosub RunUserMarco1
            if (bModeL = 8)
                Gosub RunUserMarco2
            if (bModeL = 9)
                Gosub RunUserMarco3
            if (bModeL = 10)
                Gosub RunUserMarco4
            if (bModeL = 11)
                Gosub RunUserMarco5
            ;-----------------------------------------
            if (bModeL = 15)
                send {%BLMouseKey%}
        }
        else
        {
            selectSkillLabelL := GetModeSkillLabel(bModeL, 1)
            if (IsLabel(selectSkillLabelL))
            {
                marcoTimerCount := 1 ;When loop execute, set counter to 1
                SetTimer, %selectSkillLabelL%, 1
            }
        }
    }
    if (bModeL = 12)    ;Continuous pickup
    {
        GoSub StartPickUp
        SetTimer, MouseLButton, 15
    }
    if (bModeL = 13)    ;Middle button switch status
    {
        GoSub MbuttonChangeStatus
    }
    if (bModeL = 14)    ;Dodge
    {
        send {space}
    }
    if (bModeL = 15)   ;Skill 5
    {
        send {%BLMouseKey%}
    }
}              
Return                         

*LButton Up::                        
If (boss_Enable=1)  
{
    if (bModeL = 2)
    {
        send {%BMoveKey% up}
        Gosub EndForceMove
    }
    if ((bModeL >=3 and bModeL <=11) or bModeL = 15)
    {
        if (BStandL = 1 and bModeL >=3 and bModeL <=6)
            send {%BStandKey% up}
        if (BStandL = 1 and bModeL = 15)
            send {%BStandKey% up}
        if (BOnceL != 1)
        {
            selectSkillLabelL := GetModeSkillLabel(bModeL, 1)
            if (IsLabel(selectSkillLabelL))
            {
                SetTimer, %selectSkillLabelL%, off
                ResumeModeSkillLabel(selectSkillLabelL) ;X restore skill key status use left button release custom macro to control
            }
        }
        if (bModeL >=7 and bModeL <=11) ;When left button is run custom macro, release left button to cancel macro loop
        {
            marcoLMouseHold := 0
        }
        if (BModeReleaseL >=1 and BModeReleaseL <=5)   ;When left button release select custom macro always execute
        {
            selectSkillLabelReleaseL := GetModeSkillLabel(BModeReleaseL, 100)
            if (IsLabel(selectSkillLabelReleaseL))
            {
                Gosub %selectSkillLabelReleaseL%
            }
        }
    }
    if (bModeL = 12)   ;Continuous pickup
    {
        SetTimer, MouseLButton, off
        Gosub EndPickUp
    }
    if (bModeL = 13 and BMButtonRelease = 2)    ;Middle button switch status and restore on release
    {
        GoSub MbuttonChangeStatus
    }
}
Return
;;;;;;;;Left Button Press;;;;;;;;;;;;;;

;;;;;;;;Right Button Press;;;;;;;;;;;;;;
~*RButton::  
; Get current time (milliseconds)
currentTime := A_TickCount
; Calculate time interval since last left button press
timeSinceLastClick := currentTime - lastRClickTime    
lastRClickTime := A_TickCount 
 
{
    if (BEnableMouseGesture = 1)
    {
        mousegetpos xpos1,ypos1
        settimer,gtrack,1 
    }
    
    
    If (boss_Enable=0) 
    {
        ;Non running right button function
        if ((BEnableDCR = 3 or BEnableDCR = 4))
        {
            intInterval := 150 ; If two clicks in this interval, consider double click.
            ;if (timeSinceLastClick < intInterval)
            if (A_PriorKey = "RButton" and A_TimeSincePriorHotkey < intInterval) ; 
            {
                if (BDClickR = 2)
                {
                    send {%BSkillKey1%}
                }
                if (BDClickR = 3)
                {
                    send {%BSkillKey2%}
                }
                if (BDClickR = 4)
                {
                    send {%BSkillKey3%}
                }
                if (BDClickR = 5)
                {
                    send {%BSkillKey4%}
                }
                if (BDClickR = 6)
                {
                    send {%BAvoidKey%}
                }
                if (BDClickR = 7)
                {
                    send {%BLMouseKey%}
                }
                if (BDClickR = 8) ;Custom macro1
                {
                    marcoAccessKey := "dClickR"
                    Gosub RunUserMarco1
                }
                if (BDClickR = 9)
                {
                    marcoAccessKey := "dClickR"
                    Gosub RunUserMarco2
                }
                if (BDClickR = 10)
                {
                    marcoAccessKey := "dClickR"
                    Gosub RunUserMarco3
                }
                if (BDClickR = 11)
                {
                    marcoAccessKey := "dClickR"
                    Gosub RunUserMarco4
                }
                if (BDClickR = 12)
                {
                    marcoAccessKey := "dClickR"
                    Gosub RunUserMarco5
                }
                if (BDClickR >= 13 and BDClickR <= 17)
                {
                    marcoAccessKey := "dClickR"
                    RunUserMarcoX(BDClickR-7)
                }
            }
        }
    }
    
    If (boss_Enable=1)
    {
        intInterval := 200 ; If two clicks in this interval, consider double click.
        if (A_PriorKey = "RButton" and A_TimeSincePriorHotkey < intInterval and (BEnableDCR = 2 or BEnableDCR = 4)) ;
        ;if (timeSinceLastClick < intInterval and (BEnableDCR = 2 or BEnableDCR = 4))
        {
            if (BDClickR = 2)
            {
                send {%BSkillKey1%}
            }
            if (BDClickR = 3)
            {
                send {%BSkillKey2%}
            }
            if (BDClickR = 4)
            {
                send {%BSkillKey3%}
            }
            if (BDClickR = 5)
            {
                send {%BSkillKey4%}
            }
            if (BDClickR = 6)
            {
                send {%BAvoidKey%}
            }
            if (BDClickR = 7)
            {
                send {%BLMouseKey%}
            }
            if (BDClickR = 8) ;Custom macro1
            {
                marcoAccessKey := "dClickR"
                Gosub RunUserMarco1
            }
            if (BDClickR = 9)
            {
                marcoAccessKey := "dClickR"
                Gosub RunUserMarco2
            }
            if (BDClickR = 10)
            {
                marcoAccessKey := "dClickR"
                Gosub RunUserMarco3
            }
            if (BDClickR = 11)
            {
                marcoAccessKey := "dClickR"
                Gosub RunUserMarco4
            }
            if (BDClickR = 12)
            {
                marcoAccessKey := "dClickR"
                Gosub RunUserMarco5
            }
            if (BDClickR >= 13 and BDClickR <= 17)
            {
                marcoAccessKey := "dClickR"
                RunUserMarcoX(BDClickR-7)
            }
            return
        }
        
        if (bModeR = 2)
        {
            Gosub StartForceMove
            send {%BMoveKey% down}
        }
        if ((bModeR >=3 and bModeR <=11) or bModeR = 15)
        {
            if (BStandR = 1 and bModeR >=3 and bModeR <=6)
            {
                send {%BStandKey% down}
            }
            if (BStandR = 1 and bModeR = 15)
            {
                send {%BStandKey% down}
            }
            
            if (bModeR >=7 and bModeR <=11)
                marcoRMouseHold := 1
            if (BOnceR = 1)
            {
                if (bModeR = 3)
                    send {%BSkillKey1%}
                if (bModeR = 4)
                    send {%BSkillKey2%}
                if (bModeR = 5)
                    send {%BSkillKey3%}
                if (bModeR = 6)
                    send {%BSkillKey4%}
                ;-----------------------------------------
                if (bModeR = 7)
                    Gosub RunUserMarco1
                if (bModeR = 8)
                    Gosub RunUserMarco2
                if (bModeR = 9)
                    Gosub RunUserMarco3
                if (bModeR = 10)
                    Gosub RunUserMarco4
                if (bModeR = 11)
                    Gosub RunUserMarco5
                ;-----------------------------------------
                if (bModeR = 15)
                    send {%BLMouseKey%}
            }
            else
            {
                selectSkillLabelR := GetModeSkillLabel(bModeR, 2)
                if (IsLabel(selectSkillLabelR))
                {
                    marcoTimerCount := 1 ;When loop execute, set counter to 1
                    SetTimer, %selectSkillLabelR%, 1
                }
            }
        }
        if (bModeR = 12)    ;Right continuous click
        {
            GoSub StartPickUp
            SetTimer, MouseRButton, 15
        }
        if (bModeR = 13)    ;Middle button switch status
        {
            GoSub MbuttonChangeStatus
        }
        if (bModeR = 14)    ;Dodge
        {
            send {space}
        }
        if (bModeR = 15)   ;Skill 5
        {
            send {%BLMouseKey%}
        }
    }
}
Return
    

*RButton Up::  
{
    if (BEnableMouseGesture = 1)
    {
        settimer,gtrack,off           
        ;if (Instr(gtrack, "u") > 0 and Instr(gtrack, "d") <= 0)
        if (gtrack = "ur") ;Up then right first
        {
            gtrack=
            ;send {%BHorseKey%}
            return
        }     
        ;if (Instr(gtrack, "d") > 0 and Instr(gtrack, "u") <= 0)
        if (gtrack = "dr") ;Down then right first
        {
            gtrack=
            ;send {m}
            return
        }
        if (gtrack = "dru") ;Down then right then up
        {
            gtrack=
            send {m}
            return
        }
        gtrack=
    }

    If (boss_Enable=1)
    { 
        if (bModeR = 2)
        {
            send {%BMoveKey% up}
            Gosub EndForceMove
        }
        if ((bModeR >=3 and bModeR <=11) or bModeR = 15)
        {
            if (BStandR = 1 and bModeR >=3 and bModeR <=6)
                send {%BStandKey% up}
            if (BStandR = 1 and bModeR = 15)
                send {%BStandKey% up}
            if (BOnceR != 1)
            {
                selectSkillLabelR := GetModeSkillLabel(bModeR, 2)
                if (IsLabel(selectSkillLabelR))
                {
                    SetTimer, %selectSkillLabelR%, off
                    ResumeModeSkillLabel(selectSkillLabelR) ;Restore skill key status use right button release custom macro to control
                }
            }
            if (bModeR >=7 and bModeR <=11) ;When right button is run custom macro, release right button to cancel macro loop
            {
                marcoRMouseHold := 0
            }
            if (BModeReleaseR >=1 and BModeReleaseR <=5)   ;When left button release select custom macro always execute
            {
                selectSkillLabelReleaseR := GetModeSkillLabel(BModeReleaseR, 100)
                if (IsLabel(selectSkillLabelReleaseR))
                {
                    Gosub %selectSkillLabelReleaseR%
                }
            }
        } 
        if (bModeR = 12)   ;Continuous pickup
        {
            SetTimer, MouseRButton, off
            Gosub EndPickUp
        }
        if (bModeR = 13 and BMButtonRelease = 2)    ;Middle button switch status and restore on release
        {
            GoSub MbuttonChangeStatus
        }
        if (bModeR = 14)   ;Dodge
        {
            send {space}
        }
    }
}
Return
;;;;;;;;Right Button Press;;;;;;;;;;;;;;

;;;;;;;;Middle Button and Switch Status;;;;;;;;;;;;;;;;;;
;Switch Status:
MbuttonChangeStatus:
{
    if (boss_Enable=1)
    {
        cfg_str := "A|" . BMButton . "|"
        if(Instr(cfg_str, "|1|") > 0)
        {
            ;if (Bchannel = 1)
            ;{
                channel_Enable:=!channel_Enable
                real_key := ""
                if (BchannelKey = 1)
                    real_key := "RButton"
                if (BchannelKey = 2)
                    real_key := BSkillKey1
                if (BchannelKey = 3)
                    real_key := BSkillKey2
                if (BchannelKey = 4)
                    real_key := BSkillKey3
                if (BchannelKey = 5)
                    real_key := BSkillKey4
                if (BchannelKey = 6)
                    real_key := BMoveKey
                if (BchannelKey = 7)
                    real_key := BStandKey
                if (BchannelKey = 8)
                    real_key := BLMouseKey
                if (channel_Enable = 1)
                {
                    ;send {RButton down}
                    Send {%real_key% down}
                }
                else
                {
                    ;send {RButton up}
                    Send {%real_key% up}
                }
            ;}
            ;return
        }
        if(Instr(cfg_str, "|2|") > 0)
        {
            ;if (Bchannel2 = 1)
            ;{
                channel2_Enable:=!channel2_Enable
                real_key2 := ""
                if (BchannelKey2 = 1)
                    real_key2 := "RButton"
                if (BchannelKey2 = 2)
                    real_key2 := BSkillKey1
                if (BchannelKey2 = 3)
                    real_key2 := BSkillKey2
                if (BchannelKey2 = 4)
                    real_key2 := BSkillKey3
                if (BchannelKey2 = 5)
                    real_key2 := BSkillKey4
                if (BchannelKey2 = 6)
                    real_key2 := BMoveKey
                if (BchannelKey2 = 7)
                    real_key2 := BStandKey
                if (BchannelKey2 = 8)
                    real_key2 := BLMouseKey
                if (channel2_Enable = 1)
                {
                    ;send {RButton down}
                    Send {%real_key2% down}
                }
                else
                {
                    ;send {RButton up}
                    Send {%real_key2% up}
                }
            ;}
            ;return
        }
        if(Instr(cfg_str, "|3|") > 0)
        {
                BAutoL_Enable:=!BAutoL_Enable
                if (BAutoL_Enable = 1)
                {
                    SetTimer, MouseLButton, %BDelayL%
                }
                else
                {
                    if (BDelayL2 != 0)
                        SetTimer, MouseLButton, %BDelayL2%
                    else
                        SetTimer, MouseLButton, off
                }
        }
        if(Instr(cfg_str, "|4|") > 0)
        {
                BAutoR_Enable:=!BAutoR_Enable
                if (BAutoR_Enable = 1)
                {
                    SetTimer, MouseRButton, %BDelayR%
                }
                else
                {
                    if (BDelayR2 != 0)
                        SetTimer, MouseRButton, %BDelayR2%
                    else
                        SetTimer, MouseRButton, off
                    ;SetTimer, MouseRButton, off
                }
        }
        if(Instr(cfg_str, "|5|") > 0)
        {
                BAuto1_Enable:=!BAuto1_Enable
                if (BAuto1_Enable = 1)
                {
                    send {%BSkillKey1%} 
                    SetTimer, Label1, %BDelay1%
                }
                else
                {
                    if (BDelay12 != 0)
                        SetTimer, Label1, %BDelay12%
                    else
                        SetTimer, Label1, off
                    ;SetTimer, Label1, off
                }
        }
        if(Instr(cfg_str, "|6|") > 0)
        {
                BAuto2_Enable:=!BAuto2_Enable
                if (BAuto2_Enable = 1)
                {
                    send {%BSkillKey2%} 
                    SetTimer, Label2, %BDelay2%
                }
                else
                {
                    if (BDelay22 != 0)
                        SetTimer, Label2, %BDelay22%
                    else
                        SetTimer, Label2, off
                    ;SetTimer, Label2, off
                }
        }
        if(Instr(cfg_str, "|7|") > 0)
        {
                BAuto3_Enable:=!BAuto3_Enable
                if (BAuto3_Enable = 1)
                {
                    send {%BSkillKey3%} 
                    SetTimer, Label3, %BDelay3%
                }
                else
                {
                    if (BDelay32 != 0)
                        SetTimer, Label3, %BDelay32%
                    else
                        SetTimer, Label3, off
                    ;SetTimer, Label3, off
                }
        }
        if(Instr(cfg_str, "|8|") > 0)
        {
                BAuto4_Enable:=!BAuto4_Enable
                if (BAuto4_Enable = 1)
                {
                    send {%BSkillKey4%} 
                    SetTimer, Label4, %BDelay4%
                }
                else
                {
                    if (BDelay42 != 0)
                        SetTimer, Label4, %BDelay42%
                    else
                        SetTimer, Label4, off
                    ;SetTimer, Label4, off
                }
        }
        if(Instr(cfg_str, "|9|") > 0)
        {
                BMarco1_Enable:=!BMarco1_Enable
                if (BMarco1_Enable = 1)
                {
                    SetTimer, RunUserMarco1, 1
                }
                else
                {
                    SetTimer, RunUserMarco1, off
                }
        }
        if(Instr(cfg_str, "|10|") > 0)
        {
                BMarco2_Enable:=!BMarco2_Enable
                if (BMarco2_Enable = 1)
                {
                    SetTimer, RunUserMarco2, 1
                }
                else
                {
                    SetTimer, RunUserMarco2, off
                }
        }
        if(Instr(cfg_str, "|11|") > 0)
        {
                BMarco3_Enable:=!BMarco3_Enable
                if (BMarco3_Enable = 1)
                {
                    SetTimer, RunUserMarco3, 1
                }
                else
                {
                    SetTimer, RunUserMarco3, off
                }
        }
        if(Instr(cfg_str, "|12|") > 0)
        {
                BMarco4_Enable:=!BMarco4_Enable
                if (BMarco4_Enable = 1)
                {
                    SetTimer, RunUserMarco4, 1
                }
                else
                {
                    SetTimer, RunUserMarco4, off
                }
        }
        if(Instr(cfg_str, "|13|") > 0)
        {
                BMarco5_Enable:=!BMarco5_Enable
                if (BMarco5_Enable = 1)
                {
                    SetTimer, RunUserMarco5, 1
                }
                else
                {
                    SetTimer, RunUserMarco5, off
                }
        }
        if(Instr(cfg_str, "|14|") > 0)
        {
                BAutoMouseL_Enable:=!BAutoMouseL_Enable
                if (BAutoMouseL_Enable = 1)
                {
                    send {%BLMouseKey%} 
                    SetTimer, LabelMouseL, %BDelayMouseL%
                }
                else
                {
                    if (BDelayMouseL2 != 0)
                        SetTimer, LabelMouseL, %BDelayMouseL2%
                    else
                        SetTimer, LabelMouseL, off
                    ;SetTimer, Label4, off
                }
        }
    }
}
return 

~*MButton::
{ 
    temp_boss_enable := boss_enable
    intInterval := 300 ; If two clicks in this interval, consider double click.
    if (A_PriorKey = "MButton" and A_TimeSincePriorHotkey < intInterval) ; Must be direct middle button press, not triggered by other key.
    {
        if (BEnableGreatRift = 1 and boss_Enable=0) ;Here can change to other use (if enable rift, when macro not on double click for rift)
        {
            WinGetPos, X, Y, current_Width, current_Height, %BServer%
            sysget titlebar_height, 4, %BServer%
            if (BDispMode = 2)
            {
                titlebar_height := 0
            }
            
            ;Mouse reset to character center
            put_x := current_Width*1/2
            put_y := (current_Height - titlebar_height)*1/2+titlebar_height
            MouseMove, put_x, put_y, 0 ;
                
            return
        }
        
        /*
        if (BCancelDC != 1) ;If double click not as macro switch, exit
        {
            Gosub F2
            ;If from stop to start, and middle button is restore on release, will auto trigger release switch, then manual switch once to guarantee initial state
            if (temp_boss_enable = 0 and BMButtonRelease = 2) 
                Gosub MbuttonChangeStatus
            return
        }
        */
        if (BCancelDC = 1) ;Double click for mount
        {
            if (boss_Enable = 1)
            {
                EndFunc()
                boss_Enable=0
            }            
            Sleep 800
            send {X}
            Sleep 200
            ;send {%BMoveKey% down}
            Send {z down}
            setTimer, LabelMouseL, 200
            return
        }
    }

    Gosub MbuttonChangeStatus
}
return

*MButton Up::
If (boss_Enable=1)
{ 
    if (BMButtonRelease = 2)
    {  
        GoSub MbuttonChangeStatus
        return
    }
}
return
;;;;;;;;Middle Button;;;;;;;;;;;;;;;;;;

;;;;;;;;Wheel Up;;;;;;;;;;;;;;;;;;
~WheelUp::
{  
    intInterval := 150 ; If two clicks in this interval, consider double click.
    if (A_PriorKey = "WheelUp" and A_TimeSincePriorHotkey < intInterval) ; 
    {
        return
    }

    If ((boss_Enable=0 and (BEnableWU = 3 or BEnableWU = 4)) or (boss_Enable=1 and (BEnableWU = 2 or BEnableWU = 4)))
    {
        if (BWheelUp = 2)
        {
            send {%BSkillKey1%}
        }
        if (BWheelUp = 3)
        {
            send {%BSkillKey2%}
        }
        if (BWheelUp = 4)
        {
            send {%BSkillKey3%}
        }
        if (BWheelUp = 5)
        {
            send {%BSkillKey4%}
        }
        if (BWheelUp = 6)
        {
            send {%BAvoidKey%}
        }
        if (BWheelUp = 7)
        {
            send {%BLMouseKey%}
        }
        if (BWheelUp = 8) ;Custom macro1
        {
            marcoAccessKey := "wheelUp"
            Gosub RunUserMarco1
        }
        if (BWheelUp = 9)
        {
            marcoAccessKey := "wheelUp"
            Gosub RunUserMarco2
        }
        if (BWheelUp = 10)
        {
            marcoAccessKey := "wheelUp"
            Gosub RunUserMarco3
        }
        if (BWheelUp = 11)
        {
            marcoAccessKey := "wheelUp"
            Gosub RunUserMarco4
        }
        if (BWheelUp = 12)
        {
            marcoAccessKey := "wheelUp"
            Gosub RunUserMarco5
        }
        if (BWheelUp >= 13 and BWheelUp <= 17)
        {
            marcoAccessKey := "wheelUp"
            RunUserMarcoX(BWheelUp-7)
        }
    }
}
return
;;;;;;;;Wheel Up;;;;;;;;;;;;;;;;;;
;;;;;;;;Wheel Down;;;;;;;;;;;;;;;;;;
~WheelDown::
{
    If ((boss_Enable=0 and (BEnableWD = 3 or BEnableWD = 4)) or (boss_Enable=1 and (BEnableWD = 2 or BEnableWD = 4)))
    {
        if (BWheelDown = 2)
        {
            send {%BSkillKey1%}
        }
        if (BWheelDown = 3)
        {
            send {%BSkillKey2%}
        }
        if (BWheelDown = 4)
        {
            send {%BSkillKey3%}
        }
        if (BWheelDown = 5)
        {
            send {%BSkillKey4%}
        }
        if (BWheelDown = 6)
        {
            send {%BAvoidKey%}
        }
        if (BWheelDown = 7)
        {
            send {%BLMouseKey%}
        }
        if (BWheelDown = 8) ;Custom macro1
        {
            marcoAccessKey := "wheelDown"
            Gosub RunUserMarco1
        }
        if (BWheelDown = 9)
        {
            marcoAccessKey := "wheelDown"
            Gosub RunUserMarco2
        }
        if (BWheelDown = 10)
        {
            marcoAccessKey := "wheelDown"
            Gosub RunUserMarco3
        }
        if (BWheelDown = 11)
        {
            marcoAccessKey := "wheelDown"
            Gosub RunUserMarco4
        }
        if (BWheelDown = 12)
        {
            marcoAccessKey := "wheelDown"
            Gosub RunUserMarco5
        }
        if (BWheelDown >= 13 and BWheelDown <= 17)
        {
            marcoAccessKey := "wheelDown"
            RunUserMarcoX(BWheelDown-7)
        }
    }
}
return
;;;;;;;;Wheel Down;;;;;;;;;;;;;;;;;;

~Enter::  
~T::     
~S::      
~I::      
~M::      
~Down::    
{
    EndFunc()
    boss_Enable=0
}
Return

^!J::
{
    ; ==== Force high DPI awareness ====
    DllCall("SetThreadDpiAwarenessContext", "Ptr", -3)

    ; ==== Get active window handle ====
    WinGet, hWnd, ID, A

    ; ==== Get mouse screen coord (physical pixels) ====
    VarSetCapacity(POINT, 8)
    DllCall("GetCursorPos", "Ptr", &POINT)
    ScreenX := NumGet(POINT, 0, "Int")
    ScreenY := NumGet(POINT, 4, "Int")

    ; ==== Calculate window coord (including border) ====
    VarSetCapacity(RECT, 16)
    DllCall("GetWindowRect", "Ptr", hWnd, "Ptr", &RECT)
    WinLeft   := NumGet(RECT, 0, "Int")
    WinTop    := NumGet(RECT, 4, "Int")
    WindowX := ScreenX - WinLeft
    WindowY := ScreenY - WinTop

    ; ==== Calculate client coord ====
    DllCall("ScreenToClient", "Ptr", hWnd, "Ptr", &POINT)
    ClientX := NumGet(POINT, 0, "Int")
    ClientY := NumGet(POINT, 4, "Int")

    ; ==== Key fix: Get color correct way ====
    ; Method1: Use screen DC direct read color (bypass window permission issue)
    hDC := DllCall("GetDC", "Ptr", 0) ; Use screen device context
    ColorBGR := DllCall("GetPixel", "Ptr", hDC, "Int", ScreenX, "Int", ScreenY)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    
    ; Method2: If method1 fail, use bitmap capture (compatible complex window)
    if (ColorBGR = 0xFFFFFFFF || ColorBGR = -1) ; If GetPixel fail
    {
        ; Use bitmap way capture color
        hDC := DllCall("GetDC", "Ptr", 0)
        hMemDC := DllCall("CreateCompatibleDC", "Ptr", hDC)
        hBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", 1, "Int", 1)
        DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
        DllCall("BitBlt", "Ptr", hMemDC, "Int", 0, "Int", 0, "Int", 1, "Int", 1, "Ptr", hDC, "Int", ScreenX, "Int", ScreenY, "UInt", 0x40CC0020)
        ColorBGR := DllCall("GetPixel", "Ptr", hMemDC, "Int", 0, "Int", 0)
        DllCall("DeleteObject", "Ptr", hBitmap)
        DllCall("DeleteDC", "Ptr", hMemDC)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    }

    ; Convert BGR to RGB
    ColorRGB := Format("0x{:02X}{:02X}{:02X}", (ColorBGR & 0xFF), (ColorBGR >> 8 & 0xFF), (ColorBGR >> 16 & 0xFF))

    ; ==== Window info ====
    WinWidth  := NumGet(RECT, 8, "Int") - WinLeft
    WinHeight := NumGet(RECT, 12, "Int") - WinTop
    VarSetCapacity(ClientRect, 16)
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &ClientRect)
    ClientW := NumGet(ClientRect, 8, "Int")
    ClientH := NumGet(ClientRect, 12, "Int")
    WinGetTitle, Title, ahk_id %hWnd%
    WinGetClass, Class, ahk_id %hWnd%
    WinGet, PID, PID, ahk_id %hWnd%

    ; Execute division and keep 4 decimal places
    resultx := ClientX / ClientW
    formattedResultx := Format("{1:.4f}", resultx) ; Format to 4 decimal places
    resulty := ClientY / ClientH
    formattedResulty := Format("{1:.4f}", resulty) ; Format to 4 decimal places

    result := formattedResultx " " formattedResulty " 0x" ColorRGB

    ; Copy result to clipboard
    Clipboard := result
    ClipWait, 1 ; Wait clipboard update (max 1 second)

    ; ==== Output ====
    /*
    ToolTip,
    (
    === Mouse Position ===
    Screen:`t%ScreenX%, %ScreenY%
    Window:`t%WindowX%, %WindowY%
    Client:`t%ClientX%, %ClientY%
    Color:`t%ColorRGB%

    === Active Window Position ===
    Position:`t%WinLeft%, %WinTop%
    Size:`t%WinWidth% x %WinHeight%
    Client Size:`t%ClientW% x %ClientH%
    Title:`t%Title%
    Class:`t%Class%
    PID:`t%PID%
    )
*/
    return
}

^1::
{
	GuiControlGet, ConfigPath
    SelectedFile := ConfigPath
    Gosub, GetConfigSetting
    Return
}
^2::
{
	GuiControlGet, ConfigPath2
    SelectedFile := ConfigPath2
    Gosub, GetConfigSetting
	GuiControlGet, ConfigPath
    SelectedFile := ConfigPath
    Return
}
^3::
{
	GuiControlGet, ConfigPath3
    SelectedFile := ConfigPath3
    Gosub, GetConfigSetting
	GuiControlGet, ConfigPath
    SelectedFile := ConfigPath
    Return
}
^4::
{
	GuiControlGet, ConfigPath4
    SelectedFile := ConfigPath4
    Gosub, GetConfigSetting
	GuiControlGet, ConfigPath
    SelectedFile := ConfigPath
    Return
}
^5::
{
	GuiControlGet, ConfigPath5
    SelectedFile := ConfigPath5
    Gosub, GetConfigSetting
	GuiControlGet, ConfigPath
    SelectedFile := ConfigPath
    Return
}
^6::
{
	GuiControlGet, ConfigPath6
    SelectedFile := ConfigPath6
    Gosub, GetConfigSetting
	GuiControlGet, ConfigPath
    SelectedFile := ConfigPath
    Return
}
^7::
{
	GuiControlGet, ConfigPath7
    SelectedFile := ConfigPath7
    Gosub, GetConfigSetting
	GuiControlGet, ConfigPath
    SelectedFile := ConfigPath
    Return
}
^8::
{
	GuiControlGet, ConfigPath8
    SelectedFile := ConfigPath8
    Gosub, GetConfigSetting
	GuiControlGet, ConfigPath
    SelectedFile := ConfigPath
    Return
}

GetConfigSetting:
{
    Gosub, ReadFile
    Gosub, GetUserMarco
    DisplayInfo("Config switched to: " . SelectedFile)
    Sleep (1000)
    DisplayInfoClose()
    Return
}

#IfWinActive
;---------------End Window Hotkeys-----------------------------------------------------


;---------------Global Hotkeys-----------------------------------------------------

!1:: ; ! means alt key
{
	GuiControlGet, BD2RWIN1
    hwnd_t := BD2RWIN1
    ; Use ahk_id to specify window and activate it
    WinActivate, ahk_id %hwnd_t%
    Sleep, 100 ; Wait a bit to ensure window on top
    Return
}

!2:: ; 
{
	GuiControlGet, BD2RWIN2
    hwnd_t := BD2RWIN2
    ; Use ahk_id to specify window and activate it
    WinActivate, ahk_id %hwnd_t%
    Sleep, 100 ; Wait a bit to ensure window on top
    Return
}

!3:: ; 
{
	GuiControlGet, BD2RWIN3
    hwnd_t := BD2RWIN3
    ; Use ahk_id to specify window and activate it
    WinActivate, ahk_id %hwnd_t%
    Sleep, 100 ; Wait a bit to ensure window on top
    Return
}

!4:: ; 
{
	GuiControlGet, BD2RWIN4
    hwnd_t := BD2RWIN4
    ; Use ahk_id to specify window and activate it
    WinActivate, ahk_id %hwnd_t%
    Sleep, 100 ; Wait a bit to ensure window on top
    Return
}

!5:: ; 
{
	GuiControlGet, BD2RWIN5
    hwnd_t := BD2RWIN5
    ; Use ahk_id to specify window and activate it
    WinActivate, ahk_id %hwnd_t%
    Sleep, 100 ; Wait a bit to ensure window on top
    Return
}

!6:: ; 
{
	GuiControlGet, BD2RWIN6
    hwnd_t := BD2RWIN6
    ; Use ahk_id to specify window and activate it
    WinActivate, ahk_id %hwnd_t%
    Sleep, 100 ; Wait a bit to ensure window on top
    Return
}

!7:: ; 
{
	GuiControlGet, BD2RWIN7
    hwnd_t := BD2RWIN7
    ; Use ahk_id to specify window and activate it
    WinActivate, ahk_id %hwnd_t%
    Sleep, 100 ; Wait a bit to ensure window on top
    Return
}

!8:: ; 
{
	GuiControlGet, BD2RWIN8
    hwnd_t := BD2RWIN8
    ; Use ahk_id to specify window and activate it
    WinActivate, ahk_id %hwnd_t%
    Sleep, 100 ; Wait a bit to ensure window on top
    Return
}

^b::  ; Ctrl+B hotkey
{
    WinActivate, ahk_exe D4Auto.exe  ; Activate process named D4Auto.exe window
    WinActivate, ahk_exe D2GO.exe  ; Activate process named D4Auto.exe window
}
return

^!l::
{
    ; ==== Force high DPI awareness ====
    DllCall("SetThreadDpiAwarenessContext", "Ptr", -3)

    ; ==== Get active window handle ====
    WinGet, hWnd, ID, A

    ; ==== Get mouse screen coord (physical pixels) ====
    VarSetCapacity(POINT, 8)
    DllCall("GetCursorPos", "Ptr", &POINT)
    ScreenX := NumGet(POINT, 0, "Int")
    ScreenY := NumGet(POINT, 4, "Int")

    ; ==== Calculate window coord (including border) ====
    VarSetCapacity(RECT, 16)
    DllCall("GetWindowRect", "Ptr", hWnd, "Ptr", &RECT)
    WinLeft   := NumGet(RECT, 0, "Int")
    WinTop    := NumGet(RECT, 4, "Int")
    WindowX := ScreenX - WinLeft
    WindowY := ScreenY - WinTop

    ; ==== Calculate client coord ====
    DllCall("ScreenToClient", "Ptr", hWnd, "Ptr", &POINT)
    ClientX := NumGet(POINT, 0, "Int")
    ClientY := NumGet(POINT, 4, "Int")

    ; ==== Key fix: Get color correct way ====
    ; Method1: Use screen DC direct read color (bypass window permission issue)
    hDC := DllCall("GetDC", "Ptr", 0) ; Use screen device context
    ColorBGR := DllCall("GetPixel", "Ptr", hDC, "Int", ScreenX, "Int", ScreenY)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    
    ; Method2: If method1 fail, use bitmap capture (compatible complex window)
    if (ColorBGR = 0xFFFFFFFF || ColorBGR = -1) ; If GetPixel fail
    {
        ; Use bitmap way capture color
        hDC := DllCall("GetDC", "Ptr", 0)
        hMemDC := DllCall("CreateCompatibleDC", "Ptr", hDC)
        hBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", 1, "Int", 1)
        DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
        DllCall("BitBlt", "Ptr", hMemDC, "Int", 0, "Int", 0, "Int", 1, "Int", 1, "Ptr", hDC, "Int", ScreenX, "Int", ScreenY, "UInt", 0x40CC0020)
        ColorBGR := DllCall("GetPixel", "Ptr", hMemDC, "Int", 0, "Int", 0)
        DllCall("DeleteObject", "Ptr", hBitmap)
        DllCall("DeleteDC", "Ptr", hMemDC)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    }

    ; Convert BGR to RGB
    ColorRGB := Format("0x{:02X}{:02X}{:02X}", (ColorBGR & 0xFF), (ColorBGR >> 8 & 0xFF), (ColorBGR >> 16 & 0xFF))

    ; ==== Window info ====
    WinWidth  := NumGet(RECT, 8, "Int") - WinLeft
    WinHeight := NumGet(RECT, 12, "Int") - WinTop
    VarSetCapacity(ClientRect, 16)
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &ClientRect)
    ClientW := NumGet(ClientRect, 8, "Int")
    ClientH := NumGet(ClientRect, 12, "Int")
    WinGetTitle, Title, ahk_id %hWnd%
    WinGetClass, Class, ahk_id %hWnd%
    WinGet, PID, PID, ahk_id %hWnd%

    ; Execute division and keep 4 decimal places
    resultx := ClientX / ClientW
    formattedResultx := Format("{1:.4f}", resultx) ; Format to 4 decimal places
    resulty := ClientY / ClientH
    formattedResulty := Format("{1:.4f}", resulty) ; Format to 4 decimal places

    result := formattedResultx ", " formattedResulty " " ColorRGB

    ; Copy result to clipboard
    Clipboard := result
    ClipWait, 1 ; Wait clipboard update (max 1 second)

    ; ==== Output ====
    /*
    ToolTip,
    (
    === Mouse Position ===
    Screen:`t%ScreenX%, %ScreenY%
    Window:`t%WindowX%, %WindowY%
    Client:`t%ClientX%, %ClientY%
    Color:`t%ColorRGB%

    === Active Window Position ===
    Position:`t%WinLeft%, %WinTop%
    Size:`t%WinWidth% x %WinHeight%
    Client Size:`t%ClientW% x %ClientH%
    Title:`t%Title%
    Class:`t%Class%
    PID:`t%PID%
    )
*/
    return
}
;---------------End Global Hotkeys-------------------------------------------------

gtrack:
{
    mousegetpos xpos2,ypos2
    track:=(abs(ypos1-ypos2)>=abs(xpos1-xpos2)) ? (ypos1>ypos2 ? "u" : "d") : (xpos1>xpos2 ? "l" : "r") 
    if (track<>SubStr(gtrack, 0, 1)) and (abs(ypos1-ypos2)>4 or abs(xpos1-xpos2)>4)
        gtrack.=track 
    xpos1:=xpos2,ypos1:=ypos2
}
return

RunHotkey3:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        return
    }
            
    if (BOnce3 = 1)
    {
        if (bMode3 = 1)
            Gosub RunUserMarco1
        if (bMode3 = 2)
            Gosub RunUserMarco2
        if (bMode3 = 3)
            Gosub RunUserMarco3
        if (bMode3 = 4)
            Gosub RunUserMarco4
        if (bMode3 = 5)
            Gosub RunUserMarco5
    }
    else
    {
        selectSkillLabel := GetModeSkillLabel(bMode3, 3)
        if (IsLabel(selectSkillLabel))
        {
            Hotkey3_enable := !Hotkey3_enable
            if (Hotkey3_enable)
            {
                SetTimer, %selectSkillLabel%, 1
                ;DisplayOPInfo("Custom macro started loop")
                ;Sleep 1000
                ;DisplayOPInfoClose()
            }
            else
            {
                SetTimer, %selectSkillLabel%, off
                ;DisplayOPInfo("Custom macro closed loop")
                ;Sleep 1000
                ;DisplayOPInfoClose()
            }
        }
    }
    t_hk3_toggle := 0
    Loop, Parse, HotKeyList, |
    {
        If (A_Loopfield = BHotkey3)
        {
            t_hk3_toggle := 1
            break
        }
    }
    if (t_hk3_toggle = 1)
    {
        KeyWait %BHotkey3%
    }
        
    ;if (GetKeyState(space,P))
        ;KeyWait space
    ;if (GetKeyState(%BHotkey3%,P))
        ;KeyWait %BHotkey3%
    ;Hotkey, %BHotkey3%, RunHotkey3, off
    return
}

RunHotkey4:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        return
    }
            
    if (BOnce4 = 1)
    {
        if (bMode4 = 1)
            Gosub RunUserMarco1
        if (bMode4 = 2)
            Gosub RunUserMarco2
        if (bMode4 = 3)
            Gosub RunUserMarco3
        if (bMode4 = 4)
            Gosub RunUserMarco4
        if (bMode4 = 5)
            Gosub RunUserMarco5
    }
    else
    {
        selectSkillLabel := GetModeSkillLabel(bMode4, 4)
        if (IsLabel(selectSkillLabel))
        {
            Hotkey4_enable := !Hotkey4_enable
            if (Hotkey4_enable)
            {
                SetTimer, %selectSkillLabel%, 1
                ;DisplayOPInfo("Custom macro started loop")
                ;Sleep 1000
                ;DisplayOPInfoClose()
            }
            else
            {
                SetTimer, %selectSkillLabel%, off
                ;DisplayOPInfo("Custom macro closed loop")
                ;Sleep 1000
                ;DisplayOPInfoClose()
            }
        }
    }
    t_hk4_toggle := 0
    Loop, Parse, HotKeyList, |
    {
        If (A_Loopfield = BHotkey4)
        {
            t_hk4_toggle := 1
            break
        }
    }
    if (t_hk4_toggle = 1)
    {
        KeyWait %BHotkey4%
    }
    return
}

RunHotkey5:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        return
    }
            
    if (BOnce5 = 1)
    {
        if (bMode5 = 1)
            Gosub RunUserMarco1
        if (bMode5 = 2)
            Gosub RunUserMarco2
        if (bMode5 = 3)
            Gosub RunUserMarco3
        if (bMode5 = 4)
            Gosub RunUserMarco4
        if (bMode5 = 5)
            Gosub RunUserMarco5
    }
    else
    {
        selectSkillLabel := GetModeSkillLabel(bMode5, 5)
        if (IsLabel(selectSkillLabel))
        {
            Hotkey5_enable := !Hotkey5_enable
            if (Hotkey5_enable)
            {
                SetTimer, %selectSkillLabel%, 1
                ;DisplayOPInfo("Custom macro started loop")
                ;Sleep 1000
                ;DisplayOPInfoClose()
            }
            else
            {
                SetTimer, %selectSkillLabel%, off
                ;DisplayOPInfo("Custom macro closed loop")
                ;Sleep 1000
                ;DisplayOPInfoClose()
            }
        }
    }
    t_hk5_toggle := 0
    Loop, Parse, HotKeyList, |
    {
        If (A_Loopfield = BHotkey5)
        {
            t_hk5_toggle := 1
            break
        }
    }
    if (t_hk5_toggle = 1)
    {
        KeyWait %BHotkey5%
    }
    return
}




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LabelX:                                                  
{
    send {%BSkillKey4%}

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

;Old mechanism labels
/*
Label1:                                                  
{
    send {%BSkillKey1%}  
    ;send {%BSkillKey1%}

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

Label2:                                                  
{
    send {%BSkillKey2%}    

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

Label3:                                                  
{
    send {%BSkillKey3%} 

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

Label4:                                                  
{
    send {%BSkillKey4%}

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

LabelMouseL:                                                  
{
    send {%BLMouseKey%}

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}
  

MouseLButton:
{
    Click
    IfWinNotActive,%BServer%
    {
    EndFunc()
    boss_Enable=0
    }
    return
}
*/

Label1:                                                  
{
    Skill1Pending := true

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

Label2:                                                  
{
    Skill2Pending := true   

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

Label3:                                                  
{
    Skill3Pending := true
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

Label4:                                                  
{
    Skill4Pending := true

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

LabelMouseL:                                                  
{
    Skill5Pending := true

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}
  

MouseLButton:
{
    MouseLPending := true
    IfWinNotActive,%BServer%
    {
    EndFunc()
    boss_Enable=0
    }
    return
}

MouseRButton:
{
    MouseRPending := true
    IfWinNotActive,%BServer%
    {
    EndFunc()
    boss_Enable=0
    }
    return
}

LabelPotion:                                                  
{
    send {q}  
    ;send {%BSkillKey1%}

    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }
    Return
}

SendSkill(key)
{
    SendInput {%key%}
}

Dispatcher:
{
    global

    Loop 7
    {
        idx := DispatchIndex

        ; Skill1

        if (idx = 1)
        {
            if (Skill1Pending)
            {
                Skill1Pending := false
                SendSkill(BSkillKey1)

                DispatchIndex := 2
                return
            }
        }

        ; Skill2

        else if (idx = 2)
        {
            if (Skill2Pending)
            {
                Skill2Pending := false
                SendSkill(BSkillKey2)

                DispatchIndex := 3
                return
            }
        }

        ; Skill3

        else if (idx = 3)
        {
            if (Skill3Pending)
            {
                Skill3Pending := false
                SendSkill(BSkillKey3)

                DispatchIndex := 4
                return
            }
        }

        ; Skill4

        else if (idx = 4)
        {
            if (Skill4Pending)
            {
                Skill4Pending := false
                SendSkill(BSkillKey4)

                DispatchIndex := 5
                return
            }
        }

        ; Mouse Left

        else if (idx = 5)
        {
            if (MouseLPending)
            {
                MouseLPending := false

                Click

                DispatchIndex := 6
                return
            }
        }

        ; Mouse Right

        else if (idx = 6)
        {
            if (MouseRPending)
            {
                MouseRPending := false

                Click Right

                DispatchIndex := 7
                return
            }
        }

        ; Skill5

        else if (idx = 7)
        {
            if (Skill5Pending)
            {
                Skill5Pending := false

                SendSkill(BLMouseKey)

                DispatchIndex := 1
                return
            }
        }

        DispatchIndex++

        if (DispatchIndex > 7)
            DispatchIndex := 1
    }

    return
}

KeepSkillBuff:
{
    if (BKeep1 = 1)
    {
        buffColor := GetSkillBuffStatus(1)
        if (buffColor[2] < 95)
            send {%BSkillKey1%}
    }
    if (BKeep2 = 1)
    {
        buffColor := GetSkillBuffStatus(2)
        if (buffColor[2] < 95)
            send {%BSkillKey2%}
    }
    if (BKeep3 = 1)
    {
        buffColor := GetSkillBuffStatus(3)
        if (buffColor[2] < 95)
            send {%BSkillKey3%}
    }
    if (BKeep4 = 1)
    {
        buffColor := GetSkillBuffStatus(4)
        if (buffColor[2] < 95)
            send {%BSkillKey4%}
    }
    if (BKeepL = 1) ;Left button
    {
        buffColor := GetSkillBuffStatus(5)
        if (buffColor[2] < 95)
        {
            if (GetKeyState("shift",P) or GetKeyState(%BStandKey%,P))
                send {LButton}
            else
            {
                send {%BStandKey% down}
                Sleep 50
                send {RButton}
                Sleep 50
                send {%BStandKey% up}
            }
        }
    }
    if (BKeepR = 1)
    {
        buffColor := GetSkillBuffStatus(6)
        if (buffColor[2] < 95)
            send {RButton}
    }
}
return

LabelCheckInPeace:
{
    IfWinNotActive,%BServer%
    {
        other_enable := 0
        
        ;;;;;;;;;;;;;;;;;;;;;Auto close reward window;;;;;;;;;;;;;;;;;;;;
        SetTimer, LabelAutoCloseWin, off
        LabelAutoCloseWin_status := 0
        ;;;;;;;;;;;;;;;;;;;;;Auto close reward window End;;;;;;;;;;;;;;;;
    }
    else
    {
        other_enable := 1
        
        ;;;;;;;;;;;;;;;;;;;;;Auto close reward window;;;;;;;;;;;;;;;;;;;;
        if (BAutoCloseWin = 1 and LabelAutoCloseWin_status = 0)
        {
            SetTimer, LabelAutoCloseWin, 800 
            LabelAutoCloseWin_status := 1
        }
        if(BAutoCloseWin = 0)
        {
            SetTimer, LabelAutoCloseWin, off 
            LabelAutoCloseWin_status := 0
        }
        ;;;;;;;;;;;;;;;;;;;;;Auto close reward window End;;;;;;;;;;;;;;;;
    }
    ;msgbox, %other_enable% %BAutoCloseWin% %LabelAutoCloseWin_status%
}
return

LabelAutoCloseWin:
{
    IfWinNotActive,%BServer%
    {
        other_enable := 0
        return
    }
    
    if(BAutoCloseWin = 0)
        return
        
    WinGetPos, X, Y, current_Width, current_Height, %BServer%
    sysget titlebar_height, 4, %BServer%
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }
    
    ;Detect if reward window
    s_x := current_Width*1207/2560
    s_y := (current_Height - titlebar_height)*1194/1440+titlebar_height
    e_x := current_Width*1344/2560
    e_y := (current_Height - titlebar_height)*1243/1440+titlebar_height
    PixelSearch, Px, Py, s_x, s_y, e_x, e_y, 0xDE974B, 3, Fast RGB ;
    if (ErrorLevel = 0)
    {        
        ;Detect if map window
        s_x := current_Width*1227/2560
        s_y := (current_Height - titlebar_height)*131/1440+titlebar_height
        e_x := current_Width*1343/2560
        e_y := (current_Height - titlebar_height)*164/1440+titlebar_height
        PixelSearch, Px, Py, s_x, s_y, e_x, e_y, 0xFDFDFD, 3, Fast RGB ;
        if ErrorLevel
        {
            send {F10}
        }
    }

    ;Detect if dialog window
    s_x := current_Width*1665/2560
    s_y := (current_Height - titlebar_height)*1032/1440+titlebar_height
    e_x := current_Width*1727/2560
    e_y := (current_Height - titlebar_height)*1094/1440+titlebar_height
    PixelSearch, Px, Py, s_x, s_y, e_x, e_y, 0x4D1400, 3, Fast RGB ;
    if (ErrorLevel = 0)
    {
        send {F10}
    }

    return
}

; ==============================================
; Button click: Register hotkey
; ==============================================
HotKeyRegister:
    ;Return
    Gui Submit, NoHide  ; Get interface input content

    if (Hotkey = "") {
        MsgBox, Hotkey cannot be empty！
        return
    }

    ; Close last hotkey
    if (LastHotkey != "")
        Hotkey, %LastHotkey%, Off

    ; Bind new hotkey (error proof)
    Try {
        Hotkey, %Hotkey%, RunSelectedFunc
    } Catch {
        MsgBox, Hotkey format error！`nExample：F1、^s、!a、+d
        return
    }
    LastHotkey := Hotkey  ; Save last bound hotkey

    MsgBox, Bound：%Hotkey% → %FuncName%
return

; ==============================================
; Hotkey trigger: Auto run selected function
; ==============================================
RunSelectedFunc:
    Gui Submit, NoHide
    Gosub %FuncName%  ; Execute dropdown selected function
return

RunUserMarco1:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        marcoAccessKey := ""
        return
    }
    i := 0
    loop
    {
        i := i+1
        if (i > actionArrayIndex1)
            break
        If (boss_Enable = 0)
        {
            if (marcoAccessKey = "")
                break
            ;1-Disable|2-When running|3-When not running|4-Any time
            if (marcoAccessKey = "dClickL" and (BEnableDCL = 1 or BEnableDCL =2))
                Break
            if (marcoAccessKey = "dClickR" and (BEnableDCR = 1 or BEnableDCR =2))
                Break
            if (marcoAccessKey = "wheelUp" and (BEnableWU = 1 or BEnableWU =2))
                Break
            if (marcoAccessKey = "wheelDown" and (BEnableWD = 1 or BEnableWD =2))
                Break
        }
        If (boss_Enable = 1) 
        {
            ;Left button hold set to macro1, and left button already released | Right button hold set to macro1, and right button already released
            if (bModeL = 7 and marcoLMouseHold = 0)
                Break
            if (bModeR = 7 and marcoRMouseHold = 0)
                Break
        }
  
        IfWinNotActive,%BServer%
            break
        action := actionArray1[i][1]
        content := actionArray1[i][2]
        if (action = 1)                           ;Key
            ;send {%content%}  
            Send {%content%}
        if (action = 2)                           ;Hold  
        {
            ;send {%content% down}
            Send {%content% down}
        }
        if (action = 3)                           ;Release
        {
            ;send {%content% up}
            Send {%content% up}
        }
        if (action = 4)                           ;Wait max not exceed 20 seconds Split wait time >1 second to 0.1 second units, to avoid background wait too long
        {
            Sleep %content% 
            /*
            t_sleep_time1 := content + 0
            if (t_sleep_time1 > 1000)
            {
                t_i1 := 0
                loop
                {
                    t_i1 := t_i1 + 100
                    if (t_i1 > t_sleep_time1 or t_i1 > 20000)
                        break
                    Sleep 100
                }
            }
            else
                Sleep %content% 
                */
        }
        if (action = 5)                           ;Send text
        {
            ;send {Text} %content% 
            sendinput, %content% 
        }
        if (action = 6)                           ;Custom statement
        {
            ahkExec(content)
        }
        if (action = 7)                           ;Pause macro
        {
            EndFunc()
        }
        if (action = 8)                           ;Close macro
        {
            boss_Enable=0
        }
        if (action = 9)                           ;Screen show info
        {
            DisplayInfo(content)
        }
        if (action = 10)                          ;Close screen show info
        {
            DisplayInfoClose()
        }
        if (action = 11)                          ;Placeholder
        {
        }
        if (action = 12)                          ;Change skill
        {
            ChangeSkill(content)
        }
        if (action = 13)                          ;Only first run statement, custom macro loop execute no longer execute
        {
            if (marcoTimerCount = 1) 
                ahkExec(content)
        }
        if (action = 14)                          ;Continuous skill
        {
            switch content
            {
                case "1":
                    setTimer, Label1, %BDelay1% 
                case "2":
                    setTimer, Label2, %BDelay2% 
                case "3":
                    setTimer, Label3, %BDelay3% 
                case "4":
                    setTimer, Label4, %BDelay4% 
                case "l", "L":
                    setTimer, MouseLButton, %BDelayL% 
                case "r", "R":
                    setTimer, MouseRButton, %BDelayR% 
                case "5":
                    setTimer, LabelMouseL, %BDelayMouseL% 
                ;Default:
                    ;LoopAnyKey(p_key, p_time, 1) ;Parameter1-Key, Parameter2-Interval, Parameter3- 1Start,2Stop
            }
        }
        if (action = 15)                          ;Stop continuous skill
        {
            switch content
            {
                case "1":
                    setTimer, Label1, off
                case "2":
                    setTimer, Label2, off
                case "3":
                    setTimer, Label3, off
                case "4":
                    setTimer, Label4, off
                case "l", "L":
                    setTimer, MouseLButton, off
                case "r", "R":
                    setTimer, MouseRButton, off
                case "5":
                    setTimer, LabelMouseL, off
                ;Default:
                    ;LoopAnyKey(p_key, p_time, 2) ;Parameter1-Key, Parameter2-Interval, Parameter3- 1Start,2Stop
            }
        }
        if (action = 16)                          ;Send multiple keys
        {
            keyArray := StrSplit(content, ",", ,3)
            v1 := keyArray[1]
            v2 := keyArray[2]
            v3 := keyArray[3]
            SendMultiKey(v1, v2, v3)
        }
        if (action = 17)                          ;Mouse circle, parameter1-Angle, parameter2-Ratio, parameter3-Time interval, parameter4-Key to send
        {
            directionArray := StrSplit(content, ",", ,5)
            d1 := directionArray[1]
            d2 := directionArray[2]
            d3 := directionArray[3]
            d4 := directionArray[4]
            d5 := directionArray[5]
            CircleMouse(d1, d2, d3, d4, d5)
        }
        if (action = 18)                          ;Mouse move, parameter1-X axis ratio, parameter2-Y axis ratio, parameter3- 1Ratio value;2Pixel value
        {
            pointArray := StrSplit(content, ",", ,2)
            d1 := pointArray[1]
            d2 := pointArray[2]
            MoveYourMouse(d1, d2, 1)
        }
        if (action = 19)                          ;Random key
        {
            randamKeyArray := StrSplit(content, ",")  
            arrayLength := randamKeyArray.MaxIndex()
            Random, randomNumber, 1, %arrayLength%
            keyFinal := randamKeyArray[randomNumber]
            Send {%keyFinal%}
        }
        if (action = 20)                          ;Save mouse position
        {
            MouseGetPos, savedMousePosionX, savedMousePosionY
        }
        if (action = 21)                          ;Restore mouse position
        {
            MouseMove, %savedMousePosionX%, %savedMousePosionY%
        }
        if (action = 22)                          ;Loop backpack
        {
            bagArray := StrSplit(content, ",", ,8)
            d1 := bagArray[1]
            d2 := bagArray[2]
            d3 := bagArray[3]
            d4 := bagArray[4]
            d5 := bagArray[5]
            d6 := bagArray[6]
            d7 := bagArray[7]
            d8 := bagArray[8]
            LoopBagAction(d1, d2, d3, d4, d5, d6, d7, d8)
        }
    }
    ;Only effective when loop execute macro, single run macro will not run, when left/right button hold, this counter will be set to 1
    marcoTimerCount := marcoTimerCount + 1
    marcoAccessKey := ""
    return
}

RunUserMarco2:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        marcoAccessKey := ""
        return
    }
    i := 0
    loop
    {
        i := i+1
        if (i > actionArrayIndex2)
            break
        If (boss_Enable = 0)
        {
            if (marcoAccessKey = "")
                break
            if (marcoAccessKey = "dClickL" and (BEnableDCL = 1 or BEnableDCL =2))
                Break
            if (marcoAccessKey = "dClickR" and (BEnableDCR = 1 or BEnableDCR =2))
                Break
            if (marcoAccessKey = "wheelUp" and (BEnableWU = 1 or BEnableWU =2))
                Break
            if (marcoAccessKey = "wheelDown" and (BEnableWD = 1 or BEnableWD =2))
                Break
        }
        If (boss_Enable = 1)
        {
            if (bModeL = 8 and marcoLMouseHold = 0)
                Break
            if (bModeR = 8 and marcoRMouseHold = 0)
                Break
        }
        IfWinNotActive,%BServer%
            break
        action := actionArray2[i][1]
        content := actionArray2[i][2]
        if (action = 1)                           ;Key
            ;send {%content%}  
            Send {%content%}
        if (action = 2)                           ;Hold  
        {
            ;send {%content% down}
            Send {%content% down}
        }
        if (action = 3)                           ;Release
        {
            ;send {%content% up}
            Send {%content% up}
        }
        if (action = 4)                           ;Wait max not exceed 20 seconds Split wait time >1 second to 0.1 second units, to avoid background wait too long
        {
            Sleep %content% 
            /*
            t_sleep_time2 := content + 0
            if (t_sleep_time2 > 1000)
            {
                t_i2 := 0
                loop
                {
                    t_i2 := t_i2 + 100
                    if (t_i2 > t_sleep_time2 or t_i2 > 20000)
                        break
                    Sleep 100
                }
            }
            else
                Sleep %content% 
                */
        }
        if (action = 5)                           ;Send text
        {
            ;send {Text} %content% 
            sendinput, %content% 
        }
        if (action = 6)                           ;Custom statement
        {
            ahkExec(content)
        }
        if (action = 7)                           ;Pause macro
        {
            EndFunc()
        }
        if (action = 8)                           ;Close macro
        {
            boss_Enable=0
        }
        if (action = 9)                           ;Screen show info
        {
            DisplayInfo(content)
        }
        if (action = 10)                          ;Close screen show info
        {
            DisplayInfoClose()
        }
        if (action = 11)                          ;Placeholder
        {
        }
        if (action = 12)                          ;Change skill
        {
            ChangeSkill(content)
        }
        if (action = 13)                          ;Only first run statement, loop execute no longer execute
        {
            if (marcoTimerCount = 1)
                ahkExec(content)
        }
        if (action = 14)                          ;Continuous skill
        {
            ;if (content = "1")
            switch content
            {
                case "1":
                    setTimer, Label1, %BDelay1% 
                case "2":
                    setTimer, Label2, %BDelay2% 
                case "3":
                    setTimer, Label3, %BDelay3% 
                case "4":
                    setTimer, Label4, %BDelay4% 
                case "l", "L":
                    setTimer, MouseLButton, %BDelayL% 
                case "r", "R":
                    setTimer, MouseRButton, %BDelayR% 
                case "5":
                    setTimer, LabelMouseL, %BDelayMouseL% 
            }
        }
        if (action = 15)                          ;Stop continuous skill
        {
            switch content
            {
                case "1":
                    setTimer, Label1, off
                case "2":
                    setTimer, Label2, off
                case "3":
                    setTimer, Label3, off
                case "4":
                    setTimer, Label4, off
                case "l", "L":
                    setTimer, MouseLButton, off
                case "r", "R":
                    setTimer, MouseRButton, off
                case "5":
                    setTimer, LabelMouseL, off
            }
        }
        if (action = 16)                          ;Send multiple keys
        {
            keyArray := StrSplit(content, ",", ,3)
            v1 := keyArray[1]
            v2 := keyArray[2]
            v3 := keyArray[3]
            SendMultiKey(v1, v2, v3)
        }
        if (action = 17)                          ;Mouse circle, parameter1-Angle, parameter2-Ratio, parameter3-Time interval, parameter4-Key to send
        {
            directionArray := StrSplit(content, ",", ,5)
            d1 := directionArray[1]
            d2 := directionArray[2]
            d3 := directionArray[3]
            d4 := directionArray[4]
            d5 := directionArray[5]
            CircleMouse(d1, d2, d3, d4, d5)
        }
        if (action = 18)                          ;Mouse move, parameter1-X axis ratio, parameter2-Y axis ratio, parameter3- 1Ratio value;2Pixel value
        {
            pointArray := StrSplit(content, ",", ,2)
            d1 := pointArray[1]
            d2 := pointArray[2]
            MoveYourMouse(d1, d2, 1)
        }
        if (action = 19)                          ;Random key
        {
            randamKeyArray := StrSplit(content, ",")  
            arrayLength := randamKeyArray.MaxIndex()
            Random, randomNumber, 1, %arrayLength%
            keyFinal := randamKeyArray[randomNumber]
            Send {%keyFinal%}
        }
        if (action = 20)                          ;Save mouse position
        {
            MouseGetPos, savedMousePosionX, savedMousePosionY
        }
        if (action = 21)                          ;Restore mouse position
        {
            MouseMove, %savedMousePosionX%, %savedMousePosionY%
        }
        if (action = 22)                          ;Loop backpack
        {
            bagArray := StrSplit(content, ",", ,8)
            d1 := bagArray[1]
            d2 := bagArray[2]
            d3 := bagArray[3]
            d4 := bagArray[4]
            d5 := bagArray[5]
            d6 := bagArray[6]
            d7 := bagArray[7]
            d8 := bagArray[8]
            LoopBagAction(d1, d2, d3, d4, d5, d6, d7, d8)
        }
    }
    ;Only effective when loop execute macro, single run macro will not run, when left/right button hold, this counter will be set to 1
    marcoTimerCount := marcoTimerCount + 1
    marcoAccessKey := ""
    return
}

RunUserMarco3:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        marcoAccessKey := ""
        return
    }
    i := 0
    loop
    {
        i := i+1
        if (i > actionArrayIndex3)
            break
        If (boss_Enable = 0)
        {
            if (marcoAccessKey = "")
                break
            if (marcoAccessKey = "dClickL" and (BEnableDCL = 1 or BEnableDCL =2))
                Break
            if (marcoAccessKey = "dClickR" and (BEnableDCR = 1 or BEnableDCR =2))
                Break
            if (marcoAccessKey = "wheelUp" and (BEnableWU = 1 or BEnableWU =2))
                Break
            if (marcoAccessKey = "wheelDown" and (BEnableWD = 1 or BEnableWD =2))
                Break
        }
        If (boss_Enable = 1)
        {
            if (bModeL = 9 and marcoLMouseHold = 0)
                Break
            if (bModeR = 9 and marcoRMouseHold = 0)
                Break
        }
        IfWinNotActive,%BServer%
            break
        action := actionArray3[i][1]
        content := actionArray3[i][2]
        if (action = 1)                           ;Key
            ;send {%content%}  
            Send {%content%}
        if (action = 2)                           ;Hold  
        {
            ;send {%content% down}
            Send {%content% down}
        }
        if (action = 3)                           ;Release
        {
            ;send {%content% up}
            Send {%content% up}
        }
        if (action = 4)                           ;Wait max not exceed 20 seconds Split wait time >1 second to 0.1 second units, to avoid background wait too long
        {
            Sleep %content% 
            /*
            t_sleep_time3 := content + 0
            if (t_sleep_time3 > 1000)
            {
                t_i3 := 0
                loop
                {
                    t_i3 := t_i3 + 100
                    if (t_i3 > t_sleep_time3 or t_i3 > 20000)
                        break
                    Sleep 100
                }
            }
            else
                Sleep %content% 
                */
        }
        if (action = 5)                           ;Send text
        {
            ;send {Text} %content% 
            sendinput, %content%  
        }
        if (action = 6)                           ;Custom statement
        {
            ahkExec(content)
        }
        if (action = 7)                           ;Pause macro
        {
            EndFunc()
        }
        if (action = 8)                           ;Close macro
        {
            boss_Enable=0
        }
        if (action = 9)                           ;Screen show info
        {
            DisplayInfo(content)
        }
        if (action = 10)                          ;Close screen show info
        {
            DisplayInfoClose()
        }
        if (action = 11)                          ;Placeholder
        {
        }
        if (action = 12)                          ;Change skill
        {
            ChangeSkill(content)
        }
        if (action = 13)                          ;Only first run statement, loop execute no longer execute
        {
            if (marcoTimerCount = 1)
                ahkExec(content)
        }
        if (action = 14)                          ;Continuous skill
        {
            ;if (content = "1")
            switch content
            {
                case "1":
                    setTimer, Label1, %BDelay1% 
                case "2":
                    setTimer, Label2, %BDelay2% 
                case "3":
                    setTimer, Label3, %BDelay3% 
                case "4":
                    setTimer, Label4, %BDelay4% 
                case "l", "L":
                    setTimer, MouseLButton, %BDelayL% 
                case "r", "R":
                    setTimer, MouseRButton, %BDelayR% 
                case "5":
                    setTimer, LabelMouseL, %BDelayMouseL% 
            }
        }
        if (action = 15)                          ;Stop continuous skill
        {
            switch content
            {
                case "1":
                    setTimer, Label1, off
                case "2":
                    setTimer, Label2, off
                case "3":
                    setTimer, Label3, off
                case "4":
                    setTimer, Label4, off
                case "l", "L":
                    setTimer, MouseLButton, off
                case "r", "R":
                    setTimer, MouseRButton, off
                case "5":
                    setTimer, LabelMouseL, off
            }
        }
        if (action = 16)                          ;Send multiple keys
        {
            keyArray := StrSplit(content, ",", ,3)
            v1 := keyArray[1]
            v2 := keyArray[2]
            v3 := keyArray[3]
            SendMultiKey(v1, v2, v3)
        }
        if (action = 17)                          ;Mouse circle, parameter1-Angle, parameter2-Ratio, parameter3-Time interval, parameter4-Key to send
        {
            directionArray := StrSplit(content, ",", ,5)
            d1 := directionArray[1]
            d2 := directionArray[2]
            d3 := directionArray[3]
            d4 := directionArray[4]
            d5 := directionArray[5]
            CircleMouse(d1, d2, d3, d4, d5)
        }
        if (action = 18)                          ;Mouse move, parameter1-X axis ratio, parameter2-Y axis ratio, parameter3- 1Ratio value;2Pixel value
        {
            pointArray := StrSplit(content, ",", ,2)
            d1 := pointArray[1]
            d2 := pointArray[2]
            MoveYourMouse(d1, d2, 1)
        }
        if (action = 19)                          ;Random key
        {
            randamKeyArray := StrSplit(content, ",")  
            arrayLength := randamKeyArray.MaxIndex()
            Random, randomNumber, 1, %arrayLength%
            keyFinal := randamKeyArray[randomNumber]
            Send {%keyFinal%}
        }
        if (action = 20)                          ;Save mouse position
        {
            MouseGetPos, savedMousePosionX, savedMousePosionY
        }
        if (action = 21)                          ;Restore mouse position
        {
            MouseMove, %savedMousePosionX%, %savedMousePosionY%
        }
        if (action = 22)                          ;Loop backpack
        {
            bagArray := StrSplit(content, ",", ,8)
            d1 := bagArray[1]
            d2 := bagArray[2]
            d3 := bagArray[3]
            d4 := bagArray[4]
            d5 := bagArray[5]
            d6 := bagArray[6]
            d7 := bagArray[7]
            d8 := bagArray[8]
            LoopBagAction(d1, d2, d3, d4, d5, d6, d7, d8)
        }
    }
    ;Only effective when loop execute macro, single run macro will not run, when left/right button hold, this counter will be set to 1
    marcoTimerCount := marcoTimerCount + 1
    marcoAccessKey := ""
    return
}

RunUserMarco4:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        marcoAccessKey := ""
        return
    }
    i := 0
    loop
    {
        i := i+1
        if (i > actionArrayIndex4)
            break
        If (boss_Enable = 0)
        {
            if (marcoAccessKey = "")
                break
            if (marcoAccessKey = "dClickL" and (BEnableDCL = 1 or BEnableDCL =2))
                Break
            if (marcoAccessKey = "dClickR" and (BEnableDCR = 1 or BEnableDCR =2))
                Break
            if (marcoAccessKey = "wheelUp" and (BEnableWU = 1 or BEnableWU =2))
                Break
            if (marcoAccessKey = "wheelDown" and (BEnableWD = 1 or BEnableWD =2))
                Break
        }
        If (boss_Enable = 1)
        {
            if (bModeL = 10 and marcoLMouseHold = 0)
                Break
            if (bModeR = 10 and marcoRMouseHold = 0)
                Break
        }
        IfWinNotActive,%BServer%
            break
        action := actionArray4[i][1]
        content := actionArray4[i][2]
        if (action = 1)                           ;Key
            ;send {%content%}  
            Send {%content%}
        if (action = 2)                           ;Hold  
        {
            ;send {%content% down}
            Send {%content% down}
        }
        if (action = 3)                           ;Release
        {
            ;send {%content% up}
            Send {%content% up}
        }
        if (action = 4)                           ;Wait max not exceed 20 seconds Split wait time >1 second to 0.1 second units, to avoid background wait too long
        {
            Sleep %content% 
            /*
            t_sleep_time4 := content + 0
            if (t_sleep_time4 > 1000)
            {
                t_i4 := 0
                loop
                {
                    t_i4 := t_i4 + 100
                    if (t_i4 > t_sleep_time4 or t_i4 > 20000)
                        break
                    Sleep 100
                }
            }
            else
                Sleep %content% 
                */
        }
        if (action = 5)                           ;Send text
        {
            ;send {Text} %content% 
            sendinput, %content% 
        }
        if (action = 6)                           ;Custom statement
        {
            ahkExec(content)
        }
        if (action = 7)                           ;Pause macro
        {
            EndFunc()
        }
        if (action = 8)                           ;Close macro
        {
            boss_Enable=0
        }
        if (action = 9)                           ;Screen show info
        {
            DisplayInfo(content)
        }
        if (action = 10)                          ;Close screen show info
        {
            DisplayInfoClose()
        }
        if (action = 11)                          ;Placeholder
        {
        }
        if (action = 12)                          ;Change skill
        {
            ChangeSkill(content)
        }
        if (action = 13)                          ;Only first run statement, loop execute no longer execute
        {
            if (marcoTimerCount = 1)
                ahkExec(content)
        }
        if (action = 14)                          ;Continuous skill
        {
            ;if (content = "1")
            switch content
            {
                case "1":
                    setTimer, Label1, %BDelay1% 
                case "2":
                    setTimer, Label2, %BDelay2% 
                case "3":
                    setTimer, Label3, %BDelay3% 
                case "4":
                    setTimer, Label4, %BDelay4% 
                case "l", "L":
                    setTimer, MouseLButton, %BDelayL% 
                case "r", "R":
                    setTimer, MouseRButton, %BDelayR% 
                case "5":
                    setTimer, LabelMouseL, %BDelayMouseL% 
            }
        }
        if (action = 15)                          ;Stop continuous skill
        {
            switch content
            {
                case "1":
                    setTimer, Label1, off
                case "2":
                    setTimer, Label2, off
                case "3":
                    setTimer, Label3, off
                case "4":
                    setTimer, Label4, off
                case "l", "L":
                    setTimer, MouseLButton, off
                case "r", "R":
                    setTimer, MouseRButton, off
                case "5":
                    setTimer, LabelMouseL, off
            }
        }
        if (action = 16)                          ;Send multiple keys
        {
            keyArray := StrSplit(content, ",", ,3)
            v1 := keyArray[1]
            v2 := keyArray[2]
            v3 := keyArray[3]
            SendMultiKey(v1, v2, v3)
        }
        if (action = 17)                          ;Mouse circle, parameter1-Angle, parameter2-Ratio, parameter3-Time interval, parameter4-Key to send
        {
            directionArray := StrSplit(content, ",", ,5)
            d1 := directionArray[1]
            d2 := directionArray[2]
            d3 := directionArray[3]
            d4 := directionArray[4]
            d5 := directionArray[5]
            CircleMouse(d1, d2, d3, d4, d5)
        }
        if (action = 18)                          ;Mouse move, parameter1-X axis ratio, parameter2-Y axis ratio, parameter3- 1Ratio value;2Pixel value
        {
            pointArray := StrSplit(content, ",", ,2)
            d1 := pointArray[1]
            d2 := pointArray[2]
            MoveYourMouse(d1, d2, 1)
        }
        if (action = 19)                          ;Random key
        {
            randamKeyArray := StrSplit(content, ",")  
            arrayLength := randamKeyArray.MaxIndex()
            Random, randomNumber, 1, %arrayLength%
            keyFinal := randamKeyArray[randomNumber]
            Send {%keyFinal%}
        }
        if (action = 20)                          ;Save mouse position
        {
            MouseGetPos, savedMousePosionX, savedMousePosionY
        }
        if (action = 21)                          ;Restore mouse position
        {
            MouseMove, %savedMousePosionX%, %savedMousePosionY%
        }
        if (action = 22)                          ;Loop backpack
        {
            bagArray := StrSplit(content, ",", ,8)
            d1 := bagArray[1]
            d2 := bagArray[2]
            d3 := bagArray[3]
            d4 := bagArray[4]
            d5 := bagArray[5]
            d6 := bagArray[6]
            d7 := bagArray[7]
            d8 := bagArray[8]
            LoopBagAction(d1, d2, d3, d4, d5, d6, d7, d8)
        }
    }
    ;Only effective when loop execute macro, single run macro will not run, when left/right button hold, this counter will be set to 1
    marcoTimerCount := marcoTimerCount + 1
    marcoAccessKey := ""
    return
}

RunUserMarco5:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        marcoAccessKey := ""
        return
    }
    i := 0
    loop
    {
        i := i+1
        if (i > actionArrayIndex5)
            break
        If (boss_Enable = 0)
        {
            if (marcoAccessKey = "")
                break
            if (marcoAccessKey = "dClickL" and (BEnableDCL = 1 or BEnableDCL =2))
                Break
            if (marcoAccessKey = "dClickR" and (BEnableDCR = 1 or BEnableDCR =2))
                Break
            if (marcoAccessKey = "wheelUp" and (BEnableWU = 1 or BEnableWU =2))
                Break
            if (marcoAccessKey = "wheelDown" and (BEnableWD = 1 or BEnableWD =2))
                Break
        }
        If (boss_Enable = 1)
        {
            if (bModeL = 11 and marcoLMouseHold = 0)
                Break
            if (bModeR = 11 and marcoRMouseHold = 0)
                Break
        }
        IfWinNotActive,%BServer%
            break
        action := actionArray5[i][1]
        content := actionArray5[i][2]
        if (action = 1)                           ;Key
            ;send {%content%}  
            Send {%content%}
        if (action = 2)                           ;Hold  
        {
            ;send {%content% down}
            Send {%content% down}
        }
        if (action = 3)                           ;Release
        {
            ;send {%content% up}
            Send {%content% up}
        }
        if (action = 4)                           ;Wait max not exceed 20 seconds Split wait time >1 second to 0.1 second units, to avoid background wait too long
        {
            Sleep %content% 
            /*
            t_sleep_time5 := content + 0
            if (t_sleep_time5 > 1000)
            {
                t_i5 := 0
                loop
                {
                    t_i5 := t_i5 + 100
                    if (t_i5 > t_sleep_time5 or t_i5 > 20000)
                        break
                    Sleep 100
                }
            }
            else
                Sleep %content% 
            */
        }
        if (action = 5)                           ;Send text
        {
            ;send {Text} %content% 
            sendinput, %content% 
        }
        if (action = 6)                           ;Custom statement
        {
            ahkExec(content)
        }
        if (action = 7)                           ;Pause macro
        {
            EndFunc()
        }
        if (action = 8)                           ;Close macro
        {
            boss_Enable=0
        }
        if (action = 9)                           ;Screen show info
        {
            DisplayInfo(content)
        }
        if (action = 10)                          ;Close screen show info
        {
            DisplayInfoClose()
        }
        if (action = 11)                          ;Placeholder
        {
        }
        if (action = 12)                          ;Change skill
        {
            ChangeSkill(content)
        }
        if (action = 13)                          ;Only first run statement, loop execute no longer execute
        {
            if (marcoTimerCount = 1)
                ahkExec(content)
        }
        if (action = 14)                          ;Continuous skill
        {
            ;if (content = "1")
            switch content
            {
                case "1":
                    setTimer, Label1, %BDelay1% 
                case "2":
                    setTimer, Label2, %BDelay2% 
                case "3":
                    setTimer, Label3, %BDelay3% 
                case "4":
                    setTimer, Label4, %BDelay4% 
                case "l", "L":
                    setTimer, MouseLButton, %BDelayL% 
                case "r", "R":
                    setTimer, MouseRButton, %BDelayR% 
                case "5":
                    setTimer, LabelMouseL, %BDelayMouseL% 
            }
        }
        if (action = 15)                          ;Stop continuous skill
        {
            switch content
            {
                case "1":
                    setTimer, Label1, off
                case "2":
                    setTimer, Label2, off
                case "3":
                    setTimer, Label3, off
                case "4":
                    setTimer, Label4, off
                case "l", "L":
                    setTimer, MouseLButton, off
                case "r", "R":
                    setTimer, MouseRButton, off
                case "5":
                    setTimer, LabelMouseL, off
            }
        }
        if (action = 16)                          ;Send multiple keys
        {
            keyArray := StrSplit(content, ",", ,3)
            v1 := keyArray[1]
            v2 := keyArray[2]
            v3 := keyArray[3]
            SendMultiKey(v1, v2, v3)
        }
        if (action = 17)                          ;Mouse circle, parameter1-Angle, parameter2-Ratio, parameter3-Time interval, parameter4-Key to send
        {
            directionArray := StrSplit(content, ",", ,5)
            d1 := directionArray[1]
            d2 := directionArray[2]
            d3 := directionArray[3]
            d4 := directionArray[4]
            d5 := directionArray[5]
            CircleMouse(d1, d2, d3, d4, d5)
        }
        if (action = 18)                          ;Mouse move, parameter1-X axis ratio, parameter2-Y axis ratio, parameter3- 1Ratio value;2Pixel value
        {
            pointArray := StrSplit(content, ",", ,2)
            d1 := pointArray[1]
            d2 := pointArray[2]
            MoveYourMouse(d1, d2, 1)
        }
        if (action = 19)                          ;Random key
        {
            randamKeyArray := StrSplit(content, ",")  
            arrayLength := randamKeyArray.MaxIndex()
            Random, randomNumber, 1, %arrayLength%
            keyFinal := randamKeyArray[randomNumber]
            Send {%keyFinal%}
        }
        if (action = 20)                          ;Save mouse position
        {
            MouseGetPos, savedMousePosionX, savedMousePosionY
        }
        if (action = 21)                          ;Restore mouse position
        {
            MouseMove, %savedMousePosionX%, %savedMousePosionY%
        }
        if (action = 22)                          ;Loop backpack
        {
            bagArray := StrSplit(content, ",", ,8)
            d1 := bagArray[1]
            d2 := bagArray[2]
            d3 := bagArray[3]
            d4 := bagArray[4]
            d5 := bagArray[5]
            d6 := bagArray[6]
            d7 := bagArray[7]
            d8 := bagArray[8]
            LoopBagAction(d1, d2, d3, d4, d5, d6, d7, d8)
        }
    }
    ;Only effective when loop execute macro, single run macro will not run, when left/right button hold, this counter will be set to 1
    marcoTimerCount := marcoTimerCount + 1
    marcoAccessKey := ""
    return
}

RunUserMarcoX(cur_marco_num)  ;Dynamic call custom macro
{
    Global 
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        marcoAccessKey := ""
        return
    }
    i := 0
    loop
    {
        i := i+1
        if (i > actionArrayIndex%cur_marco_num%)
            break
        If (boss_Enable = 0)
        {
            if (marcoAccessKey = "")
                break
            if (marcoAccessKey = "dClickL" and (BEnableDCL = 1 or BEnableDCL =2))
                Break
            if (marcoAccessKey = "dClickR" and (BEnableDCR = 1 or BEnableDCR =2))
                Break
            if (marcoAccessKey = "wheelUp" and (BEnableWU = 1 or BEnableWU =2))
                Break
            if (marcoAccessKey = "wheelDown" and (BEnableWD = 1 or BEnableWD =2))
                Break
        }
        If (boss_Enable = 1)
        {
            if (bModeL = 11 and marcoLMouseHold = 0)
                Break
            if (bModeR = 11 and marcoRMouseHold = 0)
                Break
        }
        IfWinNotActive,%BServer%
            break
        action := actionArray%cur_marco_num%[i][1]
        content := actionArray%cur_marco_num%[i][2]
        if (action = 1)                           ;Key
            Send {%content%}
        if (action = 2)                           ;Hold  
        {
            Send {%content% down}
        }
        if (action = 3)                           ;Release
        {
            Send {%content% up}
        }
        if (action = 4)                           ;Wait max not exceed 20 seconds Split wait time >1 second to 0.1 second units, to avoid background wait too long
        {
            Sleep %content% 
            /*
            t_sleep_time5 := content + 0
            if (t_sleep_time5 > 1000)
            {
                t_i5 := 0
                loop
                {
                    t_i5 := t_i5 + 100
                    if (t_i5 > t_sleep_time5 or t_i5 > 20000)
                        break
                    Sleep 100
                }
            }
            else
                Sleep %content% 
            */
        }
        if (action = 5)                           ;Send text
        {
            sendinput, %content% 
        }
        if (action = 6)                           ;Custom statement
        {
            ahkExec(content)
        }
        if (action = 7)                           ;Pause macro
        {
            EndFunc()
        }
        if (action = 8)                           ;Close macro
        {
            boss_Enable=0
        }
        if (action = 9)                           ;Screen show info
        {
            DisplayInfo(content)
        }
        if (action = 10)                          ;Close screen show info
        {
            DisplayInfoClose()
        }
        if (action = 11)                          ;Placeholder
        {
        }
        if (action = 12)                          ;Change skill
        {
            ChangeSkill(content)
        }
        if (action = 13)                          ;Only first run statement, loop execute no longer execute
        {
            if (marcoTimerCount = 1)
                ahkExec(content)
        }
        if (action = 14)                          ;Continuous skill
        {
            switch content
            {
                case "1":
                    setTimer, Label1, %BDelay1% 
                case "2":
                    setTimer, Label2, %BDelay2% 
                case "3":
                    setTimer, Label3, %BDelay3% 
                case "4":
                    setTimer, Label4, %BDelay4% 
                case "l", "L":
                    setTimer, MouseLButton, %BDelayL% 
                case "r", "R":
                    setTimer, MouseRButton, %BDelayR% 
                case "5":
                    setTimer, LabelMouseL, %BDelayMouseL% 
            }
        }
        if (action = 15)                          ;Stop continuous skill
        {
            switch content
            {
                case "1":
                    setTimer, Label1, off
                case "2":
                    setTimer, Label2, off
                case "3":
                    setTimer, Label3, off
                case "4":
                    setTimer, Label4, off
                case "l", "L":
                    setTimer, MouseLButton, off
                case "r", "R":
                    setTimer, MouseRButton, off
                case "5":
                    setTimer, LabelMouseL, off
            }
        }
        if (action = 16)                          ;Send multiple keys
        {
            keyArray := StrSplit(content, ",", ,3)
            v1 := keyArray[1]
            v2 := keyArray[2]
            v3 := keyArray[3]
            SendMultiKey(v1, v2, v3)
        }
        if (action = 17)                          ;Mouse circle, parameter1-Angle, parameter2-Ratio, parameter3-Time interval, parameter4-Key to send
        {
            directionArray := StrSplit(content, ",", ,5)
            d1 := directionArray[1]
            d2 := directionArray[2]
            d3 := directionArray[3]
            d4 := directionArray[4]
            d5 := directionArray[5]
            CircleMouse(d1, d2, d3, d4, d5)
        }
        if (action = 18)                          ;Mouse move, parameter1-X axis ratio, parameter2-Y axis ratio, parameter3- 1Ratio value;2Pixel value
        {
            pointArray := StrSplit(content, ",", ,2)
            d1 := pointArray[1]
            d2 := pointArray[2]
            MoveYourMouse(d1, d2, 1)
        }
        if (action = 19)                          ;Random key
        {
            randamKeyArray := StrSplit(content, ",")  
            arrayLength := randamKeyArray.MaxIndex()
            Random, randomNumber, 1, %arrayLength%
            keyFinal := randamKeyArray[randomNumber]
            Send {%keyFinal%}
        }
        if (action = 20)                          ;Save mouse position
        {
            MouseGetPos, savedMousePosionX, savedMousePosionY
        }
        if (action = 21)                          ;Restore mouse position
        {
            MouseMove, %savedMousePosionX%, %savedMousePosionY%
        }
        if (action = 22)                          ;Loop backpack
        {
            bagArray := StrSplit(content, ",", ,8)
            d1 := bagArray[1]
            d2 := bagArray[2]
            d3 := bagArray[3]
            d4 := bagArray[4]
            d5 := bagArray[5]
            d6 := bagArray[6]
            d7 := bagArray[7]
            d8 := bagArray[8]
            LoopBagAction(d1, d2, d3, d4, d5, d6, d7, d8)
        }
    }
    ;Only effective when loop execute macro, single run macro will not run, when left/right button hold, this counter will be set to 1
    marcoTimerCount := marcoTimerCount + 1
    marcoAccessKey := ""
    return
}

ChangeSkill(content_st)
{
    Array := StrSplit(content_st, "-", ,2)
    pos1 := GetSkillPos(Array[1], 1)
    pos2 := GetSkillPos(Array[2], 2)
    ;ControlSend ,,S,%BServer%
    send {s}
    Sleep, 500
    MouseMove, 200, 200, 0 ;
    Sleep, 100
    MouseClickDrag, L, pos1[1], pos1[2], pos2[1], pos2[2]
    Sleep, 100
    send {s}
    ;ControlSend ,,S,%BServer%
}

GetSkillPos(SwitchValue, mode) ;mode=1 for skill panel, mode=2 for skill bar
{
    WinGetPos, X, Y, current_Width, current_Height, %BServer%
    sysget titlebar_height, 4, %BServer%
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }
    s_x := 0
    s_y := 0

    if (mode = 1)
    {
        row := substr(SwitchValue, 1, 1)
        col := substr(SwitchValue, 2, 1)
        if (row = 1)
            y_var := 1063
        if (row = 2)
            y_var := 1154
        if (row = 3)
            y_var := 1296
        if (row = 4)
            y_var := 1445
        if (row = 5)
            y_var := 1584
        if (row = 6)
            y_var := 1725
            
        if (col = 1)
            x_var := 1744
        if (col = 2)
            x_var := 1869
        if (col = 3)
            x_var := 1996
        if (col = 4)
            x_var := 2122
        if (col = 5)
            x_var := 2247
        s_x := current_Width*x_var/3840
        s_y := (current_Height - titlebar_height)*y_var/2160+titlebar_height
    }

    if (mode = 2)
    {
        y_var := 2011
        col := SwitchValue
        if (col = 1)
            x_var := 1600
        if (col = 2)
            x_var := 1740
        if (col = 3)
            x_var := 1858
        if (col = 4)
            x_var := 1986
        if (col = 5)
            x_var := 2110
        if (col = 6)
            x_var := 2236
        s_x := current_Width*x_var/3840
        s_y := (current_Height - titlebar_height)*y_var/2160+titlebar_height
    }

    return [s_x, s_y]
}

RunUserMarco:
{
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        return
    }
    i := 0
    loop
    {
        i := i+1
        if (i > actionArrayIndex1)
            break
        action := actionArray1[i][1]
        content := actionArray1[i][2]
        ;msgbox, %action% . %content%
        if (action = 1)                           ;Key
            ;send {%content%}  
            Send {%content%}
        if (action = 2)                           ;Hold  
        {
            ;send {%content% down}
            Send {%content% down}
        }
        if (action = 3)                           ;Release
        {
            ;send {%content% up}
            Send {%content% up}
        }
        if (action = 4)                           ;Wait
            Sleep %content% 
        if (action = 5)                           ;Custom statement
        {

        }
    }
    return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EndFunc()
{
    SetTimer, Label1, off 
    SetTimer, Label2, off 
    SetTimer, Label3, off 
    SetTimer, Label4, off 
    SetTimer, LabelMouseL, off 
    SetTimer, LabelPotion, off 
    SetTimer, MouseLButton, off 
    SetTimer, MouseRButton, off 
    SetTimer, RunUserMarco1, off 
    SetTimer, RunUserMarco2, off 
    SetTimer, RunUserMarco3, off 
    SetTimer, RunUserMarco4, off 
    SetTimer, RunUserMarco5, off 
    SetTimer, gtrack, off  
    SetTimer, KeepSkillBuff, off  
    
    SetTimer Dispatcher, off
    
    DisplayInfoClose()
    DisplayOPInfoClose()

    if (GetKeyState("z",P))
		Send {z up}
    if (GetKeyState(".",P))
		Send {. up}
    if (GetKeyState("shift",P))
		Send {Shift up}
    if (GetKeyState("space",P))
		Send {space up}
    if (GetKeyState("LButton",P))
		Send {LButton up}
    if (GetKeyState("RButton",P))
        Send {RButton up}
    if (GetKeyState("1",P))
        Send {1 up}
    if (GetKeyState("2",P))
        Send {2 up}
    if (GetKeyState("3",P))
        Send {3 up}
    if (GetKeyState("4",P))
        Send {4 up}
    if (GetKeyState("5",P))
        Send {5 up}
        
    KeyList := "Shift|Ctrl|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|1|2|3|4|5|6|7|8|9|0|-|=|`|,|.|/|\|[|]" 
    Loop, Parse, KeyList, |
    {
        If GetKeystate(A_Loopfield, "P")
            Send % "{" A_Loopfield " Up}"
    }
        
    Global channel_Enable
    channel_Enable := 0        
    Global channel2_Enable
    channel2_Enable := 0    
    Global BAutoL_Enable
    BAutoL_Enable := 0    
    Global BAutoR_Enable
    BAutoR_Enable := 0
    Global BAutoMouseL_Enable
    BAutoMouseL_Enable := 0
    Global BAuto1_Enable
    BAuto1_Enable := 0
    Global BAuto2_Enable
    BAuto2_Enable := 0
    Global BAuto3_Enable
    BAuto3_Enable := 0
    Global BAuto4_Enable
    BAuto4_Enable := 0
    Global BMarco1_Enable
    BMarco1_Enable := 0
    Global BMarco2_Enable
    BMarco2_Enable := 0
    Global BMarco3_Enable
    BMarco3_Enable := 0
    Global BMarco4_Enable
    BMarco4_Enable := 0
    Global BMarco5_Enable
    BMarco5_Enable := 0

    Global Skill1Pending
    Skill1Pending := false
    Global Skill2Pending
    Skill2Pending := false
    Global Skill3Pending
    Skill3Pending := false
    Global Skill4Pending
    Skill4Pending := false
    Global MouseLPending
    MouseLPending := false
    Global MouseRPending
    MouseRPending := false
    Global Skill5Pending
    Skill5Pending := false
    Global DispatchIndex
    DispatchIndex := 1
    
    return
}

StartForceMove:
{
    if (BFMStopLM = 1)
        SetTimer, MouseLButton, off
    if (BFMStopRM = 1)
        SetTimer, MouseRButton, off
    if (BFMStopCH1 = 1 and channel_Enable = 1)
        Send {%real_key% up}
    if (BFMStopCH2 = 1 and channel2_Enable = 1)
        Send {%real_key2% up}
    if (BFMStopKey1 = 1)
        SetTimer, Label1, off
    if (BFMStopKey2 = 1)
        SetTimer, Label2, off
    if (BFMStopKey3 = 1)
        SetTimer, Label3, off
    if (BFMStopKey4 = 1)
        SetTimer, Label4, off
    if (BFMStopKey5 = 1)
        SetTimer, LabelMouseL, off
        
    
    channel_status := channel_enable
    channel2_status := channel2_enable
    BAutoL_status := BAutoL_enable
    BAutoR_status := BAutoR_enable
    BAuto1_status := BAuto1_enable
    BAuto2_status := BAuto2_enable
    BAuto3_status := BAuto3_enable
    BAuto4_status := BAuto4_enable
    BAutoMouseL_status := BAutoMouseL_Enable
    Send {%real_key% up}
    Send {%real_key2% up}
    
    return
}
EndForceMove:
{    
    ;;;;;Restore status;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    channel_enable := channel_status
    channel2_enable := channel2_status
    BAutoL_enable := BAutoL_status
    BAutoR_enable := BAutoR_status
    BAuto1_enable := BAuto1_status
    BAuto2_enable := BAuto2_status
    BAuto3_enable := BAuto3_status
    BAuto4_enable := BAuto4_status
    BAutoMouseL_Enable := BAutoMouseL_status
    if (channel_Enable = 1)
    {
        Send {%real_key% down}
    }
    if (channel2_Enable = 1)
    {
        Send {%real_key2% down}
    }
    if (BAutoL_enable = 1)
    {
        SetTimer, MouseLButton, %BDelayL%
    }
    if (BAutoR_enable = 1 and BFMStopRM = 1)
    {
        SetTimer, MouseRButton, %BDelayR%
    }
    if (BAuto1_enable = 1 and BFMStopKey1 = 1)
    {
        SetTimer, Label1, %BDelay1%
    }
    if (BAuto2_enable = 1 and BFMStopKey2 = 1)
    {
        SetTimer, Label2, %BDelay2%
    }
    if (BAuto3_enable = 1 and BFMStopKey3 = 1)
    {
        SetTimer, Label3, %BDelay3%
    }
    if (BAuto4_enable = 1 and BFMStopKey4 = 1)
    {
        SetTimer, Label4, %BDelay4%
    }
    if (BAutoMouseL_Enable = 1 and BFMStopKey5 = 1)
    {
        SetTimer, LabelMouseL, %BDelayMouseL%
    }
    ;;;;;Restore status;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
    return
}
StartPickUp:
{
    if (BPUStopLM = 1)
        SetTimer, MouseLButton, off
    if (BPUStopRM = 1)
        SetTimer, MouseRButton, off
    if (BPUStopCH1 = 1 and channel_Enable = 1)
        Send {%real_key% up}
    if (BPUStopCH2 = 1 and channel2_Enable = 1)
        Send {%real_key2% up}
    if (BPUStopKey1 = 1)
        SetTimer, Label1, off
    if (BPUStopKey2 = 1)
        SetTimer, Label2, off
    if (BPUStopKey3 = 1)
        SetTimer, Label3, off
    if (BPUStopKey4 = 1)
        SetTimer, Label4, off
    if (BPUStopKey5 = 1)
        SetTimer, LabelMouseL, off
        

    channel_status := channel_enable
    channel2_status := channel2_enable
    BAutoL_status := BAutoL_enable
    BAutoR_status := BAutoR_enable
    BAuto1_status := BAuto1_enable
    BAuto2_status := BAuto2_enable
    BAuto3_status := BAuto3_enable
    BAuto4_status := BAuto4_enable
    BAutoMouseL_status := BAutoMouseL_Enable 
    
    return
}
EndPickUp:
{
    ;;;;;Restore channel status;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    channel_enable := channel_status
    channel2_enable := channel2_status
    BAutoL_enable := BAutoL_status
    BAutoR_enable := BAutoR_status
    BAuto1_enable := BAuto1_status
    BAuto2_enable := BAuto2_status
    BAuto3_enable := BAuto3_status
    BAuto4_enable := BAuto4_status
    BAutoMouseL_Enable := BAutoMouseL_status
    if (BPUStopCH1 = 1 and channel_Enable = 1)
    {
        Send {%real_key% down}
    }
    if (BPUStopCH2 = 1 and channel2_Enable = 1)
    {
        Send {%real_key2% down}
    }
    if ((BPUStopLM = 1))
    {
        if (BDelayL2 = 0)
        {
            if (BAutoL_enable = 1)
                SetTimer, MouseLButton, %BDelayL%
        }
        else if (BDelayL2 != 0) ;BDelayL2 != 0 then BAutoL must be 1
        {
            if (BAutoL_enable = 1)
                SetTimer, MouseLButton, %BDelayL%
            else
                SetTimer, MouseLButton, %BDelayL2%
        }
    }
    if ((BPUStopRM = 1))
    {
        if (BDelayR2 = 0)
        {
            if (BAutoR_enable = 1)
            {
                Click Right
                SetTimer, MouseRButton, %BDelayR%
            }
        }
        else if (BDelayR2 != 0) ;BDelayL2 != 0 then BAutoL must be 1
        {
            if (BAutoR_enable = 1)
            {
                Click Right
                SetTimer, MouseRButton, %BDelayR%
            }
            else
            {
                Click Right
                SetTimer, MouseRButton, %BDelayR2%
            }
        }
    }
    if ((BPUStopKey1 = 1))
    {
        if (BDelay12 = 0)
        {
            if (BAuto1_enable = 1)
            {
                send {%BSkillKey1%} 
                SetTimer, Label1, %BDelay1%
            }
        }
        else if (BDelay12 != 0) ;BDelayL2 != 0 then BAutoL must be 1
        {
            if (BAuto1_enable = 1)
            {
                send {%BSkillKey1%} 
                SetTimer, Label1, %BDelay1%
            }
            else
            {
                send {%BSkillKey1%} 
                SetTimer, Label1, %BDelay12%
            }
        }
    }
    if ((BPUStopKey2 = 1))
    {
        if (BDelay22 = 0)
        {
            if (BAuto2_enable = 1)
            {
                send {%BSkillKey2%} 
                SetTimer, Label2, %BDelay2%
            }
        }
        else if (BDelay22 != 0) ;BDelayL2 != 0 then BAutoL must be 1
        {
            if (BAuto2_enable = 1)
            {
                send {%BSkillKey2%} 
                SetTimer, Label2, %BDelay2%
            }
            else
            {
                send {%BSkillKey2%} 
                SetTimer, Label2, %BDelay22%
            }
        }
    }
    if ((BPUStopKey3 = 1))
    {
        if (BDelay32 = 0)
        {
            if (BAuto3_enable = 1)
            {
                send {%BSkillKey3%} 
                SetTimer, Label3, %BDelay3%
            }
        }
        else if (BDelay32 != 0) ;BDelayL2 != 0 then BAutoL must be 1
        {
            if (BAuto3_enable = 1)
            {
                send {%BSkillKey3%} 
                SetTimer, Label3, %BDelay3%
            }
            else
            {
                send {%BSkillKey3%} 
                SetTimer, Label3, %BDelay32%
            }
        }
    }
    if ((BPUStopKey4 = 1))
    {
        if (BDelay42 = 0)
        {
            if (BAuto4_enable = 1)
            {
                send {%BSkillKey4%} 
                SetTimer, Label4, %BDelay4%
            }
        }
        else if (BDelay42 != 0) ;BDelayL2 != 0 then BAutoL must be 1
        {
            if (BAuto4_enable = 1)
            {
                send {%BSkillKey4%} 
                SetTimer, Label4, %BDelay4%
            }
            else
            {
                send {%BSkillKey4%} 
                SetTimer, Label4, %BDelay42%
            }
        }
    }
    if ((BPUStopKey5 = 1))
    {
        if (BDelayMouseL2 = 0)
        {
            if (BAutoMouseL_Enable = 1)
            {
                send {%BLMouseKey%} 
                SetTimer, LabelMouseL, %BDelayMouseL%
            }
        }
        else if (BDelayMouseL2 != 0) ;BDelayL2 != 0 then BAutoL must be 1
        {
            if (BAutoMouseL_Enable = 1)
            {
                send {%BLMouseKey%} 
                SetTimer, LabelMouseL, %BDelayMouseL%
            }
            else
            {
                send {%BLMouseKey%} 
                SetTimer, LabelMouseL, %BDelayMouseL2%
            }
        }
    }
    
    return
}

StartMarco:
{
    if (BMarcoAS1 = 1)
    {
        BMarco1_Enable := 1
        ;SetTimer, RunUserMarco1, 1
        GoSub RunUserMarco1
    }
    if (BMarcoAS2 = 1)
    {
        BMarco2_Enable := 1
        ;SetTimer, RunUserMarco2, 1
        GoSub RunUserMarco2
    }
    if (BMarcoAS3 = 1)
    {
        BMarco3_Enable := 1
        ;SetTimer, RunUserMarco3, 1
        GoSub RunUserMarco3
    }
    if (BMarcoAS4 = 1)
    {
        BMarco4_Enable := 1
        ;SetTimer, RunUserMarco4, 1
        GoSub RunUserMarco4
    }
    if (BMarcoAS5 = 1)
    {
        BMarco5_Enable := 1
        ;SetTimer, RunUserMarco5, 1
        GoSub RunUserMarco5
    }

    if (BKeep1 = 1 or BKeep2 = 1 or BKeep3 = 1 or BKeep4 = 1 or BKeepL = 1 or BKeepR = 1 or BKeepMouseL = 1)
    {
        SetTimer, KeepSkillBuff, 50
    }

    SetTimer Dispatcher, 15
    
    if (BAuto1 = 1 and BKeep1 != 1)
    {
        BAuto1_Enable:=1
        send {%BSkillKey1%} 
        SetTimer, Label1, %BDelay1%
    }
    else if (BAuto1 != 1 and BKeep1 != 1)
    {
        SetTimer, Label1, off
    }  
    
    if (BAuto2 = 1 and BKeep2 != 1)
    {
        BAuto2_Enable:=1
        send {%BSkillKey2%} 
        SetTimer, Label2, %BDelay2%
    }
    else if (BAuto2 != 1 and BKeep2 != 1) 
    {
        SetTimer, Label2, off
    }    
    
    if (BAuto3 = 1 and BKeep3 != 1)
    {
        BAuto3_Enable:=1
        send {%BSkillKey3%} 
        SetTimer, Label3, %BDelay3%
    }
    else if (BAuto3 != 1 and BKeep3 != 1) 
    {
        SetTimer, Label3, off
    }   
    
    if (BAuto4 = 1 and BKeep4 != 1)
    {
        BAuto4_Enable:=1
        send {%BSkillKey4%} 
        SetTimer, Label4, %BDelay4%
    }
    else if (BAuto4 != 1 and BKeep4 != 1)  
    {
        SetTimer, Label4, off
    }  
    
    if (BAutoMouseL = 1 and BKeepMouseL != 1)
    {
        BAutoMouseL_Enable:=1
        send {%BLMouseKey%} 
        SetTimer, LabelMouseL, %BDelayMouseL%
    }
    else if (BAutoMouseL != 1 and BKeepMouseL != 1)  
    {
        SetTimer, LabelMouseL, off
    }  
    
    if (BAutoL = 1 and BKeepL != 1)
    {
        BAutoL_Enable:=1
        SetTimer, MouseLButton, %BDelayL%
    }
    else if (BAutoL != 1 and BKeepL != 1) 
    {
        SetTimer, MouseLButton, off
    }  
    
    if (BAutoR = 1 and BKeepR != 1)
    {
        BAutoR_Enable:=1
        SetTimer, MouseRButton, %BDelayR%
    }
    else if (BAutoR != 1 and BKeepR != 1) 
    {
        SetTimer, MouseRButton, off
    } 
    
    if (BAutoPotion = 1)
    {
        send {q} 
        SetTimer, LabelPotion, %BPotionDelay1%
    }
    else if (BAuto1 != 1 and BKeep1 != 1)
    {
        SetTimer, LabelPotion, off
    }  
    
    if (Bchannel = 1)
    {
        channel_Enable:=1
        real_key := ""
        if (BchannelKey = 1)
            real_key := "RButton"
        if (BchannelKey = 2)
            real_key := BSkillKey1
        if (BchannelKey = 3)
            real_key := BSkillKey2
        if (BchannelKey = 4)
            real_key := BSkillKey3
        if (BchannelKey = 5)
            real_key := BSkillKey4
        if (BchannelKey = 6)
            ;real_key := "z"
            real_key := BMoveKey
        if (BchannelKey = 7)
            ;real_key := "."
            real_key := BStandKey
        if (BchannelKey = 8)
            real_key := BLMouseKey

        Send {%real_key% down}
    }
    
    if (Bchannel2 = 1)
    {
        channel2_Enable:=1
        real_key2 := ""
        if (BchannelKey2 = 1)
            real_key2 := "RButton"
        if (BchannelKey2 = 2)
            real_key2 := BSkillKey1
        if (BchannelKey2 = 3)
            real_key2 := BSkillKey2
        if (BchannelKey2 = 4)
            real_key2 := BSkillKey3
        if (BchannelKey2 = 5)
            real_key2 := BSkillKey4
        if (BchannelKey2 = 6)
            ;real_key := "z"
            real_key2 := BMoveKey
        if (BchannelKey2 = 7)
            ;real_key := "."
            real_key2 := BStandKey
        if (BchannelKey2 = 8)
            real_key2 := BLMouseKey

        Send {%real_key2% down}
    }

}
return

GetModeSkillLabel(SwitchValue, chooseMarcoLabelNum)
{
    labelName := ""
    if (chooseMarcoLabelNum = 1 or chooseMarcoLabelNum = 2) ;Left and right button
    {
        if (SwitchValue = 3)
            labelName := "Label1"
        if (SwitchValue = 4)
            labelName := "Label2"
        if (SwitchValue = 5)
            labelName := "Label3"
        if (SwitchValue = 6)
            labelName := "Label4"
        if (SwitchValue = 7)
            labelName := "RunUserMarco1"
        if (SwitchValue = 8)
            labelName := "RunUserMarco2"
        if (SwitchValue = 9)
            labelName := "RunUserMarco3"
        if (SwitchValue = 10)
            labelName := "RunUserMarco4"
        if (SwitchValue = 11)
            labelName := "RunUserMarco5"
        if (SwitchValue = 15)
            labelName := "LabelMouseL"
    }
    if (chooseMarcoLabelNum > 2)
    {
        if (SwitchValue = 1)
            labelName := "RunUserMarco1"
        if (SwitchValue = 2)
            labelName := "RunUserMarco2"
        if (SwitchValue = 3)
            labelName := "RunUserMarco3"
        if (SwitchValue = 4)
            labelName := "RunUserMarco4"
        if (SwitchValue = 5)
            labelName := "RunUserMarco5"
    }

    ;if (SwitchValue = 7)
        ;labelName := "RunUserMarco"
    return labelName
}

ResumeModeSkillLabel(labelName)
{
    global BAuto1,BAuto2,BAuto3,BAuto4,BAutoMouseL,BDelay1,BDelay2,BDelay3,BDelay4,BDelayMouseL ;,BFouceMove
    if (labelName = "Label1")
    {
        if (BAuto1 = 1)
            SetTimer, %labelName%, %BDelay1%
    }
    if (labelName = "Label2")
    {
        if (BAuto2 = 1)
            SetTimer, %labelName%, %BDelay2%
    }
    if (labelName = "Label3")
    {
        if (BAuto3 = 1)
            SetTimer, %labelName%, %BDelay3%
    }
    if (labelName = "Label4")
    {
        if (BAuto4 = 1)
            SetTimer, %labelName%, %BDelay4%
    }
    if (labelName = "LabelMouseL")
    {
        if (BAuto4 = 1)
            SetTimer, %labelName%, %BDelayMouseL%
    }
    return 0
}
;UserMarco;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetSkillBuffStatus(buttonID)
{
    ;Skill left to right order 1-6, 5 is left button
    global BServer
    WinGetPos, X, Y, current_Width, current_Height, %BServer%
    sysget titlebar_height, 4, %BServer%
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }	
    winW := current_Width
    winH := (current_Height - titlebar_height)
    static t_x:=[1288, 1377, 1465, 1554, 1647, 1734]
    static t_w:=63
    buffPercent := 0.05
    t_y:=1328*winH/1440
    pos1 := Round(winW/2-(3440/2-t_x[buttonID]-buffPercent*t_w)*winH/1440)
    pos2 := Round(t_y)
    PixelGetColor, tColor, pos1, pos2, rgb

    ;3840 2160
    ;static t_x:=[1260, 1393, 1528, 1660, 1800, 1933]
    ;static t_w:=118 ;1260-1378
    ;buffPercent := 0.05
    ;t_y:=1996*winH/2160
    ;pos1 := Round(winW/2-(3840/2-t_x[buttonID]-buffPercent*t_w)*winH/2160)
    ;pos2 := Round(t_y)
    ;PixelGetColor, tColor, pos1, pos2, rgb
    
    tBlue := (tColor & 0xFF)
    tGreen := ((tColor & 0xFF00) >> 8)
    tRed := ((tColor & 0xFF0000) >> 16)
    gameGamma := 1
    if (Abs(gameGamma-1)>=0.01)
    {
        tBlue:=((tBlue / 255) ** (1.75*gameGamma-0.75)) * 255
        tGreen:=((tGreen / 255) ** (1.9*gameGamma-0.9)) * 255
        tRed:=((tRed / 255) ** (1.9*gameGamma-0.9)) * 255
    }
    Return [tRed, tGreen, tBlue]
}

GetUserMarco:
{
    m_SettingFile = %SelectedFile%
	if FileExist( m_SettingFile )
	{
        marcoNum := 0
        loop
        {
            marcoNum := marcoNum + 1
            if (marcoNum>10)
                break
            actionArray%marcoNum% := []
            ActionArrayIndex%marcoNum%  := 0
            i := 0
            loop
            {
                if (i >= actionArrayCount%marcoNum%)
                    break
                i := i + 1
                IniRead, actionStr, %SelectedFile%, UserMarco%marcoNum%, cfgAction%i%
                actionStr := StrReplace(actionStr, "||", "`n")
                if (actionStr != "ERROR")
                {
                    Array := StrSplit(actionStr, ",", ,2)
                    actionArray%marcoNum%[i] := Array
                    ActionArrayIndex%marcoNum% := i
                }
                else
                {
                    break
                }

            }
        }
    }
    return
}

Add_action1:
{
    Global currentMarco
    marcoNum := currentMarco
    if (actionArrayIndex%marcoNum% >= actionArrayCount%marcoNum%)
    {
        MsgBox %marcoNum%
        MsgBox % "Max can only insert" actionArrayCount%marcoNum% "actions"
        return
    }
    actionArrayIndex%marcoNum% := actionArrayIndex%marcoNum%+1
    yValue := 60 + ((actionArrayIndex%marcoNum% - 1) * 20)

    t1 := actionArrayIndex%marcoNum%
    Gui, UserMarcoSet%marcoNum%:Add, CheckBox, x25 y%yValue% h20 vBActionArrayIndex%marcoNum%%t1%, Step%t1%:
    Gui, UserMarcoSet%marcoNum%:Add, DropDownList, x90 y%yValue% w100 AltSubmit choose1 vBActionArrayItem%marcoNum%%t1%, %actionItem% ;
    Gui, UserMarcoSet%marcoNum%:Add, Edit, x200 y%yValue% w250 h20 Multi vBActionArrayContent%marcoNum%%t1%,  ;
    actionArrayStatus%marcoNum%[actionArrayIndex%marcoNum%] := 1 ;Custom macro array

    return
}

Del_action1:
{
    Global currentMarco
    marcoNum := currentMarco
    i := 0
    loop
    {
        i := i+1
        if (i > actionArrayCount%marcoNum%)
            break
        GuiControlGet, BActionArrayIndex%marcoNum%%i%
        statusControl := BActionArrayIndex%marcoNum%%i%
        if (statusControl = 1)
        {
            GuiControl, UserMarcoSet%marcoNum%:Disable,  BActionArrayIndex%marcoNum%%i%
            GuiControl, UserMarcoSet%marcoNum%:Disable,  BActionArrayItem%marcoNum%%i%
            GuiControl, UserMarcoSet%marcoNum%:Disable,  BActionArrayContent%marcoNum%%i%
            actionArrayStatus%marcoNum%[i] := 0
        }
    }
    MsgBox, Delete success
    return
}

Destroy_action1:
{
    MsgBox, Clear success, restart program to take effect
    return
}

;;;;;;;;;D2R Functions;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
D2RSetWeaponHand(hand_num, times, interval) 
{
    global BServer, boss_Enable, BDispMode
    IfWinNotActive,%BServer%
    {
        return
    }

    WinGetPos, X, Y, current_Width, current_Height, %BServer%
    sysget titlebar_height, 4, %BServer%
    if (BDispMode = 2)
        titlebar_height := 0
    
    ;F1 skill top left： 0.3086 0.8389
    ;F1 skill bottom right： 0.3316 0.8798

    cur_handnum := 0
    check_pos1x := current_Width * 0.3086
    check_pos1y := (current_Height - titlebar_height) * 0.8389
    check_pos2x := current_Width * 0.3316
    check_pos2y := (current_Height - titlebar_height) * 0.8798
    PixelSearch, x, y, check_pos1x,check_pos1y,check_pos2x,check_pos2y,0xAC3233,3,Fast RGB 
    if !ErrorLevel 
        cur_handnum := 2
    Else
        cur_handnum := 1

    t_interval := interval
    if (t_interval is not Integer)
        t_interval := 50
    Else{
        if (t_interval > 500)
            t_interval := 500
    }
    t_times := times
    if (t_times is not Integer)
        t_times := 20
    Else{
        if (t_times > 40)
            t_times := 40
    }
    try_count := 1
    if (hand_num != cur_handnum)
    {
        while (try_count <= t_times)
        {
            Send, {w}

            Sleep, %t_interval%
            PixelSearch, x, y, check_pos1x,check_pos1y,check_pos2x,check_pos2y,0xAC3233,3,Fast RGB 
            if !ErrorLevel 
                cur_handnum := 2
            Else
                cur_handnum := 1
            if (hand_num = cur_handnum)
                Break

            try_count := try_count + 1
        }
    }

    Return
}
;;;;;;;;;D2R Functions end;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;Common Functions;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;#region 
; Function: Get all windows and sort by process creation time------------------------------------------------------------
GetDiabloWindowsByCreationTime(win_name)
{
    ;WinGet, hwndList, List, Diablo II: Resurrected
    WinGet, hwndList, List, %win_name%
    windows := []

    ; Get each window process creation time
    Loop, %hwndList%
    {
        hwnd := hwndList%A_Index%
        WinGet, pid, PID, ahk_id %hwnd%
        hProcess := DllCall("OpenProcess", "UInt", 0x1000, "Int", 0, "UInt", pid)
        if !hProcess
            continue

        ; Get process creation timestamp
        DllCall("GetProcessTimes", "Ptr", hProcess, "Int64*", creationTime, "Int64*", 0, "Int64*", 0, "Int64*", 0)
        DllCall("CloseHandle", "Ptr", hProcess)
        windows.Push({hwnd: hwnd, time: creationTime})
    }

    ; Sort by creation time (small to large)
    sorted := []
    for i, obj in windows
    {
        inserted := false
        for j, sortedObj in sorted
        {
            if (obj.time < sortedObj.time)
            {
                sorted.InsertAt(j, obj)
                inserted := true
                break
            }
        }
        if !inserted
            sorted.Push(obj)
    }

    ; Extract sorted handles
    result := []
    for i, obj in sorted
        result.Push(obj.hwnd)

    return result
}
; Function: Get all windows and sort by process creation time------------------------------------------------------------

;Multiple send key count--------------------------------------------------------
SendMultiKey(send_key, send_interval, send_times) 
{   
    ; Interval between each send (milliseconds)
    interval := send_interval  
    ; Loop count
    times := send_times
    ; Loop count
    key := send_key
    
    ; When macro not started, multiple keys may still be used, so only judge if window active
    ; Send specified count, each with specified interval
    global BServer
    Loop, %times% {
        Send, {%key%}
        Sleep, %interval%
        IfWinNotActive,%BServer%
        {
            return
        }
    }
}
;----------------------------------------------------------------------
;Mouse circle--------------------------------------------------------
CircleMouse(d_angle, d_ratio, d_time, d_key, d_type) ;Parameter1-Angle, Parameter2-Ratio/pixel, Parameter3-Time interval, Parameter4-Send key, Parameter5- 1In place circle, 2Moving circle
{   
    ; Angle
    angle := d_angle
    ; Ratio/pixel i.e. radius
    ratio := d_ratio
    ; Time interval (milliseconds)
    interval := d_time  
    ; Key
    key := d_key  
    ; Key
    type := d_type  

    global BServer, boss_Enable, BDispMode
    WinGetPos, X, Y, current_Width, current_Height, %BServer%
    sysget titlebar_height, 4, %BServer%
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }
    ;Center position
    center_x := current_Width*1920/3840
    center_y := (current_Height - titlebar_height)*1080/2160+titlebar_height

    ; When macro not started, not support this action, so judge window active and start status
    ; Send specified count, each with specified interval
    MouseMove, center_x, center_y, 0 ;Initial move to character center right
    Sleep, %interval%
    t_x := 0
    t_y := 0
    current_angle := 0
    loop {
        current_angle := current_angle + angle
        t_x := center_x + ratio*Sin(current_angle * 3.1415926/180)
        t_y := center_y + ratio*Cos(current_angle * 3.1415926/180)
        MouseMove, t_x, t_y, 0 ;
        Send, {%key%}
        if (type = 2)
        {
            Sleep, 50
            Send, {z}
            Sleep, 50
            Send, {z}
            Sleep, 50
            Send, {z}
        }   
        ;MouseClick, left, t_x, t_y
        Sleep, %interval%
        IfWinNotActive,%BServer%
        {
            return
        }
        If (boss_Enable=0) 
        {
            return
        }
    }
}
;----------------------------------------------------------------------
;Get window client area size--------------------------------------------------------
GetWindowWHDetail(ByRef win_width, ByRef win_height, ByRef client_width, ByRef client_height, ByRef border_Width, ByRef border_height, ByRef border_Width_fix, ByRef border_height_fix) 
{
    global BServer
    ; Assume window title or class name is BServer
    WinGet, hWnd, ID, %BServer%

    ; Call GetClientRect to get client area size
    VarSetCapacity(RECT, 16, 0) ; Create a RECT structure
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &RECT)

    ; Extract width and height from RECT structure
    cWidth  := NumGet(RECT, 8, "Int")  ; right - left
    cHeight := NumGet(RECT, 12, "Int") ; bottom - top

    ; Get window total size (including title bar and border)
    WinGetPos, winX, winY, winWidth, winHeight, ahk_id %hWnd%

    ; Get border height and width (use GetSystemMetrics)
    borderWidth  := DllCall("GetSystemMetrics", "Int", 32) ; SM_CXSIZEFRAME (adjustable border width)
    borderHeight := DllCall("GetSystemMetrics", "Int", 33) ; SM_CYSIZEFRAME (adjustable border height)

    ; Output each value
    win_width := winWidth ;2586
    win_height := winHeight ;1500
    client_width := cWidth ;2560
    client_height := cHeight ;1440
    border_Width := borderWidth ;11
    border_height := borderHeight ;11
    border_Width_fix := (winWidth-cWidth-(borderWidth*2))/2 ;2
    border_height_fix := winHeight-cHeight-borderHeight ;49

    /*
    ; Call GetWindowInfo to get window info
    VarSetCapacity(WINDOWINFO, 60, 0) ; WINDOWINFO structure size 60 bytes
    NumPut(60, WINDOWINFO, 0, "UInt") ; Set cbSize
    DllCall("GetWindowInfo", "Ptr", hWnd, "Ptr", &WINDOWINFO)
    ; Extract window border width
    cxWindowBorders := NumGet(WINDOWINFO, 48, "Int") ; cxWindowBorders
    MsgBox, Window border width: %cxWindowBorders%
    */
}

CheckColorExsit(ByRef result, ByRef destx, ByRef desty, pos1x, pos1y, pos2x, pos2y, color_rgb)
{
    /*
    All coord values use relative x,y axis ratio values；
    Color value is AHK rgb format；
    result=0 means not found specified color, =1 means found, =2 means window not active no search performed；
    */
    global BServer, boss_Enable, BDispMode
    IfWinNotActive,%BServer%
    {
        result := 2
        destx := 0
        desty := 0
        return
    }

    WinGetPos, X, Y, current_Width, current_Height, %BServer%
    sysget titlebar_height, 4, %BServer%
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }

    check_pos1x := current_Width * pos1x
    check_pos1y := (current_Height - titlebar_height) * pos1y
    check_pos2x := current_Width * pos2x
    check_pos2y := (current_Height - titlebar_height) * pos2y
    PixelSearch, x, y, check_pos1x,check_pos1y,check_pos2x,check_pos2y,color_rgb,3,Fast RGB 
    if !ErrorLevel {
        result := 1
        destx := x
        desty := y
    }
    Else
    {
        result := 0
        destx := 0
        desty := 0
    }
}    

;Get window client area size--------------------------------------------------------
GetWindowWHDetailTotal(ByRef WHInfo) 
{
    global BServer
    ; Assume window title or class name is BServer
    WinGet, hWnd, ID, %BServer%

    ; Call GetClientRect to get client area size
    VarSetCapacity(RECT, 16, 0) ; Create a RECT structure
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &RECT)

    ; Extract width and height from RECT structure
    cWidth  := NumGet(RECT, 8, "Int")  ; right - left
    cHeight := NumGet(RECT, 12, "Int") ; bottom - top

    ; Get window total size (including title bar and border)
    WinGetPos, winX, winY, winWidth, winHeight, ahk_id %hWnd%

    ; Get border height and width (use GetSystemMetrics)
    borderWidth  := DllCall("GetSystemMetrics", "Int", 32) ; SM_CXSIZEFRAME (adjustable border width)
    borderHeight := DllCall("GetSystemMetrics", "Int", 33) ; SM_CYSIZEFRAME (adjustable border height)

    ; Output each value
    win_width := winWidth ;2586
    win_height := winHeight ;1500
    client_width := cWidth ;2560
    client_height := cHeight ;1440
    border_Width := borderWidth ;11
    border_height := borderHeight ;11
    border_Width_fix := (winWidth-cWidth-(borderWidth*2))/2 ;2
    border_height_fix := winHeight-cHeight-borderHeight ;49

    WHInfo := win_width "," win_height "," client_width "," client_height "," border_Width "," border_height "," border_Width_fix "," border_height_fix
}

;----------------------------------------------------------------------

MoveYourMouse(p_x, p_y, p_type) ;Parameter1-X axis ratio, Parameter2-Y axis ratio, Parameter3- 1Ratio value, 2Pixel value
{   
    global BServer, boss_Enable, BDispMode
    ; When macro not started, not support this action, so judge window active and start status
    ; Send specified count, each with specified interval
    IfWinNotActive,%BServer%
    {
        return
    }

    WinGetPos, X, Y, current_Width, current_Height, %BServer%
    sysget titlebar_height, 4, %BServer%
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }
    ;Center position
    center_x := current_Width*1920/3840
    center_y := (current_Height - titlebar_height)*1080/2160+titlebar_height

    dest_x := 0
    dest_y := 0 
    if (p_type = 1)
    {
        dest_x := current_Width*p_x
        dest_y := (current_Height - titlebar_height)*p_y+titlebar_height
    }
    if (p_type = 2)
    {
        dest_x := p_x
        dest_y := p_y+titlebar_height
    }
    
    MouseMove, dest_x, dest_y, 0
}
MoveYourMouseAnyway(p_x, p_y, p_type) ;Parameter1-X axis ratio, Parameter2-Y axis ratio, Parameter3- 1Ratio value, 2Pixel value
{   
    WinGetPos, X, Y, current_Width, current_Height, A
    sysget titlebar_height, 4
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }
    ;Center position
    center_x := current_Width*1920/3840
    center_y := (current_Height - titlebar_height)*1080/2160+titlebar_height

    dest_x := 0
    dest_y := 0 
    if (p_type = 1)
    {
        dest_x := current_Width*p_x
        dest_y := (current_Height - titlebar_height)*p_y+titlebar_height
    }
    if (p_type = 2)
    {
        dest_x := p_x
        dest_y := p_y+titlebar_height
    }
    
    MouseMove, dest_x, dest_y, 0
}
;----------------------------------------------------------------------
;Loop key--------------------------------------------------------
LoopAnyKey(p_key, p_time, p_type) ;Parameter1-Key, Parameter2-Interval, Parameter3- 1Start, 2Stop
{   
    global BServer, boss_Enable
    ; When macro not started, not support this action, so judge window active and start status
    ; Send specified count, each with specified interval
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
    }

    t_key := ""
    t_time := ""
    t_letter := ","
    if (Instr(p_key, t_letter) > 0)
    {
        t_array := StrSplit(p_key, t_letter, ,2)
        t_key := t_array[1]
        t_time := t_array[2]
    }
    else
    {
        t_key := p_key
        t_time := p_time
    }

    if (p_type = 1)
    {
        ;SetTimer, SendAnyKey_%t_key%, t_time
    }
    if (p_type = 2)
    {
        ;SetTimer, SendAnyKey_%t_key%, off
    }
}
;----------------------------------------------------------------------

;Loop backpack--------------------------------------------------------
LoopBagAction(p_LX, p_LY, p_RX, p_RY, p_line, p_col, p_key, p_time) ;Parameters: Top left X, top left y, bottom right x, bottom right y, row count, column count, key, interval time
{   
    global BServer, boss_Enable
    ; When macro not started, not support this action, so judge window active and start status
    ; Send specified count, each with specified interval
    IfWinNotActive,%BServer%
    {
        EndFunc()
        boss_Enable=0
        Return
    }

    ; 2. Get game window coord and size
    WinGetPos, winX, winY, winW, winH, %BServer%
    ; Get window title bar height
    sysget, titlebar_height, 4, %BServer%
    if (BDispMode = 2)
    {
        titlebar_height := 0
    }
    ; Effective height (exclude title bar)
    effectiveH := winH - titlebar_height

    ; 3. Calculate backpack actual pixel coord (ratio → pixel)
    ; Top left actual coord
    bagTopX := winW * p_LX
    bagTopY := effectiveH * p_LY
    ; Bottom left actual coord
    bagBottomX := winW * p_RX
    bagBottomY := effectiveH * p_RY

    ; 4. Calculate single grid width, height (evenly divided square grid)
    ; Backpack total width/height
    bagWidth := bagBottomX - bagTopX
    bagHeight := bagBottomY - bagTopY
    ; Single grid size
    cellW := bagWidth / p_col
    cellH := bagHeight / p_line

    ; 5. Double loop: traverse each row + each column → grid center
    Loop, % p_line
    {
        IfWinNotActive,%BServer%
        {
            EndFunc()
            boss_Enable=0
            Break
        }
        currentRow := A_Index  ; Current row (start from 1)
        Loop, % p_col
        {
            currentCol := A_Index  ; Current column (start from 1)
            
            ; Calculate current grid center coord
            centerX := bagTopX + (currentCol - 1) * cellW + cellW / 2
            centerY := bagTopY + (currentRow - 1) * cellH + cellH / 2

            ; 6. Mouse move to grid center (relative game window)
            MouseMove, centerX, centerY, 1  ; 0=instant move, can change speed (1~100)
            Sleep, 10  ; Short delay after move, game more stable
            
            ; 7. Send specified key
            Send, {%p_key%}
            Sleep, %p_time%   ; Delay after key, prevent operation too fast
        }
    }
}
;----------------------------------------------------------------------

; #endregion Common Functions END
;--------------------------------------------------------------------------------------------------------------------------------------------

;Control_Colors--------------------------------------------------------
Control_Colors(wParam, lParam, Msg, Hwnd) {
    Static Controls := {}
   If (lParam = "Set") {
      If !(CtlHwnd := wParam + 0)
         GuiControlGet, CtlHwnd, Hwnd, %wParam%
      If !(CtlHwnd + 0)
         Return False
      Controls[CtlHwnd, "CBG"] := Msg + 0
      Controls[CtlHwnd, "CTX"] := Hwnd + 0
      Return True
   }
   ; Critical
   If (Msg = 0x0133 Or Msg = 0x0134 Or Msg = 0x0138) {
      If Controls.HasKey(lParam) {
         If (Controls[lParam].CTX >= 0)
            DllCall("Gdi32.dll\SetTextColor", "Ptr", wParam, "UInt", Controls[lParam].CTX)
         DllCall("Gdi32.dll\SetBkColor", "Ptr", wParam, "UInt", Controls[lParam].CBG)
         Return DllCall("Gdi32.dll\CreateSolidBrush", "UInt", Controls[lParam].CBG)
      }
   }
 }
;----------------------------------------------------------------------


SendString( string )
{
    Len := StrLen(string)  ; Get string length, note Chinese character length is 2, occupies 2 bytes
    Keys := ""                  ; Character sequence to send
    Index := 1                  ; For loop
    Loop
    {
        IsUnicodeChar := false
        Code2 := 0                                             ; Character 2 ASCII code
        Code1 := Asc( SubStr(string, Index, 1) )    ; Get first character ASCII value
        if(Code1 >= 129 && Code1 <= 254 && Index < Len)   ; Judge if Chinese character first character
        {
            Code2 := Asc( SubStr(string, Index+1, 1) )            ; Get second character ASCII value
            if(Code2 >= 64 && Code2 <= 254)        ; If condition true then Chinese character
            {
                IsUnicodeChar := true
                Code1 <<= 8                                  ; First character should be on high 8 bits
                Code1 += Code2                              ; Second character on low 8 bits
            }
            ++Index
        }
        if( IsUnicodeChar )
            Keys .= "{ASC " . Code1 . "}"
        else
        {
            Keys .= "{ASC 0" . Code1 . "}"                ; If non Chinese character, need prefix a 0
            if( Code2 > 0 )
                Keys .= "{ASC 0" . Code2 . "}"
        }
        ++Index
        if(Index > Len)
            Break
    }
    Send {Text} %Keys%
}

SendByClipboard( string, BackupClipBoard = false ) 
{ 
    if(BackupClipBoard) 
        ClipSaved := ClipboardAll     
    ClipBoard := string     
    Send ^v 
    if(BackupClipBoard)     
    { 
        Clipboard := ClipSaved         
        ClipSaved =     
    }
}

;**************************************************************** Embedded Acc.ahk
ROLE_SYSTEM_PUSHBUTTON := 0x2B

Acc_ObjectFromWindow(hwnd, objId := -4)  ; -4 = OBJID_CLIENT
{
    static IID_IAccessible := "{618736E0-3C3D-11CF-810C-00AA00389B71}"

    VarSetCapacity(IID, 16, 0)
    DllCall("ole32\CLSIDFromString", "WStr", IID_IAccessible, "Ptr", &IID)

    if (DllCall("oleacc\AccessibleObjectFromWindow"
        , "Ptr", hwnd
        , "UInt", objId
        , "Ptr", &IID
        , "Ptr*", pacc) = 0)
    {
        return ComObjEnwrap(9, pacc, 1)
    }

    return ""
}

Acc_CollectByRole(acc, role, ByRef out)
{
    try count := acc.accChildCount
    catch
        return

    Loop % count
    {
        try child := acc.accChild(A_Index)
        catch
            continue

        try childRole := child.accRole(0)
        catch
            continue

        if (childRole = role)
            out.Push(child)

        ; Continue recursive downward
        Acc_CollectByRole(child, role, out)
    }
}

Acc_GetWindowFromAcc(acc)
{
    try
    {
        VarSetCapacity(hwnd, A_PtrSize)
        DllCall("oleacc\WindowFromAccessibleObject"
            , "Ptr", ComObjValue(acc)
            , "Ptr*", hwnd)
        return hwnd
    }
    catch
    {
        return 0
    }
}
;****************************************************************