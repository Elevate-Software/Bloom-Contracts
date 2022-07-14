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

        treasury = new Treasury(USDC, address(swapInterface));

        treasury.transferOwnership(address(dev));
    }

    function test_treasury_init_state() public {
        assertEq(treasury.stableCurrency(), USDC);
        assertEq(treasury.swapInterfaceContract(), address(swapInterface));
        assertEq(treasury.owner(), address(dev));
    }

    // ~ updateStableReceived() Testing ~

    function test_treasury_updateStableReceived_restrictions() public {
        // "dev" should not be able to call updateStableReceived().
        assert(!dev.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));

        // "joe" should not be able to call updateStableReceived().
        assert(!joe.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));

        // "bob" should not be able to call updateStableReceived().
        assert(!bob.try_updateStableReceived(address(treasury), address(1), 1000 * USD,block.timestamp));

        // "val" should not be able to call updateStableReceived().
        assert(!val.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));

        // "swapInterface" Actor can call updateStableReceived().
        assert(swapInterface.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));
    }

    function test_treasury_updateStableReceived_state_changes() public {
        // Pre-State Check.
        assertEq(treasury.getInvestorData(address(1)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(1)).length, 0);
        assertEq(treasury.getDividendLibrary(address(1)).length, 0);

        // SwapInterface is going to call updateStableRecieved().
        assert(swapInterface.try_updateStableReceived(address(treasury), address(1), 1000 * USD, block.timestamp));

        // Post-State Check.
        assertEq(treasury.getInvestorData(address(1)).totalAmountInvested, 1000 * USD);
        assertEq(treasury.getInvestmentLibrary(address(1)).length, 1);
        assertEq(treasury.getDividendLibrary(address(1)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(1))[0].amountInvested, 1000 * USD);
        assertEq(treasury.getInvestmentLibrary(address(1))[0].timeUnix, block.timestamp);
    }

    // ~ mintBloom() Testing ~

    function test_treasury_mintBloom_restrictions() public {
        // Write test function. tryFunc is written
    }

    // ~ addAuthorizedUser() Testing ~

    function test_treasury_addAuthorizedUser_restrictions() public {
        // "dev" should be able to call addAuthorizedUser().
        assert(dev.try_addAuthorizedUser(address(treasury), address(1)));

        // "dev" cannot add address(1) to the authorizedUser array. Was already added.
        assert(!dev.try_addAuthorizedUser(address(treasury), address(1)));

        // "bob" should not be able to call addAuthorizedUser().
        assert(!bob.try_addAuthorizedUser(address(treasury), address(1)));

        // "val" should not be able to call addAuthorizedUser().
        assert(!val.try_addAuthorizedUser(address(treasury), address(1)));

        // "joe" should not be able to call addAuthorizedUser().
        assert(!joe.try_addAuthorizedUser(address(treasury), address(1)));
    }

    function test_treasury_addAuthorizedUser_state_changes() public {
        // Pre-State Check.

        // State-change.

        // Post-State Check.
    }
}
