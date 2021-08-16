<?php

function system_functions() {
  exec('ls -l');

  system('ps aux');

  shell_exec('pwd');

  popen('wget example.com', 'r');

  $process = proc_open('curl example.com', [], []);

  proc_get_status($process);

  proc_terminate($process);

  proc_close($process);

  proc_nice();

  passthru('ssh user@example.com');

  escapeshellcmd('./configure '.$_POST['configure_options']);

  $str = 'This is a $string with my $name in it.';
  eval("\$str = \"$str\";");
}
