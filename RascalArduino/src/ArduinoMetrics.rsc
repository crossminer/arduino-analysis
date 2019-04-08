module ArduinoMetrics

import analysis::m3::Core;
import lang::cpp::AST;
import lang::cpp::M3;
import IO;
import List;
import Set;
import String;
import util::Math;
import Relation;

// Build an M3 model for the given file
// e.g. |file:///path/to/File.cpp|, |project://Project/File.cpp|
M3 cppM3(loc l) {
	// Customize those according to your OS/setup
	list[loc] localCP = [
		|file:///usr/include|,
    	|file:///usr/include/c++/8.2.1|,
    	|file:///usr/include/c++/8.2.1/tr1|,
    	|file:///usr/include/linux/|,
    	|file:///usr/include/c++/8.2.1/x86_64-pc-linux-gnu/|
    ];

    // Those ones are "domain-specific". Sources:
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

	return createM3FromCppFile(l, stdLib = localCP, includeDirs = arduinoCP);
}

set[loc] varDecls(M3 m) {
	return {l | <l, _> <- m.declarations, l.scheme == "cpp+variable"};
}

// Ratio is character-wise, not line-wise
real commentRatio(M3 m) {
	int fileSize = size(readFile(m.id));
	return (0 | it + l.length | l <- m.comments, l.uri == m.id.uri) / toReal(fileSize);
}

// All transitive #includes, as parsed by CDT and
// their corresponding filepath, if applicable
rel[loc, loc] includes(M3 m) {
	return {<i, l> | i <- domain(m.includeDirectives), l <- m.includeResolution[i]};
}
