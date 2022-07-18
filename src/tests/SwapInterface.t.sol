// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";

import "./Utility.sol";

import "../SwapInterface.sol";

contract SwapInterfaceTest is DSTest, Utility {
    SwapInterface swapInterface;

    function setUp() public {
        createActors();

        swapInterface = new SwapInterface(
            USDC,
            address(dev)
        );

        dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(val));
        dev.try_addWalletToWhitelist(address(swapInterface), address(bob));
    }


    // ~ Authorized Users ~

    // addAuthorizedUser state changes
    function test_addAuthorizedUser() public {
        // pre-state
        assert(!swapInterface.isAuthorizedUser(address(joe)));

        // state change
        assert(dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // post-state
        assert(swapInterface.isAuthorizedUser(address(joe)));
    }

    // addAuthorizedUser restrictions
    function test_addAuthorizedUser_restriction() public {
        // "joe" should not be able to call addAuthorizedUser().
        assert(!joe.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "bob" should not be able to call addAuthorizedUser().
        assert(!bob.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "val" should not be able to call addAuthorizedUser().
        assert(!val.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));

        // "dev" should be able to call addAuthorizedUser().
        assert(dev.try_addWalletToAuthorizedUsers(address(swapInterface), address(joe)));
    }

    // removeAuthorizedUser state changes
    function test_removeAuthorizedUser() public {
        // pre-state
        assert(swapInterface.isAuthorizedUser(address(val)));

        // state change
        assert(dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(val)));
        
        // post-state
        assert(!swapInterface.isAuthorizedUser(address(val)));
    }

    // removeAuthorizedUser restrictions
    function test_removeAuthorizedUser_restriction() public {
        // "joe" should not be able to call removeAuthorizedUser().
        assert(!joe.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "bob" should not be able to call removeAuthorizedUser().
        assert(!bob.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "val" should not be able to call removeAuthorizedUser().
        assert(!val.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));

        // "dev" should be able to call removeAuthorizedUser().
        assert(dev.try_removeWalletFromAuthorizedUsers(address(swapInterface), address(joe)));
    }

    // ~ Whitelists

    // addWalletToWhitelist state changes
    function test_addWalletToWhitelist() public {
        //Pre state
        assert(!swapInterface.whitelistedWallet(address(joe)));

        //State change
        assert(dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        //Post state
        assert(swapInterface.whitelistedWallet(address(joe)));

    }

    // addWalletToWhitelist restrictions
    function test_addWalletToWhitelist_restriction() public {
        // "joe" should not be able to call addWalletToWhitelist().
        assert(!joe.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "bob" should not be able to call addWalletToWhitelist().
        assert(!bob.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "val" should be able to call addWalletToWhitelist().
        assert(val.try_addWalletToWhitelist(address(swapInterface), address(joe)));

        // "dev" should be able to call addWalletToWhitelist().
        assert(dev.try_addWalletToWhitelist(address(swapInterface), address(joe)));

    }

    // removeWalletFromWhitelist state changes
    function test_removeWalletFromWhitelist() public {
        // pre-state
        assert(swapInterface.whitelistedWallet(address(bob)));

        // state change
        assert(dev.try_removeWalletFromWhitelist(address(swapInterface), address(bob)));

        // post-state
        assert(!swapInterface.whitelistedWallet(address(bob)));
    }

    // removeWalletFromWhitelist restrictions
    function test_removeWalletFromWhitelist_restriction() public {
        // "joe" should not be able to call removeWalletFromWhitelist().
        assert(!joe.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "bob" should not be able to call removeWalletFromWhitelist().
        assert(!bob.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "val" should be able to call removeWalletFromWhitelist().
        assert(val.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));

        // "dev" should be able to call removeWalletFromWhitelist().
        assert(dev.try_removeWalletFromWhitelist(address(swapInterface), address(joe)));
    }

}
