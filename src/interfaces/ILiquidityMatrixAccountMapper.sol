// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILiquidityMatrixAccountMapper {
    function shouldMapAccounts(uint32 remoteEid, address remoteAccount, address localAccount)
        external
        view
        returns (bool);
}
