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

use strict;

##########################################################################
# PrintHelp(): Prints the script usage.
##########################################################################
#
sub PrintHelp() {
  print "\n";
  print "Usage:  run_miniTB.pl [ -help ] <simulator> <file list> ]\n\n";
  print "Where -help                : prints this help screen\n";
  print "      <simulator>          : could be '-ius', '-vcs' or '-questa'\n";
  print "      <file list>          : *.f miniTB file list\n";
  print "\n";
}


##########################################################################
# CheckArgs(): Checks the arguments of the program.
##########################################################################

my $simulator;
my $FILELIST;
sub CheckArgs() {
  my $numargs = $#ARGV+1;

  for my $i (0..$numargs-1) {
    if ( @ARGV[$i] =~ /-help/ ) {
      PrintHelp();
    }
    elsif ( @ARGV[$i] =~ /-ius/ ) {
      $simulator = "irun";
    }
    elsif ( @ARGV[$i] =~ /-questa/ ) {
      $simulator = "qverilog";
    }
    elsif ( @ARGV[$i] =~ /-vcs/ ) {
      $simulator = "vcs";
    }
    else {
      $FILELIST = @ARGV[$i];
    }
  }
}


##########################################################################
# ValidArgs(): This checks to see if the arguments provided make sense.
##########################################################################

sub ValidArgs() {
  if (not defined $simulator) {
    print "\nERROR:  The simulator was not specified'\n";
    PrintHelp();
    return 1;
  } elsif (not defined $FILELIST) {
    print "\nERROR:  No filelist specified'\n";
    PrintHelp();
    return 1;
  } else {
    return 0;
  }
}



############## VARIABLES ############## 

my $TESTDIR;
my $INCDIR;
my $ALLPKGS;
my $TESTRUNNER;
my $FILELIST;
my $TESTSUITES;
my $TESTFILES;
my $SVUNIT_SIM;

sub buildCmdLine() {
  $TESTDIR = ".";

  if ($simulator eq "irun") {
    $INCDIR  = "-incdir $TESTDIR ";
    $INCDIR .= "-incdir $ENV{MINITB_INSTALL}/verilog ";
  }
  else {
    $INCDIR  = "+incdir+$TESTDIR ";
    $INCDIR .= "+incdir+$ENV{MINITB_INSTALL}/verilog ";
  }

  $ALLPKGS = "$ENV{MINITB_INSTALL}/verilog/miniTB_pkg.sv";

  $TESTRUNNER = ".testrunner.sv";

  $FILELIST  = "-f *miniTB.f";

  $TESTSUITES = ".testsuite.sv";

  $TESTFILES  = "$FILELIST ";
  $TESTFILES .= "$TESTSUITES ";
  $TESTFILES .= "$TESTRUNNER ";

  $SVUNIT_SIM  = "$simulator ";
  $SVUNIT_SIM .= "$INCDIR ";
  $SVUNIT_SIM .= "$ALLPKGS ";
  $SVUNIT_SIM .= "$TESTFILES ";
  $SVUNIT_SIM .= "-l run.log ";


  if ($simulator eq "irun") {
    $SVUNIT_SIM .= "-input run.tcl";

    open(my $fh, ">", "run.tcl") or die "Cannot create run.tcl: $!";
    print $fh "database -open waves.shm\n";
    print $fh "run\n";
    print $fh "database -close waves.shm\n";
  }
  elsif ($simulator eq "qverilog") {
    open(my $fh, ">", "run.tcl") or die "Cannot create run.tcl: $!";
    $SVUNIT_SIM .= "-R -voptargs=+acc -do run.tcl";
    print $fh "onerror {quit -f}\n";
    print $fh "log -r /*\n";
    print $fh "run -all\n";
    print $fh "dataset save sim vsim.wlf\n";
    print $fh "quit -f\n";
  }
  elsif ($simulator eq "vcs") {
    $SVUNIT_SIM .= "-R -sverilog +vcs+vcdpluson -debug";
  }
}



############## COMMANDS ############## 

CheckArgs();
if ( ValidArgs() == 0 ) {
  buildCmdLine();
  system("mtb_create_testsuite.pl -overwrite -add *miniTB.sv -out .testsuite.sv");
  system("mtb_create_testrunner.pl -overwrite -add .testsuite.sv -out testrunner.sv");
  system("mv testrunner.sv .testrunner.sv");
  print "$SVUNIT_SIM\n";
  system("$SVUNIT_SIM");
  system("user_feedback.pl");
}
