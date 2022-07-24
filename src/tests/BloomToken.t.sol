// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";
import "./Utility.sol";

import "../BloomToken.sol";

contract BloomTokenTest is DSTest, Utility {
    BloomToken bloomToken;

    function setUp() public {

        createActors();
        // dev - Owner/Dev
        // joe - Normal Person
        // bob - Investor
        // val - Admin/authorizedUser

        bloomToken = new BloomToken(
            100000, // NOTE: DO NOT ADD 18 ZEROS, when deployed set to 0.
            18,
            "BloomToken",
            "BLOOM",
            address(dev)
        );

    }
    
    function test_bloomToken_init_state() public {
        assertEq(bloomToken.totalSupply(), 100000 ether);
        assertEq(bloomToken.decimals(), 18);
        assertEq(bloomToken.name(), "BloomToken");
        assertEq(bloomToken.symbol(), "BLOOM");
        assertEq(bloomToken.owner(), address(dev));
        assertEq(bloomToken.balanceOf(address(dev)), 100000 ether);
    }

    // ~ transfer() ~

    function test_bloomToken_transfer_restrictions() public {

        // "dev" can transfer 10,000 tokens to bob the investor.
        assert(dev.try_transferToken(address(bloomToken), address(bob), 10000 ether));

        // "dev" cannot transfer amount == 0.
        assert(!dev.try_transferToken(address(bloomToken), address(bob), 0 ether));

        // "bob" cannot transfer tokens to a non-exception wallet.
        assert(!bob.try_transferToken(address(bloomToken), address(joe), 1000 ether));

        // "bob" cannot transfer more tokens than what he's currently holding.
        assert(!bob.try_transferToken(address(bloomToken), address(dev), 20000 ether));

        // "bob" CAN transfer his tokens to the owner wallet since owner is an exception.
        // TODO: Consider not allowing tokens to be sent anywhere except burn address?
        //       this might be sufficient. Up for discussion.
        assert(bob.try_transferToken(address(bloomToken), address(dev), 10000 ether));
    }

    function test_bloomToken_transfer_state_changes() public {
        // Pre-state check.
        uint preBalDev = bloomToken.balanceOf(address(dev));
        uint preBalBob = bloomToken.balanceOf(address(bob));

        // Dev will send 10,000 tokens to an investor, bob.
        assert(dev.try_transferToken(address(bloomToken), address(bob), 10000 ether));

        // Post-state check.
        uint postBalDev = bloomToken.balanceOf(address(dev));
        uint postBalBob = bloomToken.balanceOf(address(bob));

        assertEq(preBalDev - postBalDev, 10000 ether);
        assertEq(postBalBob - preBalBob, 10000 ether);
    }

    // ~ approve() ~

    // TODO

    // ~ transferFrom() ~

    // TODO

    // ~ updateException ~

    // TODO

    // ~ mint() Testing ~

    // Test mint() from an admin.
    function test_bloomToken_mint() public {
        // Pre-state check.
        assertEq(bloomToken.balanceOf(address(bob)), 0);
        assertEq(bloomToken.totalSupply(), 100000 ether);

        // Mint 10 tokens to bob.
        assert(dev.try_mint(address(bloomToken), address(bob), 10 ether));

        //Post-state check.
        assertEq(bloomToken.balanceOf(address(bob)), 10 ether);
        assertEq(bloomToken.totalSupply(), 100010 ether);
    }

    // Test mint() from a non-admin
    function test_bloomToken_mint_restrictions() public {
        // Joe attempts to mint himself tokens.
        assert(!joe.try_mint(address(bloomToken), address(joe), 10 ether));

        // Val attempts to mint himself tokens.
        assert(!val.try_mint(address(bloomToken), address(val), 10 ether));

        // Bob attempts to mint himself tokens.
        assert(!bob.try_mint(address(bloomToken), address(bob), 10 ether));

        // Admin cannot mint to 0 address.
        assert(!dev.try_mint(address(bloomToken), address(0), 10 ether));

        // Admin can successfully perform a mint.
        assert(dev.try_mint(address(bloomToken), address(dev), 10 ether));
    }

    // ~ burn ~

    // Test mint() from an admin
    function test_bloomToken_burn() public {
        // Mint Bloom tokens for testing.
        assert(dev.try_mint(address(bloomToken), address(bob), 10 ether));

        //Verify balance and supply.
        assertEq(bloomToken.balanceOf(address(bob)), 10 ether);
        assertEq(bloomToken.totalSupply(), 100010 ether);

        assert(dev.try_burn(address(bloomToken), address(bob), 10 ether));

        //Verify balance and supply.
        assertEq(bloomToken.balanceOf(address(bob)), 0 ether);
        assertEq(bloomToken.totalSupply(), 100000 ether);
    }

    // Test burn() from a non-admin
    function test_bloomToken_burn_restrictions() public {
        // Mint Bloom tokens for testing.
        assert(dev.try_mint(address(bloomToken), address(dev), 10 ether));

        // Joe attempts to burn himself tokens.
        assert(!joe.try_burn(address(bloomToken), address(joe), 10 ether));

        // Val attempts to burn himself tokens.
        assert(!val.try_burn(address(bloomToken), address(val), 10 ether));

        // Bob attempts to burn himself tokens.
        assert(!bob.try_burn(address(bloomToken), address(bob), 10 ether));

        // Admin cannot burn to 0 address.
        assert(!dev.try_burn(address(bloomToken), address(0), 10 ether));

        // Admin can successfully perform a burn.
        assert(dev.try_burn(address(bloomToken), address(dev), 10 ether));
    }

}