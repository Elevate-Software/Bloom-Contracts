// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";

import "./Utility.sol";

import "../SwapInterface.sol";

import { IERC20, IUniswapV2Router01, IWETH } from "../interfaces/InterfacesAggregated.sol";

contract SwapInterfaceTest is DSTest, Utility {
    SwapInterface swapInterface;

    function setUp() public {
        createActors();
        setUpTokens();

        swapInterface = new SwapInterface(
            USDC,
            address(dev)
        );

        dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(val));
        dev.try_addWalletToWhitelist(address(swapInterface), address(bob));
    }

    function test_swapInterface_init_state() public {
        assertEq(swapInterface.stableCurrency(), USDC);
        assertEq(swapInterface.owner(), address(dev));
        assertTrue(swapInterface.isAuthorizedUser(address(val)));
        assertTrue(swapInterface.whitelistedWallet(address(bob)));
        //TODO: check that we minted our DAI
    }


    // ~ addAuthorizedUser() Testing ~

    // addAuthorizedUser state changes.
    function test_swapInterface_addAuthorizedUser_state_changes() public { 
        // pre-state
        assert(!swapInterface.isAuthorizedUser(address(joe)));

        // state change
        assert(dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // post-state
        assert(swapInterface.isAuthorizedUser(address(joe)));
    }

    // addAuthorizedUser restrictions.
    function test_swapInterface_addAuthorizedUser_restrictions() public {
        // "joe" should not be able to call addAuthorizedUser().
        assert(!joe.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "bob" should not be able to call addAuthorizedUser().
        assert(!bob.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "val" should not be able to call addAuthorizedUser().
        assert(!val.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "dev" should be able to call addAuthorizedUser().
        assert(dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));
    }

    // ~ removeAuthorizedUser() Testing ~

    // removeAuthorizedUser state changes.
    function test_swapInterface_removeAuthorizedUser_state_changes() public {
        // pre-state
        assert(swapInterface.isAuthorizedUser(address(val)));

        // state change
        assert(dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(val)));
        
        // post-state
        assert(!swapInterface.isAuthorizedUser(address(val)));
    }

    // removeAuthorizedUser restrictions.
    function test_swapInterface_removeAuthorizedUser_restrictions() public {
        // "joe" should not be able to call removeAuthorizedUser().
        assert(!joe.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "bob" should not be able to call removeAuthorizedUser().
        assert(!bob.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "val" should not be able to call removeAuthorizedUser().
        assert(!val.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "dev" should be able to call removeAuthorizedUser().
        assert(dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));
    }

    // ~ addWalletToWhitelist() Testing ~

    // addWalletToWhitelist state changes.
    function test_swapInterface_swapInterfaceaddWalletToWhitelist_state_changes() public {
        //Pre state
        assert(!swapInterface.whitelistedWallet(address(joe)));

        //State change
        assert(dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        //Post state
        assert(swapInterface.whitelistedWallet(address(joe)));

    }

    // addWalletToWhitelist restrictions.
    function test_swapInterface_addWalletToWhitelist_restrictions() public {
        // "joe" should not be able to call addWalletToWhitelist().
        assert(!joe.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "bob" should not be able to call addWalletToWhitelist().
        assert(!bob.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "val" should be able to call addWalletToWhitelist().
        assert(val.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "dev" should be able to call addWalletToWhitelist().
        assert(dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));

    }

    // ~ removeWalletFromWhitelist() Testing ~

    // removeWalletFromWhitelist state changes.
    function test_swapInterface_removeWalletFromWhitelist_state_changes() public {
        // pre-state
        assert(swapInterface.whitelistedWallet(address(bob)));

        // state change
        assert(dev.try_removeWalletFromWhitelist(address(swapInterface), address(bob)));

        // post-state
        assert(!swapInterface.whitelistedWallet(address(bob)));
    }

    // removeWalletFromWhitelist restrictions.
    function test_swapInterface_removeWalletFromWhitelist_restrictions() public {
        // "joe" should not be able to call removeWalletFromWhitelist().
        assert(!joe.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "bob" should not be able to call removeWalletFromWhitelist().
        assert(!bob.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "val" should be able to call removeWalletFromWhitelist().
        assert(val.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "dev" should be able to call removeWalletFromWhitelist().
        assert(dev.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));
    }

    // ~ changeStableCurrency() Testing ~

    // change stable currency state changes.
    function test_swapInterface_changeStableCurrency_state_changes() public {
        // pre-state
        assertEq(swapInterface.stableCurrency(), USDC);

        // state change
        assert(dev.try_changeStableCurrency(address(swapInterface), USDT));

        // post-state
        assertEq(swapInterface.stableCurrency(), USDT);
    }

    // change stable currency restrictions.
    function test_swapInterface_changeStableCurrency_restrictions() public {
        // "joe" should not be able to call changeStableCurrency().
        assert(!joe.try_changeStableCurrency(address(swapInterface), USDT));

        // "bob" should not be able to call changeStableCurrency().
        assert(!bob.try_changeStableCurrency(address(swapInterface), USDT));

        // "val" should not be able to call changeStableCurrency().
        assert(!val.try_changeStableCurrency(address(swapInterface), USDT));

        // "dev" should be able to call changeStableCurrency().
        assert(dev.try_changeStableCurrency(address(swapInterface), USDT));
    }

    // ~ enableContract() Testing ~

    // enable contract state changes.
    function test_swapInterface_enableContract_state_changes() public {
        // pre-state
        assertTrue(!swapInterface.contractEnabled());

        // state change
        assert(dev.try_enableContract(address(swapInterface)));

        // post-state
        assertTrue(swapInterface.contractEnabled());
    }

    // enable contract restrictions
    function test_swapInterface_enableContract_restrictions() public {
        // "joe" should not be able to call enableContract().
        assert(!joe.try_enableContract(address(swapInterface)));

        // "bob" should not be able to call enableContract().
        assert(!bob.try_enableContract(address(swapInterface)));

        // "val" should not be able to call enableContract().
        assert(!val.try_enableContract(address(swapInterface)));

        // "dev" should be able to call enableContract().
        assert(dev.try_enableContract(address(swapInterface)));

    }

    // ~ disableContract() Testing ~

    // disable contract state changes.
    function test_swapInterface_disableContract_state_changes() public {
        // Dev will enable contract.
        assert(dev.try_enableContract(address(swapInterface)));

        // pre-state
        assertTrue(swapInterface.contractEnabled());

        // state change
        assert(dev.try_disableContract(address(swapInterface)));

        // post-state
        assertTrue(!swapInterface.contractEnabled());
    }

    // disable contract restrictions.
    function test_swapInterface_disableContract_restrictions() public {
        // "joe" should not be able to call disableContract().
        assert(!joe.try_disableContract(address(swapInterface)));

        // "bob" should not be able to call disableContract().
        assert(!bob.try_disableContract(address(swapInterface)));

        // "val" should not be able to call disableContract().
        assert(!val.try_disableContract(address(swapInterface)));

        // "dev" should be able to call disableContract().
        assert(dev.try_disableContract(address(swapInterface)));

    }

    // ~ updateTokenWhitelist() Testing ~

    // update token whitelist state changes.
    function test_swapInterface_updateTokenWhitelist_state_changes() public {
        // pre-state
        assert(!swapInterface.whitelistedToken(DAI));

        // state change 1 (allow DAI for token whitelist)
        assert(dev.try_updateTokenWhitelist(address(swapInterface), DAI, true));

        // post-state
        assert(swapInterface.whitelistedToken(DAI));

        // state change 2 (disallow DAI from token whitelist)
        assert(dev.try_updateTokenWhitelist(address(swapInterface), DAI, false));

        // post state 2
        assert(!swapInterface.whitelistedToken(DAI));
    }

    // update token whitelist restrictions.
    function test_swapInterface_updateTokenWhitelist_restrictions() public {
        // "joe" should not be able to call updateTokenWhitelist().
        assert(!joe.try_updateTokenWhitelist(address(swapInterface), DAI, true));

        // "bob" should not be able to call updateTokenWhitelist().
        assert(!bob.try_updateTokenWhitelist(address(swapInterface), DAI, true));

        // "val" should not be able to call updateTokenWhitelist().
        assert(!val.try_updateTokenWhitelist(address(swapInterface), DAI, true));

        // "dev" should be able to call updateTokenWhitelist().
        assert(dev.try_updateTokenWhitelist(address(swapInterface), DAI, true));
    }

    // ~ Swap Testing
    // NOTE: Must call swapInterface::swap() through try_invest since its an internal function.
    function test_swapInterface_swap_state_change() public {

        // ----------
        // DAI swap()
        // ----------

        // Allow DAI to be swapped
        dev.try_updateTokenWhitelist(address(swapInterface), DAI, true);
        mint("DAI", address(swapInterface), 1000 ether);

        // pre-state (no USDC)
        assertEq(IERC20(USDC).balanceOf(address(swapInterface)), 0 ether);
        assertEq(IERC20(DAI).balanceOf(address(swapInterface)), 1000 ether);

        // state change -
        // What are we doing?
        assert(bob.try_invest(address(swapInterface), DAI, 1000 ether));

        // post-state (swapped to USDC)
        assertGt(IERC20(USDC).balanceOf(address(swapInterface)), 0 ether);
        assertEq(IERC20(DAI).balanceOf(address(swapInterface)), 0 ether);
        emit Debug("Balance of Swap Interface USDC: ", IERC20(USDC).balanceOf(address(swapInterface)));

    }
    // ETH -> WETH -> USDT -> USDC
    // WETH -> USDT -> USDC
    // wBTC -> USDT -> USDC
    // FRAX -> USDC
    // DAI -> USDC
    // USDT -> USDC
    // accept USDC
}
