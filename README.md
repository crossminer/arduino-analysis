# Simple Arduino analysis in Rascal

## Installation

  - Install an Eclipse IDE for RCP and RAP Developers suitable for your platform: https://www.eclipse.org/downloads/packages/release/2018-12/r/eclipse-ide-rcp-and-rap-developers
  - In Eclipse, install [Rascal](https://www.rascal-mpl.org/) and [CLAIR](https://github.com/cwi-swat/clair) (C Language Analysis in Rascal):
    - Navigate to `Help -> Install New Software...` and install Rascal and CLAIR using the following update sites:
      - Rascal: https://update.rascal-mpl.org/unstable/
      - CLAIR: https://update.rascal-mpl.org/libs/ (select the `clair_feature`)
  - Clone this repository somewhere on your system
    - `$ git clone https://github.com/tdegueul/arduino-analysis`
  - In Eclipse, `File -> Import -> Existing Projects into Eclipse` and select the `RascalArduino` directory in your local clone
 
## Usage

  - The absolute paths to the standard C++ library and the Arduino-specific libraries must be customized first. Open the file `RascalArduino/src/ArduinoMetrics.rsc` and edit the paths at the beginning in the method `cppM3(loc)`
  - Right-click the `RascalArduino` project in Eclipse and select `Open Rascal Console`
  - In the Rascal console:
    - `> import ArduinoMetrics;`
    - `> m = cppM3(|file:///absolute/path/to/a/cpp/File.cpp|);`
  - To inspect the relation of the resulting M3 model `m`:
    - `> m.uses;`
    - `> m.includeDirectives;`
    - etc.
  - To invoke a simple analysis:
    - `> includes(m);`
    
