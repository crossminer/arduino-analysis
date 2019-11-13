module arduino::CloneTests

import lang::cpp::M3;
import Set;
import IO;
import arduino::Metrics;

test bool testSX1272() {
	M3 orig = cppM3(|file:///home/dig/sandbox/SX1272/orig/libraries/SX1272/WaspSX1272.cpp|, includes = arduinoIncludes + |file:///home/dig/sandbox/SX1272/orig/waspmote-api/|);
	M3 fork = cppM3(|file:///home/dig/sandbox/SX1272/fork/Arduino/libraries/SX1272/src/SX1272.cpp|, includes = arduinoIncludes + |file:///home/dig/sandbox/SX1272/orig/waspmote-api/|);

	real sim = similarity(orig, fork);
	println("sim=<sim>");
	return sim > 0.5; 
}

test bool testIRremote() {
	M3 orig = cppM3(|file:///home/dig/sandbox/IRremote/orig/IRremoteInt.h|, includes = arduinoIncludes);
	M3 fork = cppM3(|file:///home/dig/sandbox/IRremote/fork/IRremoteInt.h|, includes = arduinoIncludes);

	real sim = similarity(orig, fork);
	println("sim=<sim>");
	return sim > 0.5; 
}

test bool testWifiManager() {
	M3 orig = cppM3(|file:///home/dig/sandbox/WifiManager/orig/WiFiManager.cpp|, includes = arduinoIncludes);
	M3 fork = cppM3(|file:///home/dig/sandbox/WifiManager/fork/WiFiManager.cpp|, includes = arduinoIncludes);

	real sim = similarity(orig, fork);
	println("sim=<sim>");
	return sim > 0.5; 
}
