<?php

function _banned_functions() {
  dd('foobar');

  debug_backtrace('something');
}
