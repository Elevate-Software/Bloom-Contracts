// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";
import "./Utility.sol";

import "../Treasury.sol";

contract TreasuryTest is DSTest, Utility {
    Treasury treasury;
    Actor swapInterface = new Actor();
    address UNIV2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

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
        assert(!dev.try_updateStableReceived(address(treasury),address(1),1000 * USD,block.timestamp));

        // "joe" should not be able to call updateStableReceived().
        assert(!joe.try_updateStableReceived(address(treasury),address(1),1000 * USD,block.timestamp));

        // "bob" should not be able to call updateStableReceived().
        assert(!bob.try_updateStableReceived(address(treasury),address(1),1000 * USD,block.timestamp));

        // "val" should not be able to call updateStableReceived().
        assert(!val.try_updateStableReceived(address(treasury),address(1),1000 * USD,block.timestamp));

        // "swapInterface" Actor can call updateStableReceived().
        assert(swapInterface.try_updateStableReceived(address(treasury),address(1),1000 * USD,block.timestamp));
        }

    function test_treasury_updateStableReceived_state_changes() public {
        // Pre-State Check.
        assertEq(treasury.getInvestorData(address(1)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(1)).length, 0);
        assertEq(treasury.getDividendLibrary(address(1)).length, 0);

        // SwapInterface is going to call updateStableRecieved().
        assert(swapInterface.try_updateStableReceived(address(treasury),address(1),1000 * USD,block.timestamp));

        // Post-State Check.
        assertEq(
            treasury.getInvestorData(address(1)).totalAmountInvested,
            1000 * USD
        );
        assertEq(treasury.getInvestmentLibrary(address(1)).length, 1);
        assertEq(treasury.getDividendLibrary(address(1)).length, 0);

        assertEq(
            treasury.getInvestmentLibrary(address(1))[0].amountInvested,
            1000 * USD
        );
        assertEq(
            treasury.getInvestmentLibrary(address(1))[0].timeUnix,
            block.timestamp
        );
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
        // Verify that account balance is 0.

        assertEq(treasury.balanceOfStableCurrency(), 0);

        // Add 100 to account balance.
        // Convert our ETH to WETH
        uint256 ETH_DEPOSIT = 100 ether;
        uint256 TAX_DEPOSIT = 10000 ether;

        IWETH(WETH).deposit{value: ETH_DEPOSIT}();

        IERC20(WETH).approve(address(UNIV2_ROUTER), ETH_DEPOSIT);

        // Buy USDC through Uniswap and deposit into Treasury.
        uint256 tradeAmt = 10 ether;

        IERC20(WETH).approve(address(UNIV2_ROUTER), tradeAmt);

        address[] memory path_uni_v2 = new address[](2);

        path_uni_v2[0] = WETH;
        path_uni_v2[1] = address(USDC);

        IUniswapV2Router01(UNIV2_ROUTER).swapExactTokensForTokens(
            tradeAmt,
            0,
            path_uni_v2,
            address(treasury), // Send USDC to treasury instead of msg.sender
            block.timestamp + 300
        );

        // Verify that account balance is 1000.

        assertEq(treasury.balanceOfStableCurrency(), 100);
    }
}
