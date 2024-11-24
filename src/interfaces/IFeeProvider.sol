// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
* @title IFeeProvider interface
*/

interface IFeeProvider {
    function calculateLoanOriginationFee(uint256 _amount) external view returns (uint256);
    function getLoanOriginationFeePercentage() external view returns (uint256);
}
