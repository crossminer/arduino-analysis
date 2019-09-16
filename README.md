# Simple Arduino analysis in Rascal

Some basic metrics on C/C++/Arduino code implemented in Rascal.

## Eclipse Setup

  - Install an Eclipse IDE for RCP and RAP Developers suitable for your platform: https://www.eclipse.org/downloads/packages/release/2019-03/r/eclipse-ide-rcp-and-rap-developers
  - In Eclipse, install [CDT](https://www.eclipse.org/cdt/), [Rascal](https://www.rascal-mpl.org/), and [CLAIR](https://github.com/cwi-swat/clair) (C Language Analysis in Rascal):
    - Navigate to `Help -> Install New Software...` and install CDT, Rascal, and CLAIR using the following update sites:
      - CDT: http://download.eclipse.org/tools/cdt/releases/9.7 (select `C/C++ Development Tools SDK`)
      - Rascal: https://update.rascal-mpl.org/unstable/ (select `The Rascal MetaProgramming Language`)
      - CLAIR: https://update.rascal-mpl.org/libs/ (select `clair_feature`)

## Building and running the project with Maven

  - Build

```
$ cd RascalArduino
$ mvn clean package

[output JAR stored in RascalArduino/target/arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar]
```

  - Run

```
$ java -jar RascalArduino/target/arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar /path/to/a/Sketch/file.cpp
```

  - Example output

```
$ java -jar RascalArduino/target/arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar target/arduino-analysis-0.0.1-SNAPSHOT-jar-with-dependencies.jar /home/dig/repositories/RadioHead/examples/rf95/rf95_reliable_datagram_server/rf95_reliable_datagram_server.pde

Computing commentRatio on /home/dig/repositories/RadioHead/examples/rf95/rf95_reliable_datagram_server/rf95_reliable_datagram_server.pde...
Missed entry for member visibility?
usingDeclaration(
  [],
  qualifiedName(
    [name(
        "Print",
        src=|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/HardwareSerial.h|(4591,5))],
    name(
      "write",
      src=|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/HardwareSerial.h|(4598,5)),
    src=|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/HardwareSerial.h|(4591,12),
    decl=|cpp+usingDeclaration:///HardwareSerial/write|),
  src=|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino/HardwareSerial.h|(4585,19),
  decl=|cpp+usingDeclaration:///HardwareSerial/write|)
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

## Importing the project in Eclipse

  - Clone this repository somewhere on your system
    - `$ git clone https://github.com/tdegueul/arduino-analysis`
  - In Eclipse, `File -> Import -> Existing Projects into Eclipse` and select the `RascalArduino` directory in your local clone
 
## Usage

  - The absolute paths to the standard C++ library and the Arduino-specific libraries must be customized first. Open the file `RascalArduino/src/arduino/Metrics.rsc` and edit the paths at the beginning in the method `cppM3(loc)`, after cloning the corresponding GitHub repositories locally:
  ```
  // Customize those according to your OS/setup
  list[loc] localCP = [
    |file:///usr/include|,
    |file:///usr/include/c++/8.2.1|,
    |file:///usr/include/c++/8.2.1/tr1|,
    |file:///usr/include/linux/|,
    |file:///usr/include/c++/8.2.1/x86_64-pc-linux-gnu/|
  ];

  // Those ones are Arduino-specific. Sources:
  //   - https://github.com/arduino/ArduinoCore-avr
  //   - https://github.com/PaulStoffregen/RadioHead
  //   - https://github.com/PaulStoffregen/SPI/
  list[loc] arduinoCP = [
   	|file:///usr/avr/include/|,
   	|file:///home/dig/repositories/SPI|,
   	|file:///home/dig/repositories/RadioHead|,
   	|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino|,
   	|file:///home/dig/repositories/ArduinoCore-avr/variants/standard/|
  ];
  ```
  - Right-click the `RascalArduino` project in Eclipse and select `Open Rascal Console`
  - In the Rascal console (`>` denotes the Rascal prompt):
    - `> import arduino::Metrics;`
    - `> import lang::cpp::M3;`
    - `> m = cppM3(|file:///absolute/path/to/a/cpp/File.cpp|);` (note the triple `///` after `file:`)
  - To inspect the relation of the resulting M3 model `m`:
    - `> m.uses;`
    - `> m.includeDirectives;`
    - etc.
  - The module `arduino::Metrics` contains some pre-defined metrics. Have a look at the [Metrics.rsc](RascalArduino/src/arduino/Metrics.rsc) to see the list. Then, for instance:
    - `> commentRatio(m);`
    - `> functions(m);`
    - `> typedFunctions(m);`
    
