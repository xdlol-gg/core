// SPDX-License-Identifier: BUSL
pragma solidity ^0.8.28;

import { ILiquidityMatrix } from "src/interfaces/ILiquidityMatrix.sol";

contract SettlerMock {
    address immutable liquidityMatrix;

    struct State {
        mapping(uint256 index => address) accounts;
        mapping(uint256 index => bytes32) keys;
    }

    uint32 internal constant TRAILING_MASK = uint32(0x80000000);
    uint32 internal constant INDEX_MASK = uint32(0x7fffffff);

    mapping(address app => mapping(uint32 eid => State)) internal _states;

    constructor(address _liquidityMatrix) {
        liquidityMatrix = _liquidityMatrix;
    }

    function settleLiquidity(
        address app,
        uint32 eid,
        uint256 timestamp,
        uint256,
        bytes32[] calldata,
        bytes calldata accountsData,
        int256[] calldata liquidity
    ) external {
        State storage state = _states[app][eid];

        address[] memory accounts = new address[](liquidity.length);
        for (uint256 i; i < liquidity.length; ++i) {
            uint256 offset;
            // first bit indicates whether an account follows after index and the rest 31 bits represent index
            uint32 _index = uint32(bytes4(accountsData[offset:offset + 4]));
            offset += 4;
            uint32 index = _index & INDEX_MASK;
            if (_index & TRAILING_MASK > 0) {
                accounts[i] = address(bytes20(accountsData[offset:offset + 20]));
                offset += 20;
                state.accounts[index] = accounts[i];
            } else {
                accounts[i] = state.accounts[index];
            }
        }

        ILiquidityMatrix(liquidityMatrix).settleLiquidity(
            ILiquidityMatrix.SettleLiquidityParams(app, eid, timestamp, accounts, liquidity)
        );
    }

    function settleData(
        address app,
        uint32 eid,
        uint256 timestamp,
        uint256,
        bytes32[] calldata,
        bytes calldata keysData,
        bytes[] calldata values
    ) external {
        State storage state = _states[app][eid];

        bytes32[] memory keys = new bytes32[](values.length);
        for (uint256 i; i < values.length; ++i) {
            uint256 offset;
            // first bit indicates whether a key follows after index and the rest 31 bits represent index
            uint32 _index = uint32(bytes4(keysData[offset:offset + 4]));
            offset += 4;
            uint32 index = _index & INDEX_MASK;
            if (_index & TRAILING_MASK > 0) {
                keys[i] = bytes32(keysData[offset:offset + 32]);
                offset += 32;
                state.keys[index] = keys[i];
            } else {
                keys[i] = state.keys[index];
            }
        }

        ILiquidityMatrix(liquidityMatrix).settleData(
            ILiquidityMatrix.SettleDataParams(app, eid, timestamp, keys, values)
        );
    }
}
