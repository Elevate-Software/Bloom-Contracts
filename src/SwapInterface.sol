// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";

// Curve Docs: https://curve.readthedocs.io/

/// @dev    This contract allows investors to invest ETH, DAI, USDT, or USDC.
///         This contract uses CRV protocol to swap investments to a specific stablecoin.
///         This contract will send all stablecoin to the Treasury for accounting.
///         Can be disabled/enabled by an admin.
///         Only whitelisted wallets can invest into the protocol.
///         To Be Determinted:
///          - Take a fee?
contract SwapInterface is Ownable{

    // ---------------
    // State Variables
    // ---------------

    address public stableCurrency;   /// @notice Used to store address of coin used to deposit/payout from Treasury.
    bool public contractEnabled;     /// @notice Bool for contract enabling / disabling investments

    mapping(address => InvestmentData) private investmentTracker;   /// @notice Tracks wallets and their individual investments made.
    mapping(address => bool) public whitelistedToken;               /// @notice Whitelist for coins accepted for investment.
    mapping(address => bool) public whitelistedWallet;              /// @notice Whitelist for wallets allowed to invest.

    /// @notice Struct used to store important data for each investment made before sent to the treasury.
    /// @param
    /// @param
    /// @param
    /// @param
    struct InvestmentData {
        address currency;
        uint amountInvested;
        uint stableCoinEquivalent;
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

    // TODO: 
    // add wallet to whitelist
    // invest()
    // swap function -> uses CRV
    // change stableCurrency -> onlyOwner
    // disable/enable contract -> onlyOwner
    // update token whitelist
}
