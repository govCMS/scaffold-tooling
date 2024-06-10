<?php

function _banned_functions() {
  dd('foobar');

  debug_backtrace('something');

  $mysqli = new mysqli("localhost","my_user","my_password","my_db");
  $mysqli->close();
}
