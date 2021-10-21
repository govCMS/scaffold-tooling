<?php

function hook_init() {
  filter_formats('test', 'test');
  system_region_list('test');
}
