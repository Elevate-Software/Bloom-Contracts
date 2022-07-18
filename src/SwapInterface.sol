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
    mapping(address => bool) public isAuthorizedUser;               /// @notice Admin wallets be added to this mapping.

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
        address _stableCurrency,
        address _admin
    ) {
        stableCurrency = _stableCurrency;

        transferOwnership(_admin);
        isAuthorizedUser[owner()] = true;
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
        require(isAuthorizedUser[msg.sender] == true, "SwapInterface.sol::isAuthorized() User is not authorized.");
        _;
    }

    /// @notice Only whitelisted users can call functions with this modifier.
    modifier isWhitelistedWallet() {
        require(whitelistedWallet[msg.sender] == true, "SwapInterface.sol::isWhitelistedWallet() User is not authorized.");
        _;
    }

    // ---------
    // Functions
    // ---------

    /// @notice Adds an authorized user.
    /// @param _address The address to add as authorized user.
    function addAuthorizedUser(address _address) external onlyOwner() {
        isAuthorizedUser[_address] = true;
    }

    /// @notice Removes an authorized user.
    /// @param _address The address to remove as authorized user.
    function removeAuthorizedUser(address _address) external onlyOwner() {
        isAuthorizedUser[_address] = false;
    }


    /// @notice Adds a wallet to the whitelist.
    /// @param _address The wallet to add to the whitelist.
    function addWalletToWhitelist(address _address) external isAuthorized() {
        whitelistedWallet[_address] = true;
    }

    /// @notice Removes a wallet from the whitelist.
    /// @param _address The wallet to remove from the whitelist.
    function removeWalletFromWhitelist(address _address) external isAuthorized() {
        whitelistedWallet[_address] = false;
    }

    /// @notice Allows user to invest tokens into the REIT.
    /// @param amount The amount of the token being invested.
    /// @param token The address of the token being invested.
    function invest(uint amount, address token) public isWhitelistedWallet() {

    }

    /// @notice Calls the Curve API to swap incoming assets to USDC.
    function swap() internal { // params?

    }

    /// @notice Changes the stable currency address.
    /// @param newAddress The new stable currency contact address.
    function changeStableCurrency(address newAddress) public onlyOwner() {
        stableCurrency = newAddress;
    }

    /// @notice Allows owner to disable smart contract operations.
    function disableContract() external onlyOwner() {
        contractEnabled = false;
    }

    /// @notice Allows owner to enable contract if disabled.
    function enableContract() external onlyOwner() {
        contractEnabled = true;
    }

    /// @notice Updates which tokens are accepted for investments.
    /// @param tokenAddress The contact address for the token we are updating.
    /// @param allowed true to accept investments of this token, false to decline.
    function updateTokenWhitelist(address tokenAddress, bool allowed) public onlyOwner() {
        whitelistedToken[tokenAddress] = allowed;
    }

    // ~ View Functions ~

    /// @notice Should return contract balance of stableCurrency.
    /// @return uint Amount of stableCurrency that is inside contract.
    function balanceOfStableCurrency() public view returns (uint) {

    }
}
