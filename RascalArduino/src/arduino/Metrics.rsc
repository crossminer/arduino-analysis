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

// Transitive list of all variable declarations and functions/methods
// declared in any of the files part of the include graph
set[loc] allVarDecls(M3 m) = { l | <l, _> <- m.declarations, isVariable(l) };
set[loc] allFunctions(M3 m)  = { l | <l, _> <- m.declarations, isMethod(l) || isFunction(l) };

// List of all variable declarations and functions/methods of the analyzed file only
set[loc] varDecls(M3 m) = { l | l <- allVarDecls(m), isLocal(m, l) };
set[loc] functions(M3 m)  = { l | l <- allFunctions(m),  isLocal(m, l) };

// List of variable declarations and functions/methods with their declared types
rel[loc, TypeSymbol] typedVarDecls(M3 m) = { <l, t> | l <- varDecls(m), t <- m.declaredType[l] };
rel[loc, TypeSymbol] typedFunctions(M3 m)  = { <l, t> | l <- functions(m),  t <- m.declaredType[l] };

// Basic memory usage calculation; to be done
int sketchSize(M3 m) = (0 | it + byteSize(t) | <l, t> <- typedVarDecls(m));

// List of all the includes of the include graph. Includes are mapped to
// the physical locations of the corresponding C++ files, when resolved.
rel[loc, loc] includes(M3 m) = { <i, l> | i <- domain(m.includeDirectives), l <- m.includeResolution[i] };

// Ratio of comments/documentation.
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

// TODO: Sizes
int byteSize(\unspecified()) = 0;
int byteSize(\void()) = 0;
int byteSize(\char()) = 0;
int byteSize(\wchar()) = 0;
int byteSize(\int()) = 0;
int byteSize(\float()) = 0;
int byteSize(\double()) = 0;
int byteSize(\boolean()) = 0;
int byteSize(\char16()) = 0;
int byteSize(\char32()) = 0;
int byteSize(\nullPtr()) = 0;
int byteSize(\int128()) = 0;
int byteSize(\float128()) = 0;
int byteSize(\decimal32()) = 0;
int byteSize(\decimal64()) = 0;
int byteSize(\decimal128()) = 0;

int byteSize(\array(TypeSymbol baseType)) = 0;
int byteSize(\array(TypeSymbol baseType, int size)) = 0;
int byteSize(\basicType(list[TypeModifier] modifiers, TypeSymbol baseType)) = 0;
int byteSize(\class(loc decl)) = 0;
int byteSize(\union(loc decl)) = 0;
int byteSize(\struct(list[TypeSymbol] fields)) = 0;
int byteSize(\qualifierType(list[TypeModifier] modifiers, TypeSymbol \type)) = 0;
int byteSize(\pointerType(list[TypeModifier] modifiers, TypeSymbol \type)) = 0;
int byteSize(\functionType(TypeSymbol returnType, list[TypeSymbol] parameterTypes)) = 0;
int byteSize(\functionTypeVarArgs(TypeSymbol returnType, list[TypeSymbol] parameterTypes)) = 0;
int byteSize(\typeContainer(TypeSymbol \type)) = 0;
int byteSize(\typedef(TypeSymbol \type)) = 0;
int byteSize(\enumeration(loc decl)) = 0;
int byteSize(\referenceType(TypeSymbol \type)) = 0;
int byteSize(\parameterPackType(TypeSymbol \type)) = 0;

int byteSize(\classSpecialization(loc decl, list[TypeSymbol] templateArguments)) = 0;
int byteSize(\enumerationSpecialization(loc specializedBinding, list[TypeSymbol] templateArguments)) = 0;

int byteSize(\templateTypeParameter(loc owner, loc decl)) = 0;
int byteSize(\implicitTemplateTypeParameter(loc owner, int position)) = 0; //no decl?
int byteSize(\deferredClassInstance(str name)) = 0;
int byteSize(\unknownMemberClass(loc owner, str name)) = 0;

int byteSize(\typeOfDependentExpression(loc src)) = 0;
int byteSize(\problemBinding()) = 0;
int byteSize(\problemType(str msg)) = 0;
int byteSize(\noType()) = 0;

int byteSize(\cStructTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(\cUnionTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(\cClassTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(\eStructTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(\eUnionTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(\eClassTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(\eEnumTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(\templateTemplate(TypeSymbol child, list[loc] templateParameters)) = 0;
int byteSize(\functionTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(\variableTemplate(loc decl, list[loc] templateParameters)) = 0;

int byteSize(\aliasTemplate(loc decl, list[loc] templateParameters)) = 0;

int byteSize(\functionSetType(loc decl, list[TypeSymbol] templateArguments)) = 0;
int byteSize(\functionSetTypePointer(loc decl, list[TypeSymbol] templateArguments)) = 0;

int byteSize(\unresolved()) = 0;
int byteSize(\any()) = 0;
