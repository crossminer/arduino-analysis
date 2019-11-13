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

// Those ones are Arduino-specific. Sources:
//   - https://github.com/arduino/ArduinoCore-avr
//   - https://github.com/PaulStoffregen/RadioHead
//   - https://github.com/PaulStoffregen/SPI/
public list[loc] arduinoIncludes = [
	|file:///usr/avr/include/|,
	|file:///home/dig/repositories/SPI|,
	|file:///home/dig/repositories/RadioHead|,
	|file:///home/dig/repositories/ArduinoCore-avr/cores/arduino|,
	|file:///home/dig/repositories/ArduinoCore-avr/variants/standard/|
];

// Build an M3 model for the given C++ file
// e.g. |file:///path/to/File.cpp| or |project://Project/File.cpp|
M3 cppM3(loc l, list[loc] includes = arduinoIncludes) {
	// Customize those according to your OS/setup
	list[loc] stdIncludes = [
		|file:///usr/include|,
    	|file:///usr/include/c++/9.2.0|,
    	|file:///usr/include/c++/9.2.0/tr1|,
    	|file:///usr/include/linux/|,
    	|file:///usr/include/c++/9.2.0/x86_64-pc-linux-gnu/|
    ];

	M3 m = createM3FromCppFile(l, stdLib = stdIncludes, includeDirs = includes);

	// includeResolution often contains two entries for a given include:
	// a resolved one and an unresolved one; remove the latter
	// TODO: issue on CLAIR
	m.includeResolution -= { <log, phy> | <log, phy> <- m.includeResolution,
		isUnresolved(phy) && size(m.includeResolution[log]) > 1 };

	for (loc l <- missingDeps(m))
		println("Warning: <l> could not be resolved");

	return m;
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
set[loc] missingDeps(M3 m) = invert(includes(m))[|unresolved:///|];

// Similarity / clones detection
real similarity(M3 orig, M3 fork) {
	// We're only interested in the current module's declarations
	set[loc] localOrigDecls = localDecls(orig);
	set[loc] localForkDecls = localDecls(fork);

	// Stripped method signatures
	set[str] origMethods = { replaceAll(l.uri, l.parent.uri, "") | l <- localOrigDecls, isMethod(l) };
	set[str] forkMethods = { replaceAll(l.uri, l.parent.uri, "") | l <- localForkDecls, isMethod(l) };

	// Stripped function signatures
	set[str] origFunctions = { l.uri | l <- localOrigDecls, isFunction(l) };
	set[str] forkFunctions = { l.uri | l <- localForkDecls, isFunction(l) };

	// Stripped field signatures
	set[str] origFields = { replaceAll(l.uri, l.parent.uri, "") | l <- localOrigDecls, isField(l) };
	set[str] forkFields = { replaceAll(l.uri, l.parent.uri, "") | l <- localForkDecls, isField(l) };

	set[str] origDecls = origMethods + origFunctions + origFields;
	set[str] forkDecls = forkMethods + forkFunctions + forkFields;
	
	assert size(origDecls) > 0 : "No declarations found in orig.";
	assert size(forkDecls) > 0 : "No declarations found in fork.";

	set[str] inter = origDecls & forkDecls;

	println("Comparing <orig.id.file> \<-\> <fork.id.file>");
	println("\tPerfect matches: <size(inter)> declarations (<toReal(size(inter)) / size(origDecls) * 100>%) have been perfectly matched in the fork.");
	
	// TODO: match e.g. uint16_t / uint32_t
	
	return jaccard(origDecls, forkDecls);
}

// Helpers
bool isVariable(loc l) = l.scheme == "cpp+variable";
bool isMethod(loc l)   = l.scheme == "cpp+method";
bool isFunction(loc l) = l.scheme == "cpp+function";
bool isField(loc l) = l.scheme == "cpp+field";

bool isUnresolved(loc l) = l == |unresolved:///|;

bool isLocal(M3 m, loc l) {
	for (loc physical <- m.declarations[l])
		if (physical.uri == m.id.uri)
			return true;

	return false;
}

set[loc] localDecls(M3 m) {
	return { l | <l, p> <- m.declarations, p.uri == m.id.uri };
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
