// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import  "./libraries/TransferHelper.sol";

struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

struct ExactOutputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 amountOut;
    uint256 amountInMaximum;
    uint160 sqrtPriceLimitX96;
}

interface ITargetRouter {
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract Buyer {

    constructor() {}

    function buyV2(address router, uint256 amountOut, address[] calldata path) external payable {
        ITargetRouter(router).swapETHForExactTokens{value: msg.value}(amountOut, path, address(this), block.timestamp);
    }

    function buyV2WithTax(address router, address[] calldata path) external payable {
        ITargetRouter(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(0, path, address(this), block.timestamp);
    }

    function buyV3(address router, uint256 amountOut, address tokenIn, address tokenOut, uint24 fee, uint256 amountInMaximum) external payable {
        ITargetRouter(router).exactOutputSingle{value: msg.value}(ExactOutputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            address(this),
            amountOut,
            amountInMaximum,
            0
        ));
    }

    function buyV3ExactInput(address router, uint256 amountIn, address tokenIn, address tokenOut, uint24 fee, uint256 amountOutMinimum) external payable {
        ITargetRouter(router).exactInputSingle{value: msg.value}(ExactInputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            address(this),
            amountIn,
            amountOutMinimum,
            0
        ));
    }

    function withdrawToken(address token, address to, uint256 amount) external {
        TransferHelper.safeTransfer(token, to, amount);
    }

    function withdrawAllToken(address token, address to) external {
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
    }

    function withdrawETH(address to, uint256 amount) external {
        TransferHelper.safeTransferETH(to, amount);
    }

    function withdrawAllETH(address to) external {
        TransferHelper.safeTransferETH(to, address(this).balance);
    }

    receive() external payable {}
}
