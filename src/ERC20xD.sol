// SPDX-License-Identifier: BUSL
pragma solidity ^0.8.28;

import { MessagingReceipt } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { BaseERC20xD } from "./mixins/BaseERC20xD.sol";
import { IERC20xD } from "./interfaces/IERC20xD.sol";

contract ERC20xD is BaseERC20xD, IERC20xD {
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the WrappedERC20xD contract.
     * @param _name The token name.
     * @param _symbol The token symbol.
     * @param _decimals The token decimals.
     * @param _liquidityMatrix The address of the LiquidityMatrix contract.
     * @param _gateway The address of the ERC20xDGateway contract.
     * @param _owner The owner of this contract.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _liquidityMatrix,
        address _gateway,
        address _owner
    ) BaseERC20xD(_name, _symbol, _decimals, _liquidityMatrix, _gateway, _owner) { }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function quoteMint(address from, uint128 gasLimit) public view returns (uint256 fee) {
        return quoteTransfer(from, gasLimit);
    }

    function quoteBurn(address from, uint128 gasLimit) public view returns (uint256 fee) {
        return quoteTransfer(from, gasLimit);
    }

    /*//////////////////////////////////////////////////////////////
                                LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints tokens.
     * @param to The recipient address of the minted tokens.
     * @param amount The amount of tokens to mint.
     * @dev This function should be called by derived contracts with appropriate access control.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _transferFrom(address(0), to, amount);
    }

    /**
     * @notice Burns tokens by transferring them to the zero address.
     * @param amount The amount of tokens to burn.
     * @param data Additional data for the transfer call.
     * @dev This function should be called by derived contracts with appropriate access control.
     */
    function burn(uint256 amount, bytes calldata data) external payable returns (MessagingReceipt memory receipt) {
        return _transfer(msg.sender, address(0), amount, "", 0, data);
    }
}
