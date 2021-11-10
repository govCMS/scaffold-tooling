<?php

interface foo {}

class_alias(\Foo::class, 'Drupal\markdown\Plugin\Markdown\AllowedHtmlInterface');
class_alias(\Foo::class, 'Drupal\markdown\Plugin\Markdown\ParserInterface');
