// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";

/// @dev    The Treasury contract will be the focal point within the protocol.
///         This contract will keep track of all accounting
///         It will account for all assets, investors, and dividends for all
///         projects within the Bloom Project.
///         This contract calls mint() on BloomToken.sol
///         This contract recieves USDC or other stablecoins from SwapInterface.sol
///         This contract tracks all BTC invested into the Circle acc. updateBtcReceived() called by bot.
///         This contract also can send USDC or other stablecoin to our Circle acc.
///         To be determined:
///          - What values we need to return for front end?
///          - Are we keeping track of projects or just investments?
contract Treasury is Ownable {

    // ---------------
    // State Variables
    // ---------------

    address public stableCurrency;                               /// @notice Used to store address of coin used to deposit/payout from Treasury.
    mapping(address => InvestorData) private investorLibrary;    /// @notice Mapping of Investor wallets to their investment data held in InvestorData.
    mapping(address => bool) public isAuthorizedUser;            /// @notice isAuthorizedUser[address] returns true if wallet is authorized;

    /// @notice Investor srtruct is used to track data points of investments made by investors.
    /// @param amountInvested Tracks USD-stablecoin equivalent to investment made.
    /// @param dividendsReceived Tracks dividends received by investor in stablecoin.
    struct InvestorData {
        uint totalAmountInvested;
        uint totalDividendsReceived;
        InvestmentReceipt[] investmentLibrary;
        DividendReceipt[] dividendLibrary;
    }

    /// TODO: Will
    /// @notice this does this
    /// @param 
    /// @param
    struct InvestmentReceipt {
        uint amountInvested;
        uint timeUnix;
    }

    /// TODO: Marcus
    struct DividendReceipt {
        uint dividendPaid;
        uint timeUnix;
    }

    // -----------
    // Constructor
    // -----------

    /// @notice Initializes Treasury.sol 
    /// @param _stableCurrency Used to store address of stablecoin used in contract (default is USDC).
    constructor (
        address _stableCurrency
    ) {
        stableCurrency = _stableCurrency;

        transferOwnership(msg.sender);
        isAuthorizedUser[msg.sender] = true;
    }

    // ------
    // Events
    // ------

    // TODO: Add any necessary events.

    // ---------
    // Modifiers
    // ---------

    // TODO: isAuthorized modifier goes here.

    // ---------
    // Functions
    // ---------

    /// @notice Withdraw stableCurrency from contract to a Circle acc.
    function withdrawToCircle() public {

    }

    /// @notice Updates investment values when a BTC investment is made.
    /// @dev    Function called by python bot.
    function updateBtcReceived() public {

    }

    /// @notice Updates investment values when an investment is made through Dapp.
    /// @dev    Should only be called by SwapInterface.sol.
    function updateStableReceived() public {

    }

    /// @notice Mints BLOOM tokens to a certain investor.
    /// @dev    Calls BloomToken.sol::mint().
    function mintBloom() public {

    }

    /// @notice Allows an admin (owner) to add/remove an authorized user.
    function updateAuthorizedUser() public onlyOwner() {

    }

    // ~ View Functions ~

    /// @notice Should return contract balance of stableCurrency.
    /// @return uint Amount of stableCurrency is inside contract.
    function balanceOfStableCurrency() public view returns (uint) {

    }

    /// TODO: Add necessary view functions.
    /// @dev Think about what values in here are important that need to be viewed later on.

    /// TODO: Setup contract for dividend payouts.
    /// TODO: add updateStableCurrency variable.
    /// TODO: have a safeWithdraw
}
