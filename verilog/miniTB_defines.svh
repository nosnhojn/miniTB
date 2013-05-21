//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################


/*
  Macro: `FAIL_IF
  Fails if expression is true

  Parameters: 
    exp - expression to evaluate
*/
`ifndef FAIL_IF
`define FAIL_IF(exp) \
  if (logger.fail_if(exp, `"exp`", `__FILE__, `__LINE__)) begin \
    if (logger.is_running) logger.give_up(); \
  end
`endif


/*
  Macro: `FAIL_UNLESS
  Fails if expression is not true

  Parameters: 
    exp - expression to evaluate
*/
`ifndef FAIL_UNLESS
`define FAIL_UNLESS(exp) \
  if (logger.fail_unless(exp, `"exp`", `__FILE__, `__LINE__)) begin \
    if (logger.is_running) logger.give_up(); \
  end
`endif


/*
  Macro: `INFO
  Displays info message to screen and in log file

  Parameters: 
    msg - string to display
*/
`define INFO(msg) \
  $display("INFO:  [%0t][%0s]: %s", $time, name, msg) 


/*
  Macro: `ERROR
  Displays error message to screen and in log file

  Parameters: 
    msg - string to display
*/
`define ERROR(msg) \
  $display("ERROR: [%0t][%0s]: %s", $time, name, msg)


/*
  Macro: `LF
  Displays a blank line in log file  
*/
`define LF $display("");


/*
  Macro: `SMOKE_TESTS_BEGIN
  START a block of unit tests
*/
`define SMOKE_TESTS_BEGIN \
  task automatic run(); \
    `INFO($psprintf("%s::RUNNING", name));



/*
  Macro: `SMOKE_TESTS_END
  END a block of unit tests
*/
`define SMOKE_TESTS_END endtask

/*
  Macro: `SMOKETEST
  START a miniTB test within an SMOKE_TEST_BEGIN/END block

  REQUIRES ACCESS TO error_count
*/
`define SMOKETEST(_NAME_) \
  begin : _NAME_ \
    string _testName = `"_NAME_`"; \
    integer local_error_count = logger.get_error_count(); \
    string fileName; \
    int lineNumber; \
\
    `INFO($psprintf(`"%s::%s::RUNNING`", name, _testName)); \
    logger.setup(); \
    smoketest_reset(); \
    logger.is_running = 1; \
    fork \
      begin \
        fork \
          begin

/*
  Macro: `SMOKETEST_END
  END a miniTB test within an SMOKE_TEST_BEGIN/END block
*/
`define SMOKETEST_END \
          end \
          begin \
            if (logger.get_error_count() == local_error_count) begin \
              logger.wait_for_error(); \
            end \
          end \
        join_any \
        disable fork; \
      end \
    join \
    logger.is_running = 0; \
    logger.teardown(); \
    if (logger.get_error_count() == local_error_count) \
      `INFO($psprintf(`"%s::%s::PASSED`", name, _testName)); \
    else \
      `INFO($psprintf(`"%s::%s::FAILED`", name, _testName)); \
    logger.update_exit_status(); \
  end
