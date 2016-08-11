# laptrackertk
LapTrackerTK is a full featured RC Cap Lap Tracking software.

Before you begin:
LapTrackerTK can be configured to use a TCP connection (defaults to port 65000), Serial COM Ports (defaults to COM 1), or Keyboard Input.
TCP port and COM port are configurable on the main window. Other COM port settings are available in the menu bar "Edit>COM Settings".

LapTrackerTK will listen on your configured port, and is expecting standard text or numbers. Received data will be treated as a racers name and will be used in the race database. When Keyboard input is selected only a single character is used (I simply assign a number to a car 1-9). Also, pressing "q" will also end the race when using keyboard input.

If you want to translate a received text to something else, press "Racers" and add the expected text, and what you'd like to translate it to using the following format.

Alternatively, create a file called idfile.txt in the same directory as the program with the same format: The text should be space delimited as such:

14028987 MYNAME
14074873 YOURNAME
14089879 BADBEEF

Now if the program receives the numbers, they will be translated to the name specified. This is handy if your sending simple 1-9 keyboard strokes, mac-addresses, or a chip-id of the ESP8266 (see LapTrackerTK-wiki for information on that project).

Select the number of laps to run, or the duration of time to run in minutes.

A track length must be specified to receive accurate speeds. If Feet is chosen the speed is displayed in Miles Per Hour.
If Meters is chosen then the speed is displayed in Kilometers Per Hour.

Pressing "Start Race" will begin the race and the program will start and attempt to listen on your configured port. Keyboard input is only accepted into the large text window, you may need to click into the white space to set focus into the "Race Status" window.
As the data is received it is displayed in the "Race Status" window.

To stop the race at any time press "Stop Race".

When the race is over, web files are generated for each racer and a summary of the race. All files are timestamped, and are located in the same directory as the program.

To start a new race, first press "Clear Race Data" or close the program, and re-launch it.

Enjoy!

Troubleshooting:
TCP - Use Telnet to connect to your PC over the port configured. Windows CLI or a tool like PuTTY will work, if you don't get an error immediately, your connected and can type some characters to send them to LapTrackerTK. 
Example: "telnet 127.0.0.1 65000" and send standard text.

If you don't get what you'd expect check the local firewall to see if its turned on as it might be blocking TCP on your configured port (defaults to 65000). Also PuTTY doesn't always seem to send clean text, try using Windows CMD instead.

COM - You must have an available COM port on your PC. LapTrackerTK will error immediately if the COM port is in use or unavailable.
First check that your COM port is available and not in use.
If LapTrackerTK appears to start a race, but the characters are all messed up, your COM baud rate is probability wrong.
Try connecting another PC with a Serial connect to your LapTrackerTK PC and send standard text.
Try downloading a COM port emulator to (virtual COM driver) and send data from PuTTY. Several free version on the web.

KEYBOARD - Keyboard input is pretty dummy proof but if you find that your keystrokes are not being picked up, click into the empty white space in the "Race Status" window and try your keystrokes again.
If you are finding that the race is ending prematurely be sure that your not sending a "q" as this is a trigger to stop the race.
Keyboard input was intended for simple 1-9 digit input, but any character is accepted with "q" quitting ending the race.
Reaching the end of the configured number of laps or time will also end the race as normal. 
