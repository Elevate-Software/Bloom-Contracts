// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";

import "../SwapInterface.sol";

contract SwapInterfaceTest is DSTest {
    SwapInterface swapInterface;

    function setUp() public {
        swapInterface = new SwapInterface();
    }

}
