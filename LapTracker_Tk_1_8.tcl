package require Tk
#
#Global variable for text window and output
set sep +-[string repeat - 10]-+-[string repeat - 10]-+-[string repeat - 10]-+-[string repeat - 10]-+-[string repeat - 10]-+-[string repeat - 10]-+
set mphheader [format "| %-*s | %-*s | %-*s | %-*s | %-*s | %-*s |" 10 "Car" 10 "LC" 10 "LT" 10 "MPH" 10 "FT" 10 "FMPH"]
set kmhheader [format "| %-*s | %-*s | %-*s | %-*s | %-*s | %-*s |" 10 "Car" 10 "LC" 10 "LT" 10 "KMH" 10 "FT" 10 "FKMH"]
set idMap ""
set cars ""
set comInput 2
set tcpPort 65000
set comNum 1
set comBaud 9600
set comBits 8
set comControl n
set comParity 1
#
proc main {} {
variable comInput
.racevars.statuslight create oval 10 10 30 30 -fill LimeGreen
clearracedata
.racestatus delete 1.0 end
.racestatus insert 1.0 "Start your engines!!!"
switch $comInput {
	0 {server start}
	1 {open_com}
	2 {keyboard_bind}
}
}
#
proc server {state} {
variable serverTCP65000
variable tcpPort
	switch $state {
		start	{set serverTCP65000 [socket -server race $tcpPort]}
		stop	{close $serverTCP65000}
	}
}
#
proc open_com {} {
variable comNum
variable comBaud 9600
variable comBits 8
variable comParity 1
variable comControl n
    variable com [open "COM$comNum:" r+]
    fconfigure $com -mode "$comBaud,$comControl,$comBits,$comParity" -blocking 0 -buffering none -translation binary
    fileevent $com readable [list rd_chid $com]
}
#
proc rd_chid {chid} {
    set msg [read $chid]
    race $msg null null
}
#
proc keyboard_bind {} {
bind .racestatus <Key> {
	if {{%K} == "q"} {
		stoprace
	} else {
		race %K null null
	}
}
}
#
proc race {chan addr port args} {
variable sep
variable mphheader
variable kmhheader
variable UOL
variable comInput
#inbound id of transponder
switch $comInput {
0 {set x [gets $chan]}
1 {set x $chan}
2 {set x $chan}
}
#replace with user defined ID
set x [replaceID $x]
#pull in the global array for the specific  racer
variable $x
set cars [indexRacers $x]
#
if {[array exists $x]} {
	set ${x}(diff)	[calcDiff [set ${x}(ticn)]]
	set ${x}(ticn) 	[lapTic 	[set ${x}(ticn)]]
	set ${x}(LC) 	[lapCount 	[set ${x}(LC)	]]
	set ${x}(LT) 	[lapTime 	[set ${x}(diff)]]
	set ${x}(MPH) 	[calcMPH 	[set ${x}(LT)	]]
	set ${x}(KMH) 	[calcKMH 	[set ${x}(LT)	]]
	set ${x}(FMPH) 	[calcFMPH 	[set ${x}(MPH)] [set ${x}(FMPH)]]
	set ${x}(FKMH) 	[calcFKMH 	[set ${x}(KMH)] [set ${x}(FKMH)]]
	set ${x}(FT) 	[calcFT [set ${x}(LT)] [set ${x}(FT)]]
	switch $UOL {
		Feet {append ${x}(log) \n[format "| %10.10s | %10.10s | %10.10s | %10.10s | %10.10s | %10.10s |" $x [set ${x}(LC)] [set ${x}(LT)] [set ${x}(MPH)] [set ${x}(FT)] [set ${x}(FMPH)]]}
		Meters {append ${x}(log) \n[format "| %10.10s | %10.10s | %10.10s | %10.10s | %10.10s | %10.10s |" $x [set ${x}(LC)] [set ${x}(LT)] [set ${x}(KMH)] [set ${x}(FT)] [set ${x}(FKMH)]]}
		}
	} else {
#Stage first lap globals, list cars, and start log files
		array set $x {ticn 0 LC 0 LT 0 MPH 0 diff 0 FT 0 FMPH 0 KMH 0 FKMH 0 log ""}
		set ${x}(ticn) 	[lapTic 	[set ${x}(ticn)]]
		set racetime [clock format [clock seconds] -format "%y-%m-%d-%y_%H%M%S"]
		switch $UOL {
		Feet {set ${x}(log) "$racetime\n$sep\n$mphheader\n$sep"}
		Meters {set ${x}(log) "$racetime\n$sep\n$kmhheader\n$sep"}
		}
	}
#Print leader board to screen
printscreen $x
switch $comInput {
	0 {close $chan}
}
}

proc replaceID {id} {
variable idMap
set index [lsearch $idMap $id]
if {$index >= 0} {
set id [lindex $idMap [expr {$index + 1}]]
}
return $id
}

proc indexRacers {newcar} {
	variable cars
	if {[lsearch $cars $newcar] < 0} {
		lappend cars $newcar
		} else {
		return $cars
		}
	return $cars
}

proc calcDiff {ticn} {
	set tic [clock milliseconds]
	set diff [expr $tic - $ticn]
	return $diff
}

proc lapTic {ticn} {
	set tic [clock milliseconds]
	set ticn $tic
	return $ticn
}

proc lapTime {diff} {
	set LT [format %2.3f [expr $diff.0/1000]]
	return $LT
}

proc lapCount {LC} {
	incr LC 1
	return $LC
}

proc calcMPH {LT} {
	variable tracklength
	set MPH [format %3.2f [expr ($tracklength.0/5280) / ($LT/3600)]]
	return $MPH
}

proc calcKMH {LT} {
	variable tracklength
	set KMH [format %3.2f [expr ($tracklength.0/$LT) * 3.6]]
	return $KMH
}

proc calcFMPH {MPH FMPH} {
	if {$MPH > $FMPH} {
		set FMPH $MPH
	}
	return $FMPH
}

proc calcFKMH {KMH FKMH} {
	if {$KMH > $FKMH} {
		set FKMH $KMH
	}
	return $FKMH
}

proc calcFT {LT FT} {
	if {$FT == 0} {
		set FT $LT		
	} elseif {$LT < $FT} {
		set FT $LT
	}
	return $FT
}

proc printscreen {x} {
variable cars
variable mphheader
variable kmhheader
variable racelength
variable racestart
variable racestop
variable UOL
variable UOT
variable sep
set output ""
	foreach line $cars {
		variable $line
		set car $line
		switch $UOL {
			Feet {lappend output [format "| %10.10s | %10.10s | %10.10s | %10.10s | %10.10s | %10.10s |" $car [set ${line}(LC)] [set ${line}(LT)] [set ${line}(MPH)] [set ${line}(FT)] [set ${line}(FMPH)]]}
			Meters {lappend output [format "| %10.10s | %10.10s | %10.10s | %10.10s | %10.10s | %10.10s |" $car [set ${line}(LC)] [set ${line}(LT)] [set ${line}(KMH)] [set ${line}(FT)] [set ${line}(FKMH)]]}
		}
	 }
set output [lsort -decreasing -integer -index 3 $output]
set leader [lindex $output 0]
set leaderLT [lindex $leader 5]
set leaderLC [lindex $leader 3] 
set textline 4
.racestatus delete 1.0 end
switch $UOL {
	Feet {.racestatus insert 1.0 "$sep\n$mphheader\n$sep\n"}
	Meters {.racestatus insert 1.0 "$sep\n$kmhheader\n$sep\n"}
}
	foreach line $output {
	.racestatus insert $textline.0 $line\n
	.racestatus tag configure black -foreground black
	.racestatus tag configure green -foreground green
	.racestatus tag configure red -foreground red
	set racerLT [lindex $line 5]
	set racerLC [lindex $line 3]
	if {$racerLC == $leaderLC} {
	if {$racerLT == $leaderLT} {
		.racestatus tag add black $textline.27 $textline.38
	} elseif {$racerLT == 0} {
		.racestatus tag add black $textline.27 $textline.38
	} elseif {$racerLT < $leaderLT} {
		.racestatus tag add green $textline.27 $textline.38
	} else {
		.racestatus tag add red $textline.27 $textline.38
	}

	}
	
incr textline
}
.racestatus insert $textline.0 $sep\n
incr textline
#
switch $UOT {
	Laps {
		set leadcar [lindex $leader 1]
			if {$racelength > [lindex $leader 3]} {
				.racestatus insert $textline.0 "\n\n$leadcar is the leader"
			} elseif {$racelength == 0} {
				.racestatus insert $textline.0 "\n\nBoogity boogity lets go racing!"
			} else {
				.racestatus insert $textline.0 "\n\n$leadcar is the winner!!!!\n"
			stoprace
			}
		}
	Minutes {
		set leadcar [lindex $leader 1]
		if {[info exists racestart]} {
				if {[clock seconds] > $racestop} {
					.racestatus insert $textline.0 "\n\n$leadcar is the winner!!!!\n"
					stoprace
				}
			set timeleft [expr {$racestop - [clock seconds]}]
				if {$timeleft > 0} {
					.racestatus insert $textline.0 "\n\n$leadcar is the leader\n"
					incr textline
					.racestatus insert $textline.0 "$timeleft seconds left to race!"
				}
		} else {
			variable racestart [clock seconds]
			variable racestop [clock add $racestart $racelength minutes]
			.racestatus insert $textline.0 "\n\nBoogity boogity lets go racing!"
			}
		}
	}
}

proc stoprace {} {
variable comInput
variable com
.racevars.statuslight create oval 10 10 30 30 -fill Red
switch $comInput {
	0 {server stop}
	1 {close $com}
	2 {bind .racestatus <Key> break}
}
racesummary
}

proc racesummary {} {
variable cars
variable mphheader
variable kmhheader
variable sep
variable UOL
foreach line $cars {
	variable $line
	set log [open $line.txt a+]
	set carlog [set ${line}(log)]
	puts $log "$carlog\n$sep"
	close $log
}
set racetime [clock format [clock seconds] -format "%y-%m-%d-%y_%H%M%S"]
set racesum [open _RaceSummary_.txt a+]
set data ""
foreach line $cars {
	set file [open $line.txt r]
	set laps [read $file]
	set laps [split $laps \n]
	set lapcount [llength $laps]
	lappend data "[lindex $laps [expr {$lapcount - 3}]]"
	close $file
}
switch $UOL {
Feet {puts $racesum  "$racetime\n$sep\n$mphheader\n$sep"}
Meters {puts $racesum  "$racetime\n$sep\n$kmhheader\n$sep"}
}
set sortlaps [lsort -decreasing -integer -index 3 $data]
foreach line $sortlaps {
	set car [lindex $line 1]
	set LC [lindex $line 3]
	set LT [lindex $line 5]
	set FT [lindex $line 9]
	switch $UOL {
	Feet {
			set MPH [lindex $line 7]
			set FMPH [lindex $line 11]
			puts $racesum [format "| %10.10s | %10.10s | %10.10s | %10.10s | %10.10s | %10.10s |" $car $LC $LT $MPH $FT $FMPH]
			}
	Meters {
			set KMH [lindex $line 7]
			set FKMH [lindex $line 11]
			puts $racesum [format "| %10.10s | %10.10s | %10.10s | %10.10s | %10.10s | %10.10s |" $car $LC $LT $KMH $FT $FKMH]
			}
	}
}
puts $racesum $sep
close $racesum
}

proc clearracedata {} {
variable cars
foreach car $cars {
	variable $car
	array unset $car
}
variable cars ""
.racestatus delete 1.0 end
}

proc assignracers {} {
	tk::toplevel .idfile
	grid [text .idfile.ids -width 40 -height 10] -column 0 -row 0 -sticky nsew
	if {[catch {set idfile [open idfile.txt r]}] < 1 } {
		set listofids [read $idfile]
		close $idfile
		.idfile.ids insert 1.0 $listofids
	}
	grid [button .idfile.cancel -text "Cancel" -command {destroy .idfile}] -column 2 -row 1 -sticky new
	grid [button .idfile.save -text "Save" -command {variable idMap [.idfile.ids get 1.0 end]; destroy .idfile}] -column 1 -row 1 -sticky new
}

proc about {} {
	tk::toplevel .about
	grid [text .about.about -width 40 -height 10] -column 0 -row 0 -sticky nsew
	.about.about insert 1.0 "This is Laptracker, the best free\nlaptracker out there...\nEnjoy!!!"
}

proc comSettings {} {
tk::toplevel .comsettings
label	.comsettings.lable			-text "COM Settings:"
label	.comsettings.baudlable 		-text "Baud:"
label	.comsettings.bitslable		-text "Bits:"
label	.comsettings.controllable	-text "Control:"
label	.comsettings.paritylable	-text "Parity:"

entry	.comsettings.baud 			-width 6	-textvariable comBaud
entry	.comsettings.bits			-width 6	-textvariable comBits
entry	.comsettings.control		-width 6	-textvariable comControl
entry	.comsettings.parity			-width 6	-textvariable comParity
button	.comsettings.ok -text "Ok" -command {destroy .comsettings}

grid	.comsettings.lable			-column 0 -row 0 -columnspan 2
grid	.comsettings.baudlable 		-column 0 -row 1
grid	.comsettings.bitslable		-column 0 -row 2
grid	.comsettings.controllable	-column 0 -row 3
grid	.comsettings.paritylable	-column 0 -row 4
grid	.comsettings.baud 			-column 1 -row 1
grid	.comsettings.bits	        -column 1 -row 2
grid	.comsettings.control        -column 1 -row 3
grid	.comsettings.parity	        -column 1 -row 4
grid	.comsettings.ok				-column 1 -row 5
}

wm title . "LapTracker"
wm geometry . 800x400
ttk::frame .racevars

option add *tearOff 0


menu .menubar
. configure -menu .menubar

menu .menubar.file
menu .menubar.edit
menu .menubar.help

.menubar add cascade -menu .menubar.file -label File
.menubar add cascade -menu .menubar.edit -label Edit
.menubar add cascade -menu .menubar.help -label Help
.menubar.file add command -label "Start Race" -command main	
.menubar.file add command -label "Stop Race" -command stoprace
.menubar.file add command -label "Close" -command {racesummary; exit}
.menubar.edit add command -label "Assign Racers" -command assignracers
.menubar.edit add command -label "COM Settings" -command comSettings
.menubar.help add command -label "About" -command about		

radiobutton .racevars.tcp -text "TCP" -variable comInput -value 0
radiobutton .racevars.com -text "COM" -variable comInput -value 1
radiobutton .racevars.key -text "KEYBOARD" -variable comInput -value 2
entry	.racevars.comnum -width 6 -textvariable comNum
entry	.racevars.tcpport -width 6 -textvariable tcpPort
label	.racevars.racelengthlable -text "Race Length:"
spinbox	.racevars.unitoftime -width 8 -from 1.0 -to 2.0 -textvariable UOT -wrap 1
entry	.racevars.racelength -width 10 -textvariable racelength
label	.racevars.tracklengthlable -text "Track Length:"
spinbox .racevars.unitoflength -width 8 -from 1.0 -to 2.0 -textvariable UOL -wrap 1
entry	.racevars.tracklength -width 10 -textvariable tracklength
button	.racers -text "Racers" -command assignracers
button	.clearracedatabutton -text "Clear Race Data" -command clearracedata
button	.startrace -text "Start Race" -command main
button	.stoprace -text "Stop Race" -command stoprace
button	.close -text "Close" -command exit
label	.racestatuslabel -text "Race Status"
text	.racestatus  -width 81 -height 15
scrollbar .racestatussb -orient vertical -command ".racestatus yview"
canvas	.racevars.statuslight -width 40 -height 40
.racevars.statuslight create oval 10 10 30 30 -fill Red

grid columnconfigure . {0 1 2 3 4} -weight 1
grid rowconfigure . {0 1 2 3 4} -weight 1

grid .racevars		 				-column 0 -row 0 -columnspan 2 -rowspan 1
grid .racevars.tcp					-column 0 -row 1 -sticky w
grid .racevars.com					-column	4 -row 1 -sticky w
grid .racevars.tcpport				-column	2 -row 1 -sticky w
grid .racevars.comnum				-column	5 -row 1 -sticky w
grid .racevars.racelengthlable		-column 3 -row 0 -sticky e
grid .racevars.unitoftime			-column 4 -row 0 -sticky w
grid .racevars.key					-column 7 -row 1 -sticky w
grid .racevars.racelength			-column 5 -row 0 -sticky w
grid .racevars.tracklengthlable		-column 6 -row 0 -sticky e
grid .racevars.unitoflength			-column 7 -row 0 -sticky w
grid .racevars.tracklength			-column 8 -row 0 -sticky w
grid .racevars.statuslight			-column 9 -row 1 -sticky e

grid .racers						-column 3 -row 0 -sticky ew
grid .clearracedatabutton			-column 3 -row 1 -sticky ew
grid .startrace						-column 3 -row 2 -sticky ew
grid .stoprace						-column 3 -row 3 -sticky ew
grid .racestatuslabel 				-column 0 -row 0 -columnspan 2 -sticky sew
grid .racestatus					-column 0 -row 1 -columnspan 2 -rowspan 4 -sticky nsew
grid .racestatussb					-column 2 -row 1 -rowspan 4 -sticky nsw
grid .close							-column 3 -row 4 -sticky ew

.racevars.unitoftime configure -values {Laps Minutes}
.racevars.unitoflength configure -values {Feet Meters} 
.racevars.racelength insert 0 50
.racevars.tracklength insert 0 300