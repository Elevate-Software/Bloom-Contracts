// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";
import { SafeERC20 } from "./OpenZeppelin/SafeERC20.sol";
import { IERC20, IWETH, ITreasury, curve3PoolStableSwap, curveFraxUSDCStableSwap, curveTriCrypto2StableSwap } from "./interfaces/InterfacesAggregated.sol";

import { IERC20 } from "./interfaces/InterfacesAggregated.sol";

// Curve Docs: https://curve.readthedocs.io/

/// @dev    This contract allows investors to invest ETH, DAI, USDT, FRAX, WETH, WBTC, or USDC.
///         This contract uses CRV protocol to swap investments to a specific stablecoin.
///         This contract will send all stablecoin to the Treasury for accounting.
///         Can be disabled/enabled by an admin.
///         Only whitelisted wallets can invest into the protocol.
///         TODO (TBD):
///          - Take a fee?
///          - Will we ever remove data from the mappings: ie, how does a project end?


contract SwapInterface is Ownable{

    // ---------------
    // State Variables
    // ---------------
    event Debug(string, uint256);

    using SafeERC20 for IERC20;

    address public stableCurrency;      /// @notice Used to store address of coin used to deposit/payout from Treasury.
    bool public contractEnabled;        /// @notice Bool for contract enabling / disabling investments.
    bool public treasurySet;            /// @notice Bool to make sure treasury has been set.

    address public Treasury;            /// @notice Used to transfer USDC to treasury.

    mapping(address => bool) public whitelistedToken;               /// @notice Whitelist for coins accepted for investment.
    mapping(address => bool) public whitelistedWallet;              /// @notice Whitelist for wallets allowed to invest.
    mapping(address => bool) public isAuthorizedUser;               /// @notice Admin wallets be added to this mapping.

    // contract addresses
    address constant DAI   = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT  = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant FRAX  = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address constant WETH  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant WBTC  = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    // curve swap addresses
    address constant _3POOL_SWAP_ADDRESS = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address constant _FRAXUSDC_SWAP_ADDRESS = 0xDcEF968d416a41Cdac0ED8702fAC8128A64241A2;
    address constant _TRICRYPTO2_SWAP_ADDRESS = 0xD51a44d3FaE010294C616388b506AcdA1bfAAE46;


    // -----------
    // Constructor
    // -----------

    /// @notice Initializes SwapInterface.sol 
    /// @param _stableCurrency Used to store address of stablecoin used in contract.
    /// @param _admin Wallet address of owner account.
    constructor (
        address _stableCurrency,
        address _admin
    ) {
        // zero address checks
        require(_stableCurrency != address(0), "SwapInterface.sol::constructor() _stableCurrency not set");
        require(_admin != address(0), "SwapInterface.sol::constructor() _admin not set");

        stableCurrency = _stableCurrency;

        transferOwnership(_admin);
        isAuthorizedUser[owner()] = true;
    }

    // ------
    // Events
    // ------

    event AuthorizedUserUpdated(address indexed user, bool isAuthorized);

    event InvestmentReceived(uint256 amountInvestedUSDC);

    event ContractStateUpdated(bool isEnabled);

    event TreasuryAddressUpdated(address treasuryAddress);

    event TokenWhitelistStateUpdated(address token, bool isAllowed);

    event StableCurrencyUpdated(address currentStable, address newStable);


    // ---------
    // Modifiers
    // ---------

    /// @notice Only authorized users can call functions with this modifier.
    modifier isAuthorized() {
        require(isAuthorizedUser[msg.sender], "SwapInterface.sol::isAuthorized() User is not authorized");
        _;
    }

    /// @notice Only whitelisted users can call functions with this modifier.
    modifier isWhitelistedWallet() {
        require(whitelistedWallet[msg.sender], "SwapInterface.sol::isWhitelistedWallet() User is not authorized");
        _;
    }

    // ---------
    // Functions
    // ---------

    /// @notice Adds an authorized user.
    /// @param _address The address to add as authorized user.
    function addAuthorizedUser(address _address) external onlyOwner() {
        require(!isAuthorizedUser[_address], "SwapInterface.sol::addAuthorizedUser() User is already authorized");
        emit AuthorizedUserUpdated(_address, true);
        isAuthorizedUser[_address] = true;
    }

    /// @notice Removes an authorized user.
    /// @param _address The address to remove as authorized user.
    function removeAuthorizedUser(address _address) external onlyOwner() {
        require(isAuthorizedUser[_address], "SwapInterface.sol::removeAuthorizedUser() User is not authorized");
        emit AuthorizedUserUpdated(_address, false);
        isAuthorizedUser[_address] = false;
    }


    /// @notice Adds a wallet to the whitelist.
    /// @param _address The wallet to add to the whitelist.
    function addWalletToWhitelist(address _address) external isAuthorized() {
        require(!whitelistedWallet[_address], "SwapInterface.sol::addWalletToWhitelist() User is already whitelisted");
        whitelistedWallet[_address] = true;
    }

    /// @notice Removes a wallet from the whitelist.
    /// @param _address The wallet to remove from the whitelist.
    function removeWalletFromWhitelist(address _address) external isAuthorized() {
        require(whitelistedWallet[_address], "SwapInterface.sol::removeWalletFromWhitelist() User is not whitelisted");
        whitelistedWallet[_address] = false;
    }

    /// @notice Allows user to invest tokens into the REIT.
    /// @param _asset The address of the token being invested.
    /// @param _amount The amount of the token being invested.
    function invest(address _asset, uint256 _amount) external isWhitelistedWallet() {
        require(contractEnabled, "swapInterface.sol::invest() Contract not enabled");
        require(_amount > 0, "swapInterface.sol::invest() Amount invested must be greater than 0");
        require(whitelistedToken[_asset], "swapInterface.sol::invest() Investing is disabled for this token");

        IERC20(_asset).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 amountInvested = swap(_asset, _amount, msg.sender);

        emit InvestmentReceived(amountInvested);
    }

    /// @notice Allows user to invest ETH into the REIT.
    /// @dev ETH is not ERC20, needs to be wrapped using the WETH contract.
    function investETH() external payable isWhitelistedWallet() {
        require(contractEnabled, "swapInterface.sol::investETH() Contract not enabled");
        require(msg.value > 0, "swapInterface.sol::investETH() Amount invested must be greater than 0");

        IWETH(WETH).deposit{value: msg.value}();
        uint256 amountInvested = swap(WETH, msg.value, msg.sender);

        emit InvestmentReceived(amountInvested);
    }

    /// @notice Calls the Curve API to swap incoming assets to USDC.
    /// @param _asset The address of the token being swapped.
    /// @param _amount The amount of the token being swapped.
    /// @param _address The address of the user investing in the REIT.
    // TODO: should we swap for a given amount, or just try to use the contract's currency balance?
    // TODO: discuss any other potential whitelisted currencies or how we can make a dynamic whitelist.
    function swap(address _asset, uint256 _amount, address _address) internal returns (uint256 amountInvestedUSDC) {
        require(_amount > 0, "swapInterface.sol::swap() Amount must be greater than 0");
        require(whitelistedToken[_asset], "swapInterface.sol::swap() Swapping is disabled for this token");

        uint256 min_dy = 1;

        // swap given asset to stable currency (USDC).
            // ETH -> WETH -> USDT -> USDC
            // WETH -> USDT -> USDC
            // wBTC -> USDT -> USDC
            // FRAX -> USDC
            // DAI -> USDC
            // USDT -> USDC
            // accept USDC

        if (_asset == DAI) {
            // swap 0 for 1
            assert(IERC20(_asset).approve(_3POOL_SWAP_ADDRESS, _amount));
            curve3PoolStableSwap(_3POOL_SWAP_ADDRESS).exchange(int128(0), int128(1), _amount, min_dy);
        }

        else if (_asset == USDT) {
            // swap 2 for 1
            IERC20(_asset).safeApprove(_3POOL_SWAP_ADDRESS, _amount);   // NOTE: USDT is not ERC20 compliant, so we use SafeERC20 safeApprove.
            curve3PoolStableSwap(_3POOL_SWAP_ADDRESS).exchange(int128(2), int128(1), _amount, min_dy);
        }

        else if (_asset == FRAX) {
            // swap 0 for 1
            assert(IERC20(_asset).approve(_FRAXUSDC_SWAP_ADDRESS, _amount));
            curveFraxUSDCStableSwap(_FRAXUSDC_SWAP_ADDRESS).exchange(int128(0), int128(1), _amount, min_dy);
        }

        else if (_asset == WETH) {
            // swap 2 for 0, 2 for 1
            assert(IERC20(_asset).approve(_TRICRYPTO2_SWAP_ADDRESS, _amount));
            curveTriCrypto2StableSwap(_TRICRYPTO2_SWAP_ADDRESS).exchange(uint256(2), uint256(0), _amount, min_dy);

            IERC20(USDT).safeApprove(_3POOL_SWAP_ADDRESS, uint256(IERC20(USDT).balanceOf(address(this))));
            curve3PoolStableSwap(_3POOL_SWAP_ADDRESS).exchange(int128(2), int128(1), uint256(IERC20(USDT).balanceOf(address(this))), min_dy);
        }

        else if (_asset == WBTC) {
            // swap 1 for 0, 2 for 1
            assert(IERC20(_asset).approve(_TRICRYPTO2_SWAP_ADDRESS, _amount));
            curveTriCrypto2StableSwap(_TRICRYPTO2_SWAP_ADDRESS).exchange(uint256(1), uint256(0), _amount, min_dy);

            IERC20(USDT).safeApprove(_3POOL_SWAP_ADDRESS, uint256(IERC20(USDT).balanceOf(address(this))));
            curve3PoolStableSwap(_3POOL_SWAP_ADDRESS).exchange(int128(2), int128(1), uint256(IERC20(USDT).balanceOf(address(this))), min_dy);
        }

        // USDC doesn't need to be swapped via curve.

        // transfer swapped asset to treasury.
        uint256 amountUSDC = IERC20(USDC).balanceOf(address(this));
        assert(IERC20(USDC).transfer(Treasury, amountUSDC));

        ITreasury(Treasury).updateStableReceived(_address, amountUSDC, block.timestamp);
        return amountUSDC;
    }

    /// @notice Changes the stable currency address.
    /// @param _stableCurrency The new stable currency contact address.
    function changeStableCurrency(address _stableCurrency) external onlyOwner() {
        require(stableCurrency != _stableCurrency, "swapInterface.sol::updateStableCurrency() stableCurrency should not equal _stableCurrency");
        require(IERC20(_stableCurrency).decimals() >= 6, "swapInterface.sol::updateStableCurrency() decimal precision of _stableCurrency needs to be >= 6");
        
        emit StableCurrencyUpdated(stableCurrency, _stableCurrency);
        stableCurrency = _stableCurrency;
    }

    /// @notice Allows owner to disable smart contract operations.
    function disableContract() external onlyOwner() {
        require(contractEnabled, "swapInterface.sol::disableContract() contract is already disabled");
        emit ContractStateUpdated(false);
        contractEnabled = false;
    }

    /// @notice Allows owner to enable contract if disabled.
    function enableContract() external onlyOwner() {
        require(!contractEnabled, "swapInterface.sol::enableContract() contract is already enabled");
        require(treasurySet, "swapInterface.sol::invest() Treasury not set");
        emit ContractStateUpdated(true);
        contractEnabled = true;
    }

    /// @notice Updates which tokens are accepted for investments.
    /// @param _token The contact address for the token we are updating.
    /// @param _isAllowed true to accept investments of this token, false to decline.
    function updateTokenWhitelist(address _token, bool _isAllowed) external onlyOwner() {
        require(whitelistedToken[_token] == !_isAllowed, "swapInterface.sol::updateTokenWhitelist() token state is already as requested");
        emit TokenWhitelistStateUpdated(_token, _isAllowed);
        whitelistedToken[_token] = _isAllowed;
    }

    /// @notice Updates address of the Treasury contract.
    /// @param _newAddress The new address of the treasury.
    function updateTreasury(address _newAddress) external onlyOwner() {
        require(_newAddress != address(0), "SwapInterface.sol::updateTreasury() _newAddress parameter not set");
        require(_newAddress != Treasury, "SwapInterface.sol::updateTreasury() new Treasury address must be different from the old one");
        emit TreasuryAddressUpdated(_newAddress);
        Treasury = _newAddress;
        treasurySet = true;
    }

    // ~ View Functions ~

    /// @notice Should return contract balance of stableCurrency.
    /// @param _token Contact address of token to check the balance of.
    /// @return uint256 Amount of stableCurrency that is inside contract.
    function balanceOfToken(address _token) external view returns (uint256) {
        return IERC20(_token).balanceOf(address(this)); // TODO: balance of this contract or of treasury contract?
    }
}
