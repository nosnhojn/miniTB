#!/usr/bin/perl

################################################################
#
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#  
#  http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.
#
################################################################

use File::Basename;


##########################################################################
# PrintHelp(): Prints the script usage.
##########################################################################
sub PrintHelp() {
  print "\n";
  print "Usage:  build_miniTB.pl [ -help ] -module_name <name>\n\n";
  print "Where -help                : prints this help screen\n";
  print "      -module_name <name>  : generate a unit test template for a module <name>\n";
  print "\n";
}


##########################################################################
# CheckArgs(): Checks the arguments of the program.
##########################################################################


sub CheckArgs() {
  $numargs = $#ARGV+1;

  for $i (0..$numargs-1) {
    if ( $skip == 1 ) {
      $skip = 0;
    }
    else {
      if ( @ARGV[$i] =~ /-help/ ) {
        PrintHelp();
      }
      elsif ( @ARGV[$i] =~ /-module_name/ ) {
        $i++;
        $skip = 1;
        $module_name = $ARGV[$i];
      }
    }
  }
}

  
##########################################################################
# ValidArgs(): This checks to see if the arguments provided make sense.
##########################################################################
sub ValidArgs() {
  if ( not defined($module_name) ) {
    print "\nERROR:  The -module_name was not specified\n";
    PrintHelp();
    return 1;
  }
  else {
    $miniTB = $module_name;
    $miniTB .= "_miniTB.sv";

    $miniTB_flist = $module_name;
    $miniTB_flist .= "_miniTB.f";
    return 0;
  }
}


##########################################################################
# OpenFiles(): This opens the input and output files
##########################################################################
sub OpenFiles() {
  if ( -r $miniTB or -r $miniTB_flist ) {
    print "\nERROR: The miniTB '$miniTB' already exists\n\n";
    exit 1;
  }
  else {
    open (MINITB, ">$miniTB") or die "Cannot Open file $miniTB\n";
    open (FLIST, ">$miniTB_flist") or die "Cannot Open file $miniTB_flist\n";
  }
}


##########################################################################
# CloseFiles(): This closes the input and output files
##########################################################################
sub CloseFiles() {
  close (MINITB) or die "Cannot Close file $miniTB\n";
  close (FLIST) or die "Cannot Close file $miniTB_flist\n";
}


##########################################################################
# Main(): writes the rest of the unit test file
##########################################################################
sub Main() {
  $processing_module = 1;
  $uut = $module_name;
  $testfilename = "$module_name.sv";
  CreateMiniTB();
  CreateFlist();
}


##########################################################################
# CreateClassUnitTest(): This creates the output for the unit test class.  It's
#                   called for each class within the file
##########################################################################
sub CreateMiniTB() {
  print MINITB "`include \"miniTB_defines.svh\"\n";
  print MINITB "import miniTB_pkg::*;\n";
  print MINITB "\n";
  print MINITB "module $uut\_miniTB;\n";
  print MINITB "  string name = \"$uut\_miniTB\";\n";
  print MINITB "  miniTB_logger logger;\n";
  print MINITB "\n";
  print MINITB "\n";
  print MINITB "  //===================================\n";
  print MINITB "  // This is the module that we're \n";
  print MINITB "  // smoke testing\n";
  print MINITB "  //===================================\n";
  print MINITB "  $uut uut();\n\n\n";
  print MINITB "  //===================================\n";
  print MINITB "  // build (like an initial block that\n";
  print MINITB "  // executes prior to running any\n";
  print MINITB "  // tests)\n";
  print MINITB "  //===================================\n";
  print MINITB "  function void build();\n";
  print MINITB "    logger = new(name);\n";
  print MINITB "  endfunction\n\n\n";
  print MINITB "  //===================================\n";
  print MINITB "  // reset each smoke test\n";
  print MINITB "  //===================================\n";
  print MINITB "  task smoketest_reset();\n";
  print MINITB "  endtask\n\n\n";
  print MINITB "  //===================================\n";
  print MINITB "  // All tests are defined between the\n";
  print MINITB "  // SMOKE_TESTS_BEGIN/END macros\n";
  print MINITB "  //\n";
  print MINITB "  // Each individual test must be\n";
  print MINITB "  // defined between\n";
  print MINITB "  //   `SMOKETEST(_NAME_)\n";
  print MINITB "  //   `SMOKETEST_END\n";
  print MINITB "  //\n";
  print MINITB "  // i.e.\n";
  print MINITB "  //   `SMOKETEST(mytest)\n";
  print MINITB "  //     <test code>\n";
  print MINITB "  //   `SMOKETEST_END\n";
  print MINITB "  //===================================\n";
  print MINITB "  `SMOKE_TESTS_BEGIN\n\n\n\n";
  print MINITB "  `SMOKE_TESTS_END\n\n";
  print MINITB "endmodule\n";
}


sub CreateFlist() {
  print FLIST "$testfilename\n";
  print FLIST "$miniTB\n";
}


##########################################################################
# This is the main run flow of the script
##########################################################################
CheckArgs();
if ( ValidArgs() == 0) {
  OpenFiles();
  Main();
  CloseFiles(); 
}
