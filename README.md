# Simple Arduino analysis in Rascal

Some basic metrics on C/C++/Arduino code implemented in Rascal.

## Building and running the project with Maven

```
$ cd RascalArduino
$ mvn clean package
$ cp target/arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar .
```

### Arduino metrics
Invoking the JAR with one argument will run all the function tagged with the `@metric` annotation in [Metrics.rsc](https://github.com/tdegueul/arduino-analysis/blob/master/RascalArduino/src/arduino/Metrics.rsc):

```
$ java -jar arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar /home/dig/repositories/RadioHead/examples/rf95/rf95_reliable_datagram_server/rf95_reliable_datagram_server.pde
Computing commentRatio on /home/dig/repositories/RadioHead/examples/rf95/rf95_reliable_datagram_server/rf95_reliable_datagram_server.pde...
        result = 0.6640440598

Computing includes on /home/dig/repositories/RadioHead/examples/rf95/rf95_reliable_datagram_server/rf95_reliable_datagram_server.pde...
        result = {<|cpp+systemInclude:///avr/eeprom.h|,|file:///usr/avr/include/avr/eeprom.h|>,<|cpp+systemInclude:///RHDatagram.h|,|file:///home/dig/repositories/RadioHead/RHDatagram.h|>,<|cpp+systemInclude:///RH_RF95.h|,|file:///home/dig/repositories/RadioHead/RH_RF95.h|>,<|cpp+include:///Print.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/Print.h|>,<|cpp+systemInclude:///ctype.h|,|file:///usr/avr/include/ctype.h|>,<|cpp+systemInclude:///stdint.h|,|file:///usr/avr/include/stdint.h|>,<|cpp+systemInclude:///stdint.h|,|unresolved:///|>,<|cpp+systemInclude:///SPI.h|,|file:///home/dig/repositories/SPI/SPI.h|>,<|cpp+systemInclude:///SPI.h|,|unresolved:///|>,<|cpp+systemInclude:///avr/version.h|,|file:///usr/avr/include/avr/version.h|>,<|cpp+systemInclude:///math.h|,|file:///usr/avr/include/math.h|>,<|cpp+systemInclude:///math.h|,|unresolved:///|>,<|cpp+systemInclude:///inttypes.h|,|file:///usr/avr/include/inttypes.h|>,<|cpp+systemInclude:///Arduino.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/Arduino.h|>,<|cpp+systemInclude:///Arduino.h|,|unresolved:///|>,<|cpp+include:///HardwareSerial.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/HardwareSerial.h|>,<|cpp+systemInclude:///stdio.h|,|file:///usr/avr/include/stdio.h|>,<|cpp+systemInclude:///RHGenericSPI.h|,|file:///home/dig/repositories/RadioHead/RHGenericSPI.h|>,<|cpp+systemInclude:///RHGenericDriver.h|,|file:///home/dig/repositories/RadioHead/RHGenericDriver.h|>,<|cpp+systemInclude:///stdbool.h|,|unresolved:///|>,<|cpp+include:///Stream.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/Stream.h|>,<|cpp+systemInclude:///RHHardwareSPI.h|,|file:///home/dig/repositories/RadioHead/RHHardwareSPI.h|>,<|cpp+include:///binary.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/binary.h|>,<|cpp+systemInclude:///avr/portpins.h|,|file:///usr/avr/include/avr/portpins.h|>,<|cpp+systemInclude:///string.h|,|file:///usr/avr/include/string.h|>,<|cpp+systemInclude:///string.h|,|unresolved:///|>,<|cpp+systemInclude:///stdarg.h|,|unresolved:///|>,<|cpp+systemInclude:///avr/fuse.h|,|file:///usr/avr/include/avr/fuse.h|>,<|cpp+systemInclude:///avr/interrupt.h|,|file:///usr/avr/include/avr/interrupt.h|>,<|cpp+systemInclude:///avr/interrupt.h|,|unresolved:///|>,<|cpp+include:///pins_arduino.h|,|file:///home/dig/repositories/ArduinoCore-avr/variants/standard/pins_arduino.h|>,<|cpp+systemInclude:///util/delay.h|,|file:///usr/avr/include/util/delay.h|>,<|cpp+systemInclude:///util/delay.h|,|unresolved:///|>,<|cpp+include:///Printable.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/Printable.h|>,<|cpp+systemInclude:///avr/io.h|,|unresolved:///|>,<|cpp+systemInclude:///avr/io.h|,|file:///usr/avr/include/avr/io.h|>,<|cpp+include:///WString.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/WString.h|>,<|cpp+include:///Arduino.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/Arduino.h|>,<|cpp+systemInclude:///RadioHead.h|,|file:///home/dig/repositories/RadioHead/RadioHead.h|>,<|cpp+systemInclude:///avr/lock.h|,|file:///usr/avr/include/avr/lock.h|>,<|cpp+systemInclude:///avr/common.h|,|file:///usr/avr/include/avr/common.h|>,<|cpp+systemInclude:///avr/sfr_defs.h|,|file:///usr/avr/include/avr/sfr_defs.h|>,<|cpp+systemInclude:///RHSPIDriver.h|,|file:///home/dig/repositories/RadioHead/RHSPIDriver.h|>,<|cpp+include:///WCharacter.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/WCharacter.h|>,<|cpp+systemInclude:///RHReliableDatagram.h|,|file:///home/dig/repositories/RadioHead/RHReliableDatagram.h|>,<|cpp+systemInclude:///avr/pgmspace.h|,|file:///usr/avr/include/avr/pgmspace.h|>,<|cpp+systemInclude:///stdlib.h|,|file:///usr/avr/include/stdlib.h|>,<|cpp+systemInclude:///stddef.h|,|file:///usr/include/linux/stddef.h|>,<|cpp+systemInclude:///stddef.h|,|unresolved:///|>,<|cpp+include:///USBAPI.h|,|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/USBAPI.h|>,<|cpp+systemInclude:///util/delay_basic.h|,|file:///usr/avr/include/util/delay_basic.h|>}
        
Computing allSketchSize on /home/dig/repositories/RadioHead/examples/rf95/rf95_reliable_datagram_server/rf95_reliable_datagram_server.pde...
        result = 13

Computing missingDeps on /home/dig/repositories/RadioHead/examples/rf95/rf95_reliable_datagram_server/rf95_reliable_datagram_server.pde...
        result = {|cpp+systemInclude:///math.h|,|cpp+systemInclude:///Arduino.h|,|cpp+systemInclude:///stdint.h|,|cpp+systemInclude:///SPI.h|,|cpp+systemInclude:///stdbool.h|,|cpp+systemInclude:///string.h|,|cpp+systemInclude:///util/delay.h|,|cpp+systemInclude:///avr/io.h|,|cpp+systemInclude:///stddef.h|,|cpp+systemInclude:///avr/interrupt.h|,|cpp+systemInclude:///stdarg.h|}

Computing sketchSize on /home/dig/repositories/RadioHead/examples/rf95/rf95_reliable_datagram_server/rf95_reliable_datagram_server.pde...
        result = 0
```

### Fork analysis
Invoking the JAR with two arguments will run fork analysis between the two provided modules:

```
$ java -jar arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar /home/dig/sandbox/WifiManager/orig/WiFiManager.cpp /home/dig/sandbox/WifiManager/fork/WiFiManager.cpp
Comparing WiFiManager.cpp <-> WiFiManager.cpp
        Perfect matches: 32 declarations (76.1904761900%) have been perfectly matched in the fork.
Score: 0.6530612

$ java -jar arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar /home/dig/sandbox/SX1272/orig/libraries/SX1272/WaspSX1272.cpp /home/dig/sandbox/SX1272/fork/Arduino/libraries/SX1272/src/SX1272.cpp
Comparing WaspSX1272.cpp <-> SX1272.cpp
        Perfect matches: 66 declarations (67.3469387800%) have been perfectly matched in the fork.
Score: 0.528

$ java -jar arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar /home/dig/sandbox/IRremote/orig/IRremoteInt.h /home/dig/sandbox/IRremote/fork/IRremoteInt.h
Comparing IRremoteInt.h <-> IRremoteInt.h
        Perfect matches: 8 declarations (100.%) have been perfectly matched in the fork.
Score: 1.0
```

## Eclipse Setup

  - Install an Eclipse IDE for RCP and RAP Developers suitable for your platform: https://www.eclipse.org/downloads/packages/release/2019-03/r/eclipse-ide-rcp-and-rap-developers
  - In Eclipse, install [CDT](https://www.eclipse.org/cdt/), [Rascal](https://www.rascal-mpl.org/), and [CLAIR](https://github.com/cwi-swat/clair) (C Language Analysis in Rascal):
    - Navigate to `Help -> Install New Software...` and install CDT, Rascal, and CLAIR using the following update sites:
      - CDT: http://download.eclipse.org/tools/cdt/releases/9.7 (select `C/C++ Development Tools SDK`)
      - Rascal: https://update.rascal-mpl.org/unstable/ (select `The Rascal MetaProgramming Language`)
      - CLAIR: https://update.rascal-mpl.org/libs/ (select `clair_feature`)

