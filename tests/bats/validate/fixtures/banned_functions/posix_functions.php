<?php

function posix_functions() {
  posix_getpwuid(1000);

  posix_kill(1000, SIGKILL);

  posix_mkfifo('/tmp/testmkfifo', 0644);

  posix_setpgid(1000, 1000);

  posix_setsid();

  posix_setuid(1000);

  posix_uname();
}
