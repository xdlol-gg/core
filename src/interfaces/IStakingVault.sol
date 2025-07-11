// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakingVaultCallbacks {
    /**
     * @notice Called when a token redemption is performed.
     * @param asset The address of the asset redeemed.
     * @param shares The amount of shares to redeem.
     * @param amount The amount of assets withdrawn.
     * @param data Arbitrary data.
     */
    function onRedeem(address asset, uint256 shares, uint256 amount, bytes calldata data) external;
}

interface IStakingVaultNativeCallbacks {
    /**
     * @notice Called when a native currency redemption is performed.
     * @param shares The amount of shares to redeem.
     * @param data Arbitrary data.
     */
    function onRedeemNative(uint256 shares, bytes calldata data) external payable;
}

interface IStakingVault {
    event Stake(address indexed asset, uint256 amount);
    event Unstake(address indexed asset, uint256 amount);
    event Deposit(address indexed asset, uint256 amount, uint256 shares);
    event Redeem(address indexed asset, uint256 amount);

    function sharesOf(address asset, address owner) external view returns (uint256);

    /**
     * @notice Deposits an asset.
     * @param asset The asset to deposit.
     * @param to The recipient.
     * @param amount The amount to deposit.
     * @param data Extra data.
     * @return shares The resulting share amount.
     */
    function deposit(address asset, address to, uint256 amount, bytes calldata data)
        external
        payable
        returns (uint256 shares);

    /**
     * @notice Deposits native currency.
     * @param to The recipient.
     * @param amount The native amount to deposit.
     * @param data Extra data.
     * @return shares The resulting share amount.
     */
    function depositNative(address to, uint256 amount, bytes calldata data) external payable returns (uint256 shares);

    /**
     * @notice Redeems tokens from the vault.
     * @dev Checks balance and processes local or cross-chain redemptions.
     * @param asset The asset to redeem.
     * @param to The recipient.
     * @param shares The amount of shares to redeem.
     * @param callbackData Data to be used for IStakingVaultNativeCallbacks
     * @param receivingData Extra data for receiving tokens.
     * @param data Extra data.
     */
    function redeem(
        address asset,
        address to,
        uint256 shares,
        bytes calldata callbackData,
        bytes calldata receivingData,
        uint128 receivingFee,
        bytes calldata data
    ) external payable;

    /**
     * @notice Redeems native currency from the vault.
     * @dev Checks balance and processes local or cross-chain redemptions.
     * @param to The recipient.
     * @param shares The amount of shares to redeem.
     * @param callbackData Data to be used for IStakingVaultNativeCallbacks
     * @param receivingData Extra data for receiving tokens.
     * @param data Extra data.
     */
    function redeemNative(
        address to,
        uint256 shares,
        bytes calldata callbackData,
        bytes calldata receivingData,
        uint128 receivingFee,
        bytes calldata data
    ) external payable;
}
