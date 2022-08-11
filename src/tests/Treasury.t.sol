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
        setUpTokens();

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

    function test_treasury_updateStableReceived_decimal_conversion() public {
        // Change stableCurrency to a stablecoin with a decimal precision != 6.
        dev.try_updateStableCurrency(address(treasury), DAI);

        // Pre-State Check.
        assertEq(treasury.getInvestorData(address(1)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(1)).length, 0);
        assertEq(treasury.getDividendLibrary(address(1)).length, 0);
        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(1)), 0);

        // SwapInterface is going to call updateStableRecieved().
        assert(swapInterface.try_updateStableReceived(address(treasury),address(1),1674 * WAD, block.timestamp));

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

    // ~ balanceOfStableCurrency() Testing ~

    function test_treasury_balanceOfStableCurrency_state_changes() public {
        // Pre-State Check.
        // Assert the balance of stableCurrency inside of the treasury is equal to 0.
        assertEq(IERC20(treasury.stableCurrency()).balanceOf(address(treasury)), 0);
        assertEq(treasury.balanceOfStableCurrency(), 0);

        // State-Change.
        // Add funds to contract balance of stableCurrency inside Treasury.sol.
        mint("USDC", address(treasury), 1000 * USD);

        // Post-State Check.
        // Assert the balance of stableCurrency inside of the treasury is equal to 1000.
        assertEq(IERC20(treasury.stableCurrency()).balanceOf(address(treasury)), 1000 * USD);
        assertEq(treasury.balanceOfStableCurrency(), 1000 * USD);
    }

    // ~ safeWithdraw() Testing ~

    function test_treasury_safeWithdraw_restrictions() public {
      // Make sure our safeWithdraw function does not allow users to withdraw with 0 funds available.
      assert(!dev.try_safeWithdraw(address(treasury), USDC));
        
      // Add funds to contract balance of stableCurrency inside Treasury.sol.
      mint("USDC", address(treasury), 1033 * USD);
      
      // "dev" should be able to call safeWithdraw().
      assert(dev.try_safeWithdraw(address(treasury), USDC));

      // "bob" should not be able to call safeWithdraw().
      assert(!bob.try_safeWithdraw(address(treasury), USDC));

      // "joe" should not be able to call safeWithdraw().
      assert(!joe.try_safeWithdraw(address(treasury), USDC));

      // "val" should not be able to call safeWithdraw().
      assert(!val.try_safeWithdraw(address(treasury), USDC));
    }

    function test_treasury_safeWithdraw_state_changes() public {
        // Make sure funds are in the treasury for a withdraw to occur.
        assertEq(IERC20(treasury.stableCurrency()).balanceOf(address(treasury)), 0);
        mint("USDC", address(treasury), 2000 * USD);
        assertEq(IERC20(treasury.stableCurrency()).balanceOf(address(treasury)), 2000 * USD);

        // Pre-State check.
        // Makes sure dev has a balance of 0.
        assertEq(IERC20(treasury.stableCurrency()).balanceOf(address(dev)), 0);
        
        // State-Change.
        assert(dev.try_safeWithdraw(address(treasury), USDC));


        // Post-State check.
        // Dev now should have 2000 USD, which indicates a successful withdraw.
        assertEq(IERC20(treasury.stableCurrency()).balanceOf(address(dev)), 2000 * USD);
        assertEq(IERC20(treasury.stableCurrency()).balanceOf(address(treasury)), 0);
         
    }
}
