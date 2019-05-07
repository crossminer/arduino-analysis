module arduino::Metrics

import analysis::m3::Core;
import lang::cpp::AST;
import lang::cpp::M3;
import IO;
import List;
import Set;
import String;
import util::Math;
import Relation;

// Build an M3 model for the given C++ file
// e.g. |file:///path/to/File.cpp| or |project://Project/File.cpp|
M3 cppM3(loc l) {
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

	return createM3FromCppFile(l, stdLib = localCP, includeDirs = arduinoCP);
}

// Transitive declarations
set[loc] allVarDecls(M3 m) = { l | <l, _> <- m.declarations, isVariable(l) };
set[loc] allFunctions(M3 m)  = { l | <l, _> <- m.declarations, isMethod(l) || isFunction(l) };

// Local declarations
set[loc] varDecls(M3 m) = { l | l <- allVarDecls(m), isLocal(m, l) };
set[loc] functions(M3 m)  = { l | l <- allFunctions(m),  isLocal(m, l) };

// Typed declarations
rel[loc, TypeSymbol] typedVarDecls(M3 m) = { <l, t> | l <- varDecls(m), t <- m.declaredType[l] };
rel[loc, TypeSymbol] typedFunctions(M3 m)  = { <l, t> | l <- functions(m),  t <- m.declaredType[l] };

// All transitive #includes, as parsed by CDT and
// their corresponding filepath, if applicable
rel[loc, loc] includes(M3 m) = { <i, l> | i <- domain(m.includeDirectives), l <- m.includeResolution[i] };

// Ratio is character-wise, not line-wise
real commentRatio(M3 m) {
	int fileSize = size(readFile(m.id));
	int commentsSize = (0 | it + size(readFile(l)) | l <- m.comments, l.uri == m.id.uri);
	return commentsSize / toReal(fileSize);
}

// Helpers
bool isVariable(loc l) = l.scheme == "cpp+variable";
bool isMethod(loc l)   = l.scheme == "cpp+method";
bool isFunction(loc l) = l.scheme == "cpp+function";

bool isLocal(M3 m, loc l) {
	set[loc] physicalLocs = m.declarations[l];

	for (loc physical <- m.declarations[l])
		if (physical.uri == m.id.uri)
			return true;

	return false;
}
