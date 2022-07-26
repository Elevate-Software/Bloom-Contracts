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



// ----------
// Interfaces
// ----------

// DAI, USDC, USDT
interface curve3PoolStableSwap {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}

// FRAX, USDT
interface curveFraxUSDCStableSwap {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external; //TODO: is this correct?
}

// USDT, WBTC, WETH
interface curveTriCrypto2StableSwap {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external; //TODO: is this correct?
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/// other interfaces here :)

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

    // contract addresses
    address constant DAI   = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT  = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant FRAX  = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address constant WETH  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant WBTC  = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    // swap addresses
    address constant _3PoolSwapAddress = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address constant _FraxUSDCPoolSwapAddress = 0xDcEF968d416a41Cdac0ED8702fAC8128A64241A2;
    address constant _tricrypto2PoolSwapAddress = 0x80466c64868E1ab14a1Ddf27A676C3fcBE638Fe5;


    // -----------
    // Constructor
    // -----------

    /// @notice Initializes Treasury.sol 
    /// @param _stableCurrency Used to store address of stablecoin used in contract (default is USDC).
    /// @param _admin Wallet address of owner account.
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
    function swap(address asset, uint amount) internal {
        require(whitelistedToken[asset] == true, "swapInterface.sol::swap() Swapping is disabled for this token.");

        uint min_dy = 1;    // TODO: Figure out what this should actually be if not 1.

        // swap given asset to stable currency (USDC).

        if (asset == DAI) {
            // swap 1 for 2
            IERC20(asset).approve(_3PoolSwapAddress, amount);
            curve3PoolStableSwap(_3PoolSwapAddress).exchange(int128(1), int128(2), amount, min_dy);
        }

        else if (asset == USDT) {
            // swap 3 for 2
            IERC20(asset).approve(_3PoolSwapAddress, amount);
            curve3PoolStableSwap(_3PoolSwapAddress).exchange(int128(3), int128(2), amount, min_dy);
        }

        else if (asset == FRAX) {
            // swap 1 for 2
            IERC20(asset).approve(_FraxUSDCPoolSwapAddress, amount);
            curveFraxUSDCStableSwap(_FraxUSDCPoolSwapAddress).exchange(int128(1), int128(2), amount, min_dy);
        }

        else if (asset == WETH) {
            // swap 3 for 1, 3 for 2
            IERC20(asset).approve(_tricrypto2PoolSwapAddress, amount);
            curveTriCrypto2StableSwap(_tricrypto2PoolSwapAddress).exchange(int128(3), int128(1), amount, min_dy);
            curve3PoolStableSwap(_3PoolSwapAddress).exchange(3, 2, amount, min_dy);
        }

        else if (asset == WBTC) {
            // swap 2 for 1, 3 for 2
            IERC20(asset).approve(_tricrypto2PoolSwapAddress, amount);
            curveTriCrypto2StableSwap(_tricrypto2PoolSwapAddress).exchange(int128(2), int128(1), amount, min_dy);
            curve3PoolStableSwap(_3PoolSwapAddress).exchange(int128(3), int128(2), amount, min_dy);
        }

        // if asset is USDC send it to contract
        else if (asset == USDC) {
            // no swap
        }

        // Pools resources //
        // All Pools: https://curve.fi/pools
        // Understanding Pools: https://resources.curve.fi/lp/understanding-curve-pools
        // Base & MetaPools: https://resources.curve.fi/lp/base-and-metapools

        // Swapping resources //
        // Tutorial (it's in Vyper, but should be almost identical in Solidity): https://www.youtube.com/watch?v=uB78gRsE5cI
        // Pool Contract: https://github.com/curvefi/curve-contract/tree/master/contracts/pools

        // DAI, USDC, USDT, FRAX, WETH, WBTC, TUSD
        // needs to be or swap directly to USDC
        // viable pools: 3Pool (DAI, USDT, USDC); fraxUSDC (FRAX, USDC); 
        // missing pools: WETH, WBTC, TUSD ... tricrypto2(USDT, wBTC, WETH) but is non-pegged and doesn't have USDC.

        // need a separate interface for each pool we're going to use.
        // May have to cut out WETH, WBTC, AND TUSD.
            // TUSD because there's no pool for it
            // WETH AND WBTC because we would have to swap twice (into TUSD in tricrypto2 pool, then into USDC in 3pool).

        // automatically send invested USDC to treasury.
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
