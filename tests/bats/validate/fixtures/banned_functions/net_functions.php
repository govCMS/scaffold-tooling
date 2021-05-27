<?php

function curl_functions() {
  $ch = curl_init();
  curl_exec($ch);

  $mh = curl_multi_init();
  curl_multi_exec($mh, 0);
}

function ftp_functions() {
  $conn_id = ftp_connect('ftp.example.com');

  ftp_exec($conn_id, 'ls -al');

  ftp_get($conn_id, '', '');

  ftp_login($conn_id, '', '');

  ftp_nb_fput($conn_id, '', fopen('', r), FTP_BINARY);

  ftp_put($conn_id, '', '');

  ftp_raw($conn_id, '');

  ftp_rawlist($conn_id, '');
}
