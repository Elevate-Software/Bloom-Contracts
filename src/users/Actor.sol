// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

import { IERC20 } from "../interfaces/InterfacesAggregated.sol";

contract Actor {

    /************************/
    /*** DIRECT FUNCTIONS ***/
    /************************/

    // function transferToken(address token, address to, uint256 amt) external {
    //     IERC20(token).transfer(to, amt);
    // }

    /*********************/
    /*** TRY FUNCTIONS ***/
    /*********************/

    // function try_transferToken(address token, address to, uint256 amt) external returns (bool ok) {
    //     string memory sig = "transfer(address,uint256)";
    //     (ok,) = address(token).call(abi.encodeWithSignature(sig, to, amt));
    // }

    function try_updateStableReceived(address treasury, address wallet, uint amount, uint timeUnix) external returns (bool ok) {
        string memory sig = "updateStableReceived(address,uint,uint)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, wallet, amount, timeUnix));
    }
    
}