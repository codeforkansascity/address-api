<?php
/**
 * Created by PhpStorm.
 * User: james
 * Date: 4/24/2016
 * Time: 3:46 PM
 */
class HelloTest extends PHPUnit_Framework_TestCase
{
    // ...

    public function testHelloTest()
    {
        // Arrange
        $a = "Hello";

        // Act
        $b = $a . " World";

        // Assert
        $this->assertEquals("Hello World", $b);
    }

    // ...
}

