// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";
import "./Utility.sol";

import "../Treasury.sol";

import "../BloomToken.sol";

contract TreasuryTest is DSTest, Utility {
    Treasury treasury;
    BloomToken bloomToken;

    Actor swapInterface = new Actor();

    function setUp() public {
        createActors();

        bloomToken = new BloomToken(
            0, // NOTE: DO NOT ADD 18 ZEROS, when deployed set to 0
            18,
            "BloomToken",
            "BLOOM",
            address(dev)
        );

        treasury = new Treasury(
            USDC,
            address(swapInterface),
            address(bloomToken),
            address(dev)
        );

        assert(dev.try_setTreasury(address(bloomToken), address(treasury)));
    }

    function test_treasury_init_state() public {
        assertEq(treasury.stableCurrency(), USDC);
        assertEq(treasury.swapInterfaceContract(), address(swapInterface));
        assertEq(treasury.owner(), address(dev));
    }

    // ~ updateStableReceived() Testing ~

    function test_treasury_updateStableReceived_restrictions() public {
        // "dev" should not be able to call updateStableReceived().
        assert(!dev.try_updateStableReceived(address(treasury),address(1),1000 * USD, block.timestamp));

        // "joe" should not be able to call updateStableReceived().
        assert(!joe.try_updateStableReceived(address(treasury),address(1),1000 * USD, block.timestamp));

        // "bob" should not be able to call updateStableReceived().
        assert(!bob.try_updateStableReceived(address(treasury),address(1),1000 * USD, block.timestamp));

        // "val" should not be able to call updateStableReceived().
        assert(!val.try_updateStableReceived(address(treasury),address(1),1000 * USD, block.timestamp));

        // "swapInterface" Actor can call updateStableReceived().
        assert(swapInterface.try_updateStableReceived(address(treasury),address(1),1000 * USD, block.timestamp));

        // "swapInterface" cannot mint tokens to the dead address.
        assert(!swapInterface.try_updateStableReceived(address(treasury), address(0), 1000 * USD, block.timestamp));

        // "swapInterface" cannot mint 0 tokens.
        assert(!swapInterface.try_updateStableReceived(address(treasury), address(1), 0, block.timestamp));
    }

    function test_treasury_updateStableReceived_state_changes() public {
        // Pre-State Check.
        assertEq(treasury.getInvestorData(address(1)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(1)).length, 0);
        assertEq(treasury.getDividendLibrary(address(1)).length, 0);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(1)), 0);

        // SwapInterface is going to call updateStableRecieved().
        assert(swapInterface.try_updateStableReceived(address(treasury),address(1),1674 * USD, block.timestamp));

        // Post-State Check.
        assertEq(treasury.getInvestorData(address(1)).totalAmountInvested,1674 * USD);
        assertEq(treasury.getInvestmentLibrary(address(1)).length, 1);
        assertEq(treasury.getDividendLibrary(address(1)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(1))[0].amountInvested,1674 * USD);
        assertEq(treasury.getInvestmentLibrary(address(1))[0].timeUnix,block.timestamp);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 1674 * WAD);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(1)), 1674 * WAD);
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
        assertEq(treasury.getNumOfAuthorizedUsers(), 1);
        assertTrue(!treasury.getAuthorizedUser(address(1)));

        // State-change.
        assert(dev.try_addAuthorizedUser(address(treasury), address(1)));

        // Post-State Check.
        assertEq(treasury.getNumOfAuthorizedUsers(), 2);
        assertTrue(treasury.getAuthorizedUser(address(1)));
    }

    // ~ removeAuthorizedUser() Testing ~

    function test_treasury_removeAuthorizedUser_restrictions() public {
        // add joe to array.
        assert(dev.try_addAuthorizedUser(address(treasury), address(joe)));

        // "dev" is able to remove joe from the array.
        assert(dev.try_removeAuthorizedUser(address(treasury), address(joe)));

        // "dev" should not be able to remove a wallet that is not inside the array.
        assert(!dev.try_removeAuthorizedUser(address(treasury), address(joe)));

        // "bob" should not be able to call removeAuthorizedUser().
        assert(!bob.try_removeAuthorizedUser(address(treasury), address(joe)));

        // "val" should not be able to call removeAuthorizedUser().
        assert(!val.try_removeAuthorizedUser(address(treasury), address(joe)));

        // "joe" should not be able to call removeAuthorizedUser().
        assert(!joe.try_removeAuthorizedUser(address(treasury), address(val)));
    }

    function test_treasury_removeAuthorizedUser_state_changes() public {
        assert(dev.try_addAuthorizedUser(address(treasury), address(joe)));

        // Pre-State Check.
        // lets us know if joe is actually inside the array.
        assertEq(treasury.getNumOfAuthorizedUsers(), 2);
        assert(treasury.getAuthorizedUser(address(joe)));

        // State-Change.
        // Is popping joe out of the array.
        assert(dev.try_removeAuthorizedUser(address(treasury), address(joe)));

        // Post-State-Check.
        // Tells us if joe is popped out of the array.
        assertEq(treasury.getNumOfAuthorizedUsers(), 1);
        assert(!treasury.getAuthorizedUser(address(joe)));
    }

   
}
