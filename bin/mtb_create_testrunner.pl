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

##########################################################################
# Local Variables
##########################################################################
$num_suites  = 0;


##########################################################################
# PrintHelp(): Prints the script usage.
##########################################################################
sub PrintHelp() {
  print "\n";
  print "Usage:  create_testrunner.pl [ -help | -i | -r | -out <file> | -add <filename> | -overwrite ]\n\n";
  print "Where -help           : prints this help screen\n";
  print "      -out <file>     : specifies an output filename\n";
  print "      -add <filename> : adds suite to test runner\n";
  print "      -overwrite      : overwrites the output file if it already exists\n";
  print "\n";
  die;
}


##########################################################################
# CheckArgs(): Checks the arguments of the program.
##########################################################################
sub CheckArgs() {
  $numargs = @ARGV;

  for $i (0..$numargs-1) {
    if ( $skip == 1 ) {
      $skip = 0;
    }
    else {
      if ( @ARGV[$i] =~ /-help/ ) {
        PrintHelp();
      }
      elsif ( @ARGV[$i] =~ /-out/ ) {
        $i++;
        $skip = 1;
        $output_file = $ARGV[$i];
      }
      elsif ( @ARGV[$i] =~ /-add/ ) {
        $i++;
        $skip = 1;
        push(@files_to_add, $ARGV[$i]);
      }
      elsif ( @ARGV[$i] =~ /-overwrite/ ) {
        $overwrite = 1;
      }
    }
  }
}

  
##########################################################################
# ValidArgs(): This checks to see if the arguments provided make sense.
##########################################################################
sub ValidArgs() {
  if ( $output_file eq "" ) {
    print "\nERROR:  The output file was not specified\n";
    PrintHelp();
  }
  if ( @files_to_add == 0 ) {
    print "\nERROR:  No files specified\n";
    PrintHelp();
  }
  print "\nSVUNIT: Output File: $output_file\n";
  print "\n";
  $class = $output_file;
  $class =~ s/\.sv//g;
}


##########################################################################
# OpenFiles(): This opens the input and output files
##########################################################################
sub OpenFiles() {
  if ( -r $output_file and $overwrite != 1 ) {
    print "ERROR: The file $output_file already exists, to overwrite, use the -overwrite argument\n\n";
    exit 1;
  }
  else {
    open ( OUTFILE, ">$output_file"  ) or die "Cannot Open file $output_file\n";
  }
}


##########################################################################
# CloseFiles(): This closes the input and output files
##########################################################################
sub CloseFiles() {
  close ( OUTFILE ) or die "Cannot Close file $output_file\n";
}


##########################################################################
# CreateTestSuite(): This creates the testsuite for all unit tests within
#                    this directory 
##########################################################################
sub CreateTestSuite() {
  foreach ( @files_to_add ) {
    -e $_ or die "ERROR: $_ does not exist";
    tr/\// /;
    @item = split(/ /);
    foreach $j (@item) {
      if ( $j =~ /testsuite\.sv/ ) {
        chomp( $j );
        push(@list, $j);
      }
    }
  }

  foreach $item ( @list ) {
    $item =~ s/\.sv//g;
    $item =~ s/\.//;
    $instance = $item;
    $instance =~ s/_testsuite/_ts/g;
    if ( $overwrite != 1 ) {
      print "\n";
    }
    push( @class_names, $item );
    push( @instance_names, $instance );
    $num_suites++;
  }
  

  $cnt = 0;

  print "SVUNIT: Creating testrunner $class:\n\n";

  print OUTFILE "import miniTB_pkg::\*;\n\n";
  print OUTFILE "module $class();\n";
  print OUTFILE "  string name = \"$class\";\n";
  print OUTFILE "  miniTB_testrunner miniTB_tr;\n\n\n";
  print OUTFILE "  //==================================\n";
  print OUTFILE "  // These are the test suites that we\n";
  print OUTFILE "  // want included in this testrunner\n";
  print OUTFILE "  //==================================\n";

  print "SVUNIT: Creating instances for:\n";
  foreach $item ( @class_names ) {
    print OUTFILE "  $item $instance_names[$cnt]();\n";
    print "          $item\n";
    $cnt++;
  }
  print "\n";

  print OUTFILE "\n";
  print OUTFILE "\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Main\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  initial\n";
  print OUTFILE "  begin\n";
  print OUTFILE "    build();\n";
  print OUTFILE "    run();\n";
  print OUTFILE "    \$finish();\n";
  print OUTFILE "  end\n";

  $cnt = 0;

  print OUTFILE "\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Build\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  function void build();\n";
  print OUTFILE "    miniTB_tr = new(name);\n";

  foreach $item ( @instance_names ) {
    print OUTFILE "    $item.build();\n";
    print OUTFILE "    miniTB_tr.add_testsuite($item.miniTB_ts);\n";
    $cnt++;
  }

  print OUTFILE "  endfunction\n\n\n";

  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Run\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  task run();\n";
  foreach $item ( @instance_names ) {
    print OUTFILE "    $item.run();\n";
  }
  print OUTFILE "    miniTB_tr.report();\n";
  print OUTFILE "  endtask\n";

  print OUTFILE "\n";
  print OUTFILE "\n";
  print OUTFILE "endmodule\n";
}



##########################################################################
# MoveFile(): This moves the overwrites the output file with the 
#             temporary output file.
##########################################################################
sub MoveFile() {
  if ( -w $output_file ) {
    system("mv $output_file~ $output_file");
  }
  else {
    die "ERROR: Move from $output_file~ to $output_file failed";
  }
}


##########################################################################
# This is the main run flow of the script
##########################################################################
CheckArgs();
ValidArgs();
OpenFiles();
CreateTestSuite();
CloseFiles(); 
