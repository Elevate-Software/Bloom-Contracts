// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./BloomContracts.sol";

contract BloomContractsTest is DSTest {
    BloomContracts contracts;

    function setUp() public {
        contracts = new BloomContracts();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
