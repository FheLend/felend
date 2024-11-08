// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../libraries/openzeppelin-upgradeability/VersionedInitializable.sol";
import "../libraries/EthAddressLib.sol";

/// @title TokenDistributor
/// @notice Receives tokens and manages the distribution amongst receivers
///  The usage is as follows:
///  - The distribution addresses and percentages are set up on construction
///  - At any moment, anyone can call distribute() with a list of token addresses in order to distribute
///    the accumulated token amounts and/or ETH in this contract to all the receivers with percentages
contract TokenDistributor is ReentrancyGuard, VersionedInitializable {
    using SafeERC20 for IERC20;

    struct Distribution {
        address[] receivers;
        uint256[] percentages;
    }

    event DistributionUpdated(address[] receivers, uint256[] percentages);
    event Distributed(address receiver, uint256 percentage, uint256 amount);

    uint256 public constant IMPLEMENTATION_REVISION = 0x4;

    /// @notice Defines how tokens and ETH are distributed on each call to .distribute()
    Distribution private distribution;

    /// @notice Instead of using 100 for percentages, higher base to have more precision in the distribution
    uint256 public constant DISTRIBUTION_BASE = 10000;

    /// @notice The address of the token to burn (LEND token)
    address public tokenToBurn;

    /// @notice Called by the proxy when setting this contract as implementation
    function initialize(
        address[] memory _receivers,
        uint256[] memory _percentages
    ) public initializer {
        internalSetTokenDistribution(_receivers, _percentages);
        emit DistributionUpdated(_receivers, _percentages);    
        
    }

    /// @notice In order to receive ETH transfers
    receive() external payable {}


    /// @notice Distributes the whole balance of a list of _tokens balances in this contract
    /// @param _tokens list of ERC20 tokens to distribute
    function distribute(IERC20[] memory _tokens) public {
        for (uint256 i = 0; i < _tokens.length; i++) {
            uint256 _balanceToDistribute = (address(_tokens[i]) != EthAddressLib.ethAddress())
                ? _tokens[i].balanceOf(address(this))
                : address(this).balance;
            if (_balanceToDistribute <= 0) {
                continue;
            }

            internalDistributeTokenWithAmount(_tokens[i], _balanceToDistribute);
        }
    }

    /// @notice Distributes specific amounts of a list of _tokens
    /// @param _tokens list of ERC20 tokens to distribute
    /// @param _amounts list of amounts to distribute per token
    function distributeWithAmounts(IERC20[] memory _tokens, uint256[] memory _amounts) public {
        for (uint256 i = 0; i < _tokens.length; i++) {
            internalDistributeTokenWithAmount(_tokens[i], _amounts[i]);
        }
    }

    /// @notice Distributes specific total balance's percentages of a list of _tokens
    /// @param _tokens list of ERC20 tokens to distribute
    /// @param _percentages list of percentages to distribute per token
    function distributeWithPercentages(IERC20[] memory _tokens, uint256[] memory _percentages) public {
        for (uint256 i = 0; i < _tokens.length; i++) {
            uint256 _amountToDistribute = (address(_tokens[i]) != EthAddressLib.ethAddress())
                ? (_tokens[i].balanceOf(address(this))+_percentages[i]) / 100
                : address(this).balance * _percentages[i] / 100;
            if (_amountToDistribute <= 0) {
                continue;
            }

            internalDistributeTokenWithAmount(_tokens[i], _amountToDistribute);
        }
    }

    /// @notice Sets _receivers addresses with _percentages for each one
    /// @param _receivers Array of addresses receiving a percentage of the distribution, both user addresses
    ///   or contracts
    /// @param _percentages Array of percentages each _receivers member will get
    function internalSetTokenDistribution(address[] memory _receivers, uint256[] memory _percentages) internal {
        require(_receivers.length == _percentages.length, "Array lengths should be equal");

        distribution = Distribution({receivers: _receivers, percentages: _percentages});
        emit DistributionUpdated(_receivers, _percentages);
    }

    /// @notice Distributes a specific amount of a token owned by this contract
    /// @param _token The ERC20 token to distribute
    /// @param _amountToDistribute The specific amount to distribute
    function internalDistributeTokenWithAmount(IERC20 _token, uint256 _amountToDistribute) internal {
        address _tokenAddress = address(_token);
        Distribution memory _distribution = distribution;
        for (uint256 j = 0; j < _distribution.receivers.length; j++) {
            uint256 _amount = _amountToDistribute * _distribution.percentages[j] / DISTRIBUTION_BASE;

            //avoid transfers/burns of 0 tokens
            if(_amount == 0){
                continue;
            }

            if (_tokenAddress != EthAddressLib.ethAddress()) {
                _token.safeTransfer(_distribution.receivers[j], _amount);
            } else {
                // solium-disable-next-line
                (bool _success,) = _distribution.receivers[j].call{value:_amount}("");
                require(_success, "Reverted ETH transfer");
            }
            emit Distributed(_distribution.receivers[j], _distribution.percentages[j], _amount);
            
        }
    }

    /// @notice Returns the receivers and percentages of the contract Distribution
    /// @return receivers array of addresses and percentages array on uints
    function getDistribution() public view returns(address[] memory receivers, uint256[] memory percentages) {
        receivers = distribution.receivers;
        percentages = distribution.percentages;
    }

    /// @notice Gets the revision number of the contract
    /// @return The revision numeric reference
    function getRevision() internal pure override returns (uint256) {
        return IMPLEMENTATION_REVISION;
    }

}