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


***********************************************************
***********************************************************

                     Congrats!!

***********************************************************
***********************************************************
You're 1 step closer to smoke testing your RTL in a
designer friendly verilog framework and just minutes away
from running your first smoke test!
***********************************************************
***********************************************************


NOTE: for instructions on how to get going with miniTB, go to
      www.agilesoc.com.


-----------------------------------------------------------
Release Notes...
-----------------------------------------------------------

See RELEASE.txt for release notes


-----------------------------------------------------------
Running the example miniTB
-----------------------------------------------------------

'cd examples/modules/apb_slave/' and follow the instructions
in README to see a full miniTB example.


-----------------------------------------------------------
Step-by-step instructions to build your own miniTB
-----------------------------------------------------------

1) setup the MINITB_INSTALL and PATH environment variables
>export MINITB_INSTALL=`pwd`
>export PATH=$PATH:$MINITB_INSTALL"/bin"

1a) or you can source the Setup.bsh (if you use the bash shell)
>source Setup.bsh

1b) or you can source the Setup.csh (if you use the csh shell)
>source Setup.csh

2) go somewhere and generate a miniTB. This'll give you a verilog
miniTB template and a miniTB filelist
>cd <somewhere>
>build_miniTB.pl -module_name my_module

3) add any required files, include directories, misc filelist switches
to my_module_miniTB.f

4) add smoke tests to your miniTB using the SMOKETEST macros
---
  my_module_miniTB.sv:
    `SMOKE_TESTS_BEGIN

    //===================================
    // Unit test: test_mytest
    //===================================
    `SMOKETEST(my_smoke_test)
      <exercise uut functionality>
      `FAIL_IF(uut.some_signal != <some_value>);
    `SMOKETEST_END

    `SMOKE_TESTS_END
---

7) run your miniTB with the simulator of your choice (ius, questa or vcs)
>run_miniTB.pl -ius my_module_miniTB.f   # OR
>run_miniTB.pl -questa my_module_miniTB.f   # OR
>run_miniTB.pl -vcs my_module_miniTB.f

8) pat self on back
