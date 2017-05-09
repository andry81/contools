#!/bin/tclsh

 #
 # Proc to generate a string of (binary) characters
 # Range defaults to 'A'-'z' (this includes several non-alphabetic
 # characters)
 #
 binary scan A c A
 binary scan z c z
 proc randomDelimString [list length [list min $A] [list max $z]] {
    set range [expr {$max-$min}]

    set txt ""
    for {set i 0} {$i < $length} {incr i} {
       set ch [expr {$min+int(rand()*$range)}]
       append txt [binary format c $ch]
    }
    return $txt
 }

 #
 # Proc to generate a string of (given) characters
 # Range defaults to "ABCDEF...wxyz'
 #
 proc randomRangeString {length {chars "01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"}} {
    set range [expr {[string length $chars]-1}]

    set txt ""
    for {set i 0} {$i < $length} {incr i} {
       set pos [expr {int(rand()*$range)}]
       append txt [string range $chars $pos $pos]
    }
    return $txt
 }

 puts [randomDelimString 30]
 puts [randomRangeString 30]
 puts [randomRangeString 30 "aaabcdeeeeee"]

 #
 # Time the performance
 #
 set string ""
 set fd [open "./aaa.txt" "w+"]
 for {set i 0} {$i < 1000000} {incr i} {
   set string [randomRangeString 1000]
   puts $fd $string
   if { ! ($i % 1000) } {
     puts "$i: [string range $string 0 16]"
   }
 }
 close $fd

 if { 0 } {
   # Sample output (Pentium II, 350 MHz, running Windows 98, Tcl 8.3.4):

 [lmZQAiB]Hb_hFpEw`LiEQSjOSsBfC
 BnnWCymqGYaFyAKOAMPfmnYKRJTugu
 abcbdeaeeadeeeceaebaaebeeeebee
 3564 microseconds per iteration
 2862 microseconds per iteration

 }
 