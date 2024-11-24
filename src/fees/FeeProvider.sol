// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../libraries/openzeppelin-upgradeability/VersionedInitializable.sol";
import "../interfaces/IFeeProvider.sol";
import "../libraries/WadRayMath.sol";


/**
* @title FeeProvider contract
* @notice Implements calculation for the fees applied by the protocol
**/
contract FeeProvider is IFeeProvider, VersionedInitializable {
    using WadRayMath for uint256;

    // percentage of the fee to be calculated on the loan amount
    uint256 public originationFeePercentage;

    address public addressesProvider;

    uint256 constant public FEE_PROVIDER_REVISION = 0x1;

    constructor(address _addressProvider) {
        initialize(_addressProvider);
    }

    function getRevision() internal pure override returns(uint256) {
        return FEE_PROVIDER_REVISION;
    }
    /**
    * @dev initializes the FeeProvider after it's added to the proxy
    * @param _addressesProvider the address of LendingPoolAddressesProvider
    */
    function initialize(address _addressesProvider) public initializer {
        /// @notice origination fee is set as default as 25 basis points of the loan amount (0.0025%)
        originationFeePercentage = 0.0025 * 1e18;
    }

    /**
    * @dev calculates the origination fee for every loan executed on the platform.
    * @param _amount the amount of the loan
    **/
    function calculateLoanOriginationFee(uint256 _amount) external view returns (uint256) {
        return _amount.wadMul(originationFeePercentage);
    }

    /**
    * @dev returns the origination fee percentage
    **/
    function getLoanOriginationFeePercentage() external view returns (uint256) {
        return originationFeePercentage;
    }

}
