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
@memo
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
rel[loc, TypeSymbol] allTypedVarDecls(M3 m) = { <l, t> | l <- allVarDecls(m), t <- m.declaredType[l] };

// Basic memory usage calculation
@metric
int sketchSize(M3 m) = (0 | it + byteSize(t) | <l, t> <- typedVarDecls(m));

@metric
int allSketchSize(M3 m) = (0 | it + byteSize(t) | <l, t> <- allTypedVarDecls(m));

// List of all the includes of the include graph. Includes are mapped to
// the physical locations of the corresponding C++ files, when resolved.
@metric
rel[loc, loc] includes(M3 m) = { <i, l> | i <- domain(m.includeDirectives), l <- m.includeResolution[i] };

// Ratio of comments/documentation.
// Ratio is character-wise, not line-wise
@metric
real commentRatio(M3 m) {
	int fileSize = size(readFile(m.id));
	int commentsSize = (0 | it + size(readFile(l)) | l <- m.comments, l.uri == m.id.uri);
	return commentsSize / toReal(fileSize);
}

// Missing dependencies
@metric
set[loc] missingDeps(M3 m) {
	return { logical | <logical, physical> <- includes(m), physical == |unresolved:///| };
}

real similarity(M3 m1, M3 m2) {
	return jaccard(m1.declarations, m2.declarations);
}

// Helpers
bool isVariable(loc l) = l.scheme == "cpp+variable";
bool isMethod(loc l)   = l.scheme == "cpp+method";
bool isFunction(loc l) = l.scheme == "cpp+function";

bool isLocal(M3 m, loc l) {
	for (loc physical <- m.declarations[l])
		if (physical.uri == m.id.uri)
			return true;

	return false;
}

// TODO: Sizes
int byteSize(TypeSymbol::\unspecified()) = 0;
int byteSize(TypeSymbol::\void()) = 0;
int byteSize(TypeSymbol::\char()) = 1;
int byteSize(TypeSymbol::\wchar()) = 0;
int byteSize(TypeSymbol::\int()) = 2;
int byteSize(TypeSymbol::\float()) = 4;
int byteSize(TypeSymbol::\double()) = 4;
int byteSize(TypeSymbol::\boolean()) = 1;
int byteSize(TypeSymbol::\char16()) = 0;
int byteSize(TypeSymbol::\char32()) = 0;
int byteSize(TypeSymbol::\nullPtr()) = 0;
int byteSize(TypeSymbol::\int128()) = 0;
int byteSize(TypeSymbol::\float128()) = 0;
int byteSize(TypeSymbol::\decimal32()) = 0;
int byteSize(TypeSymbol::\decimal64()) = 0;
int byteSize(TypeSymbol::\decimal128()) = 0;

int byteSize(TypeSymbol::\uint8_t()) = 1;
int byteSize(TypeSymbol::\uint16_t()) = 2;
int byteSize(TypeSymbol::\long()) = 4;
int byteSize(TypeSymbol::\word()) = 2;
int byteSize(TypeSymbol::\string()) = 6;
int byteSize(TypeSymbol::\unsigned()) = 0;
int byteSize(TypeSymbol::\const()) = 6;

int byteSize(TypeSymbol::\array(TypeSymbol baseType)) = 0;
int byteSize(TypeSymbol::\array(TypeSymbol baseType, int size)) = 0;
int byteSize(TypeSymbol::\basicType(list[lang::cpp::TypeSymbol::TypeModifier] modifiers, TypeSymbol baseType)) = byteSize(baseType);
int byteSize(TypeSymbol::\class(loc decl)) = 0;
int byteSize(TypeSymbol::\union(loc decl)) = 0;
int byteSize(TypeSymbol::\struct(list[TypeSymbol] fields)) = 0;
int byteSize(TypeSymbol::\qualifierType(list[lang::cpp::TypeSymbol::TypeModifier] modifiers, TypeSymbol \type)) = 0;
int byteSize(TypeSymbol::\pointerType(list[lang::cpp::TypeSymbol::TypeModifier] modifiers, TypeSymbol \type)) = 0;
int byteSize(TypeSymbol::\functionType(TypeSymbol returnType, list[TypeSymbol] parameterTypes)) = 0;
int byteSize(TypeSymbol::\functionTypeVarArgs(TypeSymbol returnType, list[TypeSymbol] parameterTypes)) = 0;
int byteSize(TypeSymbol::\typeContainer(TypeSymbol \type)) = 0;
int byteSize(TypeSymbol::\typedef(TypeSymbol \type)) = 0;
int byteSize(TypeSymbol::\enumeration(loc decl)) = 0;
int byteSize(TypeSymbol::\referenceType(TypeSymbol \type)) = 0;
int byteSize(TypeSymbol::\parameterPackType(TypeSymbol \type)) = 0;

int byteSize(TypeSymbol::\classSpecialization(loc decl, list[TypeSymbol] templateArguments)) = 0;
int byteSize(TypeSymbol::\enumerationSpecialization(loc specializedBinding, list[TypeSymbol] templateArguments)) = 0;

int byteSize(TypeSymbol::\templateTypeParameter(loc owner, loc decl)) = 0;
int byteSize(TypeSymbol::\implicitTemplateTypeParameter(loc owner, int position)) = 0; //no decl?
int byteSize(TypeSymbol::\deferredClassInstance(str name)) = 0;
int byteSize(TypeSymbol::\unknownMemberClass(loc owner, str name)) = 0;

int byteSize(TypeSymbol::\typeOfDependentExpression(loc src)) = 0;
int byteSize(TypeSymbol::\problemBinding()) = 0;
int byteSize(TypeSymbol::\problemType(str msg)) = 0;
int byteSize(TypeSymbol::\noType()) = 0;

int byteSize(TypeSymbol::\cStructTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\cUnionTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\cClassTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\eStructTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\eUnionTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\eClassTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\eEnumTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\templateTemplate(TypeSymbol child, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\functionTemplate(loc decl, list[loc] templateParameters)) = 0;
int byteSize(TypeSymbol::\variableTemplate(loc decl, list[loc] templateParameters)) = 0;

int byteSize(TypeSymbol::\aliasTemplate(loc decl, list[loc] templateParameters)) = 0;

int byteSize(TypeSymbol::\functionSetType(loc decl, list[TypeSymbol] templateArguments)) = 0;
int byteSize(TypeSymbol::\functionSetTypePointer(loc decl, list[TypeSymbol] templateArguments)) = 0;

int byteSize(TypeSymbol::\unresolved()) = 0;
int byteSize(TypeSymbol::\any()) = 0;
