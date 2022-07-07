// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";

/// @dev    This ERC20 contract represents the soulbound Bloom Token.
///         This contract should support the following functionalities:
///         - Soulbound
///         - Mintable
///         - Burnable
///         To be determined:
///         - Which contracts should be allowed to mint/burn, and process for enabling mint/burn permissions.

contract BloomToken is Ownable{
    
    // ---------------
    // State Variables
    // ---------------


    // -----------
    // Constructor
    // -----------

    /// @notice Initialize the BloomToken.sol contract ($BLOOM).
    /// @param totalSupply_ The initial supply of $BLOOM (0 ether).
    /// @param decimals_ The decimal precision of $BLOOM (18).
    /// @param name_ The name of BloomToken (BLOOM).
    /// @param symbol_ The symbol of BloomToken (BLM).
    /// @param admin The admin of Bloomtoken.sol.
    constructor(
        uint256 totalSupply_,
        uint8 decimals_,
        string memory name_,
        string memory symbol_,
        address admin
    ) {

    }

    // ------
    // Events
    // ------


    // ---------
    // Modifiers
    // ---------


    // ---------
    // Functions
    // ---------


}
