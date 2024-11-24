// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/src/Test.sol";
import { FheEnabled } from "../../util/FheHelper.sol";
import { ExampleToken } from "../../src/FHERC20.sol";
import { Pool } from "../../src/protocol/Pool.sol";
import { PoolAddressesProvider } from "../../src/configuration/PoolAddressesProvider.sol";
import { PoolConfigurator } from "../../src/protocol/PoolConfigurator.sol";

contract PoolTest is Test, FheEnabled {
    ExampleToken testToken;
    Pool pool;
    PoolAddressesProvider poolAddressesProvider;

    uint256 private adminPrivateKey;

    function setUp() public virtual {
        initializeFhe();

        adminPrivateKey = 0xBA11;

        testToken = new ExampleToken("USDT", "USDT", 100_000_000);
    
        poolAddressesProvider = new PoolAddressesProvider();

        pool = new Pool(poolAddressesProvider);
    }

    /**
     * @dev test supply
     */
    function test_supply() public {
    }

    /**
     * @dev test withdraw
     */
    function test_withdraw() public {

    }

    /**
     * Test borrow success
     * @dev test borrow success case
     */
    function test_borrow() public {

    }
    
    /**
     * Test get reserve configuration data
     * @dev success case
     */
    function test_get_reserve_configuration_data() public {

    }

    /**
     * Test get reserve data
     * @dev 
     */
    function test_get_reserve_data() public {

    }
}