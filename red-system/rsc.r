REBOL [
	Title:   "Red/System compiler wrapper"
	Author:  "Nenad Rakocevic"
	File: 	 %rsc.r
	Rights:  "Copyright (C) 2011 Nenad Rakocevic. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
	Usage:   {
		do/args %rsc.r "[-vvvv] [-f PE|ELF] %path/source.reds"
	}
]

; unless value? 'system-dialect [
	do %compiler.r
; ]

unless exists? %builds/ [make-dir %builds/]

verbosity: 0
opts: make system-dialect/options-class [link?: yes]

unless parse system/script/args [
	any [
		#"-" [
			some [#"v" (verbosity: verbosity + 1)] (opts/verbosity: verbosity)
			| #"f" copy fmt to #" " (opts/format: to-word trim fmt)
		]
	]
	file: to end
][
	print "Invalid command line"
	halt
]

unless all [
	file? file: attempt [load file]
	exists? file	
][
	print ["Can't access file" mold file]
	halt
]

print [
	newline
	"-= Red/System Compiler =-" newline
	"Compiling" file "..."
]

result: system-dialect/compile/options file opts

print ["^/...compilation time:" tab round result/1/second * 1000 "ms"]
if result/2 [
	print [
		"...linking time:" tab tab round result/2/second * 1000 "ms^/"
		"...output file size:" tab result/3 "bytes"
	]
]


