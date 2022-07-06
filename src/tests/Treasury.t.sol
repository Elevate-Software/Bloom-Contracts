// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";

import "../Treasury.sol";

contract TreasuryTest is DSTest {
    Treasury treasury;

    function setUp() public {
        treasury = new Treasury();
    }

}
