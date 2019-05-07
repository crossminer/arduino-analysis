# Simple Arduino analysis in Rascal

Some basic metrics on C/C++/Arduino code implemented in Rascal.

## Eclipse Setup

  - Install an Eclipse IDE for RCP and RAP Developers suitable for your platform: https://www.eclipse.org/downloads/packages/release/2019-03/r/eclipse-ide-rcp-and-rap-developers
  - In Eclipse, install [CDT](https://www.eclipse.org/cdt/), [Rascal](https://www.rascal-mpl.org/), and [CLAIR](https://github.com/cwi-swat/clair) (C Language Analysis in Rascal):
    - Navigate to `Help -> Install New Software...` and install CDT, Rascal, and CLAIR using the following update sites:
      - CDT: http://download.eclipse.org/tools/cdt/releases/9.7 (select `C/C++ Development Tools SDK`)
      - Rascal: https://update.rascal-mpl.org/unstable/ (select `The Rascal MetaProgramming Language`)
      - CLAIR: https://update.rascal-mpl.org/libs/ (select `clair_feature`)

## Installation

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
    
