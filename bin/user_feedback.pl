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

my $FB;
my $fb_file;
my $HI_MSG_THRESHOLD = 20;
my $LO_MSG_THRESHOLD = 10;

sub printHi() {
  print "Wow!! You must really like MiniTB. We'd really appreciate telling us something about what you're doing!\n";
}

sub printLo() {
  print "Thanks for giving MiniTB a try. Can you give us your initial impression? What you like/hate?\n";
}

if (defined $ENV{"HOME"} and not defined $ENV{"BUGGEROFFMINITB"}) {
  $fb_file = $ENV{"HOME"} . "/.minitb";

  if (-e $fb_file) {
    open (FB, "+<$fb_file") or exit 0;
    $_ = <FB>;
    chomp;
    if (m/^[0-9]+$/) {
      if ($_ == $HI_MSG_THRESHOLD) {
        printHi();
      }

      elsif ($_ == $LO_MSG_THRESHOLD) {
        printLo();
      }

      if ($_ <= $HI_MSG_THRESHOLD) {
        seek FB, 0, 0;
        print FB ++$_ . "\n";
      }
    }
  }

  else {
    open (FB, ">$fb_file") or exit 0;
    print FB "1\n";
  }
  close ( FB, ">$fb_file") or exit 0;
}
