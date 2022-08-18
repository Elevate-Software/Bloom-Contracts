// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../../lib/ds-test/src/test.sol";

import "./Utility.sol";

import "../SwapInterface.sol";

import "../Treasury.sol";

import "../BloomToken.sol";

import "../SwapInterface.sol";

import { IUniswapV2Router01, IWETH } from "../interfaces/InterfacesAggregated.sol";

contract BloomMainDeploymentTest is DSTest, Utility {
    SwapInterface swapInterface;
    Treasury treasury;
    BloomToken bloomToken;

    function setUp() public {
        createActors();
        setUpTokens();

        swapInterface = new SwapInterface(
            USDC,
            address(dev)
        );

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


        // ~ manually set variables ~
        // bloomToken
        dev.try_setTreasury(address(bloomToken), address(treasury));

        // treasury
        dev.try_updateSwapInterface(address(treasury), address(swapInterface));

        // swapInterface
        dev.try_updateTreasury(address(swapInterface), address(treasury));
        dev.try_enableContract(address(swapInterface));
    }


    function test_BloomMainDeployment_init_state() public {

        // bloomToken init verification
        assertEq(bloomToken.totalSupply(), 0 ether);
        assertEq(bloomToken.decimals(), 18);
        assertEq(bloomToken.name(), "BloomToken");
        assertEq(bloomToken.symbol(), "BLOOM");
        assertEq(bloomToken.owner(), address(dev));
        assertEq(bloomToken.balanceOf(address(dev)), 0 ether);
        assertEq(bloomToken.treasury(), address(treasury));

        // treasury init verification
        assertEq(treasury.stableCurrency(), USDC);
        assertEq(treasury.owner(), address(dev));
        assertEq(treasury.swapInterfaceContract(), address(swapInterface));
        assertEq(treasury.bloomToken(), address(bloomToken));

        // swapInterface init verification
        assertEq(swapInterface.stableCurrency(), USDC);
        assertEq(swapInterface.owner(), address(dev));
        assertEq(swapInterface.Treasury(), address(treasury));
        assertTrue(swapInterface.treasurySet());
        assertTrue(swapInterface.contractEnabled());
    }

    function test_BloomMainDeployment_invest() public {
        
    }

}