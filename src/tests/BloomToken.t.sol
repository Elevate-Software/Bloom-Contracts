// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";

import "../BloomToken.sol";

contract BloomTokenTest is DSTest {
    BloomToken bloomToken;

    function setUp() public {
        bloomToken = new BloomToken();
    }

}
