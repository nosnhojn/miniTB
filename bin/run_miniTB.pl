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

############## VARIABLES ############## 

my $TESTDIR = ".";

my $INCDIR  = "-incdir $TESTDIR ";
$INCDIR .= "-incdir $ENV{MINITB_INSTALL}/verilog ";

my $ALLPKGS = "$ENV{MINITB_INSTALL}/verilog/miniTB_pkg.sv";

my $TESTRUNNER = ".testrunner.sv";

my $FILELISTS  = "-f *miniTB.f";

my $TESTSUITES = ".testsuite.sv";

my $TESTFILES  = "$FILELISTS ";
$TESTFILES .= "$TESTSUITES ";
$TESTFILES .= "$TESTRUNNER ";

my $SVUNIT_SIM  = "irun ";
$SVUNIT_SIM .= "$INCDIR ";
$SVUNIT_SIM .= "$ALLPKGS ";
$SVUNIT_SIM .= "$TESTFILES ";
$SVUNIT_SIM .= "-l run.log ";



############## COMMANDS ############## 

system("create_testsuite.pl -overwrite -add *miniTB.sv -out .testsuite.sv");
system("create_testrunner.pl -overwrite -add .testsuite.sv -out testrunner.sv");
system("mv testrunner.sv .testrunner.sv");
print "$SVUNIT_SIM\n";
system("$SVUNIT_SIM");
