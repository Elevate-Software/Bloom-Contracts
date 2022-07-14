// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";
import "./Utility.sol";

import "../BloomToken.sol";

contract BloomTokenTest is DSTest, Utility {
    BloomToken bloomToken;


    function setUp() public {
        createActors();

        bloomToken = new BloomToken(
            1000 ether,
            18,
            "BloomToken",
            "BLOOM",
            address(dev)
        );
    }

}
