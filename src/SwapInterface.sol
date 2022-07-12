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
///          - Will we ever remove data from the mappings: ie, how does a project end?
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

    /// @notice Only authorized users can call functions with this modifier.
    modifier isAuthorized() {
        
        _;
    }

    // ---------
    // Functions
    // ---------

    // TODO: add these functions along with it's NatSpec
    // add wallet to whitelist
    // invest() -> should only be called if whitelisted
    // swap function -> uses CRV
    // change stableCurrency -> onlyOwner
    // disable/enable contract -> onlyOwner
    // update token whitelist
    // balanceOf stableCurrency

    /// TODO: Should we have a remove wallet from whitelist?
    /// @notice Adds a wallet to the whitelist.
    /// @param _address The wallet to add to the whitelist.
    function addWalletToWhitelist(address _address) public onlyOwner() {

    }

    /// @notice Allows user to invest tokens into the REIT.
    /// @param amount The amount of the token being invested.
    /// @param token The address of the token being invested.
    function invest(uint amount, address token) public {

    }

    /// @notice Calls the Curve API to swap incoming assets to USDC.
    /// TODO: Still trying to understand how this one will work, not sure what the inputs will be.
    function swap() public {

    }

    /// @notice Changes the stable currency address.
    /// @param newAddress The new stable currency contact address.
    function changeStableCurrency(address newAddress) public onlyOwner() {

    }

    /// @notice Allows owner to disable smart contract operations. (can these be external?)
    function disableContract() public onlyOwner() {

    }

    /// @notice Allows owner to re-enable contract if disabled.
    function enableContract() public onlyOwner() {

    }

    /// @notice Updates which tokens are accepted for investments.
    /// @param tokenAddress The contact address for the token we are updating.
    /// @param allow true to accept investments of this token, false to decline.
    function updateTokenWhitelist(address tokenAddress, bool allow) public onlyOwner() {

    }

    // ~ View Functions ~

    /// @notice Should return contract balance of stableCurrency.
    /// @return uint Amount of stableCurrency that is inside contract.
    function balanceOfStableCurrency() public view returns (uint) {

    }
}
