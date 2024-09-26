// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
* @title IPriceOracleGetter interface
*/
interface IPriceOracleGetter {
    /***********
    @dev returns the asset price in ETH
     */
    function getAssetPrice(address _asset) external view returns (uint256);
}
