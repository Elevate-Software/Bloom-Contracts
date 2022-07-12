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
///          - How do we know which wallets are finished receiving dividends?
///          - How will funds be deposited for dividends?
contract Treasury is Ownable {

    // ---------------
    // State Variables
    // ---------------

    address public stableCurrency;                               /// @notice Used to store address of coin used to deposit/payout from Treasury.
    mapping(address => InvestorData) private investorLibrary;    /// @notice Mapping of Investor wallets to their investment data held in InvestorData.
    mapping(address => bool) public isAuthorizedUser;            /// @notice isAuthorizedUser[address] returns true if wallet is authorized;

    /// @notice Investor struct is used to track data points of investments made by investors.
    /// @param amountInvested Tracks USD-stablecoin equivalent to investment made.
    /// @param dividendsReceived Tracks dividends received by investor in stablecoin.
    struct InvestorData {
        uint totalAmountInvested;
        uint totalDividendsReceived;
        InvestmentReceipt[] investmentLibrary;
        DividendReceipt[] dividendLibrary;
    }

    /// TODO: NatSpec
    /// @notice InvestmentReceipt is used to track the amount invested by an indiviual investor and the date/time each transaction occurs.
    /// @param amountInvested Stores the amount an individual invest.
    /// @param timeUnix Stores the date/time when transaction occured.
    struct InvestmentReceipt {
        uint amountInvested;
        uint timeUnix;
    }

    /// TODO: NatSpec
    /// @notice Dividend Struct is used to track the amount of dividends an investor is paid and the date/time each transaction occurs.
    /// @param dividendPaid Stores the amount of dividends paid to an investor.
    /// @param timeUnix Stores the date/time transaction occured.
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

    // TODO: Add any necessary events. An event is simply a log that takes place
    //       when something in the contract happens we feel is important enough to emit it.
    //       https://www.tutorialspoint.com/solidity/solidity_events.htm.
    
    // ---------
    // Modifiers
    // ---------

    // TODO: Add a modifier called isAuthorizedUser that checks to see if msg.sender is an authorizedUser.
    //       https://www.tutorialspoint.com/solidity/solidity_function_modifiers.htm.
    
     
    // ---------
    // Functions
    // ---------

    /// @notice Withdraw stableCurrency from contract to a Circle acc.
    /// @dev 
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

    /// @notice Withdraws asset to owner wallet.
    /// @param _token is the contract address of token we want to withdraw.
    function safeWithdraw(address _token) public onlyOwner() {

    }

    /// @notice Deposit assets into the contract
    /// @param _token is the contract address of token we want to withdraw.
    function safeDeposit(address _token) public onlyOwner() {

    }

    /// TODO: Setup contract for dividend payouts. Do this by adding
    /// a function called payDividend() include NatSpec.
    /// @notice Pays dividends to the investor.
    /// @param _dividend is the contact address of where we want to send the dividend payout to.
    function payDividend(address _dividends) public payable returns(uint) {

    }

    /// TODO: add updateStableCurrency() function which updates _stableCurrency.
    /// @notice updates stablecurrency to _stablecurrency.
    /// @param _stablecurrency stores stableCurrency.
    function updateStableCurrency(address _stableCurrency) public {
        stableCurrency = _stableCurrency;
    }

    /// TODO: add depositDividends() function which allows a manual deposit
    ///       of funds into the contract
    /// @notice deposits dividend payment to a depository.
    /// @param  dividendWallet stores the wallet address for the dividends to be directed to.
    /// @param dividendDepository stores the amount of dividends to be paid to an investor.
    function depositDividends(address dividendWallet, uint dividendDepository) public {

    }


    // ~ View Functions ~

    /// @notice Should return contract balance of stableCurrency.
    /// @return uint Amount of stableCurrency that is inside contract.
    function balanceOfStableCurrency() public view returns (uint) {

    }

}
