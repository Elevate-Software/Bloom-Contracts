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

        uint256 swapAmount = 10 ether;

        // Allow DAI to be swapped setup.
        dev.try_updateTokenWhitelist(address(swapInterface), DAI, true);
        dev.try_addWalletToWhitelist(address(swapInterface), address(bob));
        mint("DAI", address(bob), swapAmount);

        // pre-state checks
        // contracts should have no money invested.
        assertEq(IERC20(USDC).balanceOf(swapInterface.Treasury()), 0 * USD);
        assertEq(IERC20(DAI).balanceOf(address(bob)), swapAmount);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 0);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), 0);

        // state change
        // investor Bob calls SwapInterface.invest() to invest in the REIT.
        assert(bob.try_approveToken(DAI, address(swapInterface), swapAmount));
        assert(bob.try_invest(address(swapInterface), DAI, swapAmount));

        // post-state checks
        // contracts should reflect that money has been invested.
        uint256 amountReceived = IERC20(USDC).balanceOf(swapInterface.Treasury());
        assertGt(amountReceived, 0);

        assertEq(IERC20(USDC).balanceOf(address(swapInterface)), 0 * USD);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 1);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(bob))[0].amountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob))[0].timeUnix, block.timestamp);

        assertEq(IERC20(address(bloomToken)).totalSupply(), amountReceived * 10**12);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), amountReceived * 10**12);

    }

    function test_BloomMainDeployment_investETH() public {
        
        // Allow WETH to be swapped setup.
        dev.try_addWalletToWhitelist(address(swapInterface), address(bob));
        dev.try_updateTokenWhitelist(address(swapInterface), WETH, true);

        // pre-state checks
        // contracts should have no money invested.
        assertEq(IERC20(USDC).balanceOf(swapInterface.Treasury()), 0 * USD);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, 0);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 0);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(IERC20(address(bloomToken)).totalSupply(), 0);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), 0);

        // state change
        // investor Bob calls SwapInterface.invest() to invest in the REIT.
        assert(bob.try_investETH{value: 10 ether}(address(swapInterface)));

        // post-state checks
        // contracts should reflect that money has been invested.
        uint256 amountReceived = IERC20(USDC).balanceOf(swapInterface.Treasury());
        assertGt(amountReceived, 0);

        assertEq(IERC20(USDC).balanceOf(address(swapInterface)), 0 * USD);

        assertEq(treasury.getInvestorData(address(bob)).totalAmountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob)).length, 1);
        assertEq(treasury.getDividendLibrary(address(bob)).length, 0);

        assertEq(treasury.getInvestmentLibrary(address(bob))[0].amountInvested, amountReceived);
        assertEq(treasury.getInvestmentLibrary(address(bob))[0].timeUnix, block.timestamp);

        assertEq(IERC20(address(bloomToken)).totalSupply(), amountReceived * 10**12);
        assertEq(IERC20(address(bloomToken)).balanceOf(address(bob)), amountReceived * 10**12);

    }

}