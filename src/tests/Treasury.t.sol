// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";
import "./Utility.sol";

import "../Treasury.sol";

contract TreasuryTest is DSTest, Utility {
    Treasury treasury;
    Actor swapInterface = new Actor();

    function setUp() public {
        createActors();

        treasury = new Treasury(
            USDC,
            address(swapInterface)
        );

        treasury.transferOwnership(address(dev));
    }

    function test_treasury_init_state() public {
        assertEq(treasury.stableCurrency(), USDC);
        assertEq(treasury.swapInterfaceContract(), address(swapInterface));
        assertEq(treasury.owner(), address(dev));
    }

    // ~ updateStableReceived() Testing ~

    function test_treasury_updateStableReceived_restrictions() public {
        assert(!dev.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));
        assert(!joe.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));
        assert(!bob.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));
        assert(!val.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));
        assert(swapInterface.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));
    }

    function test_treasury_updateStableReceived_state_changes() public {

    }

}
