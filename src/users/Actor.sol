// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

import { IERC20 } from "../interfaces/InterfacesAggregated.sol";

contract Actor {

    /************************/
    /*** DIRECT FUNCTIONS ***/
    /************************/

    function transferToken(address token, address to, uint256 amt) external returns (bool ok){
        assert(IERC20(token).transfer(to, amt));
        return true;
    }

    /*********************/
    /*** TRY FUNCTIONS ***/
    /*********************/

    // function try_transferToken(address token, address to, uint256 amt) external returns (bool ok) {
    //     string memory sig = "transfer(address,uint256)";
    //     (ok,) = address(token).call(abi.encodeWithSignature(sig, to, amt));
    // }

    function try_updateStableReceived(address treasury, address _wallet, uint256 _amount, uint256 _timeUnix) external returns (bool ok) {
        string memory sig = "updateStableReceived(address,uint256,uint256)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, _wallet, _amount, _timeUnix));
    }

    function try_mintBloom(address treasury, address wallet, uint256 amount) external returns (bool ok) {
        string memory sig = "mintBloom(address,uint256)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, wallet, amount));
    }

    function try_addAuthorizedUser(address treasury, address wallet) external returns (bool ok) {
        string memory sig = "addAuthorizedUser(address)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, wallet));
    }

    function try_transferToken(address token, address to, uint256 amount) external returns (bool ok) {
        string memory sig = "transfer(address,uint256)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, to, amount));
    }

    function try_transferFromToken(address token, address from, address to, uint256 amount) external returns (bool ok) {
        string memory sig = "transferFrom(address,address,uint256)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, to, amount));
    }

    function try_approveToken(address token, address to, uint256 amount) external returns (bool ok) {
        string memory sig = "approve(address,uint256)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, to, amount));
    }

    function try_updateException(address token, address wallet, bool isException) external returns (bool ok) {
        string memory sig = "updateException(address,bool)";
        (ok,) = address(token).call(abi.encodeWithSignature(sig, wallet, isException));
    }
    
}