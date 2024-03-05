// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import  "./libraries/TransferHelper.sol";

interface IBuyer {
    function buyV2(address router, uint256 amountOut, address[] calldata path) external payable;
    function buyV2WithTax(address router, address[] calldata path) external payable;
    function buyV3ExactInput(address router, uint256 amountIn, address tokenIn, address tokenOut, uint24 fee, uint256 amountOutMinimum) external payable;
    function buyV3(address router, uint256 amountOut, address tokenIn, address tokenOut, uint24 fee, uint256 amountInMaximum) external payable;
    function withdrawToken(address token, address to, uint256 amount) external;
    function withdrawAllToken(address token, address to) external;
    function withdrawETH(address to, uint256 amount) external;
    function withdrawAllETH(address to) external;
}

contract BuyerFactory is Ownable {

    address public buyer;

    address[] public preClones;

    event NewClone(address _newClone);

    using Clones for address;

    constructor(address _buyer, uint256 preClonesNum) Ownable(msg.sender) {
        buyer = _buyer;
        for (uint256 i = 0; i < preClonesNum; i++) {
            address identicalChild = buyer.clone();
            preClones.push(identicalChild);

            emit NewClone(identicalChild);
        }
    }

    function preClone(uint256 num) external onlyOwner {
        for (uint256 i = 0; i < num; i++) {
            address identicalChild = buyer.clone();
            preClones.push(identicalChild);

            emit NewClone(identicalChild);
        }
    }

    function batchBuyV2(uint256 walletNum, uint256 ethPerWallet, address router, uint256 amountOut, address[] calldata path) external payable onlyOwner {
        require(walletNum <= numberOfClones(), "BuyerFactory: not enough clones");
        require(ethPerWallet * walletNum <= msg.value, "BuyerFactory: not enought fund");

        for (uint256 i = 0; i < walletNum; i++) {
            IBuyer(preClones[i]).buyV2{value: ethPerWallet}(router, amountOut, path);
        }
    }

    function batchBuyV2WithTax(uint256 walletNum, uint256 ethPerWallet, address router, address[] calldata path) external payable onlyOwner {
        require(walletNum <= numberOfClones(), "BuyerFactory: not enough clones");
        require(ethPerWallet * walletNum <= msg.value, "BuyerFactory: not enought fund");

        for (uint256 i = 0; i < walletNum; i++) {
            IBuyer(preClones[i]).buyV2WithTax{value: ethPerWallet}(router, path);
        }
    }

    function batchBuyV3(uint256 walletNum, uint256 ethPerWallet, address router, uint256 amountOut, address tokenIn, address tokenOut, uint24 fee, uint256 amountInMaximum) external payable onlyOwner {
        require(walletNum <= numberOfClones(), "BuyerFactory: not enough clones");
        require(ethPerWallet * walletNum <= msg.value, "BuyerFactory: not enought fund");

        for (uint256 i = 0; i < walletNum; i++) {
            IBuyer(preClones[i]).buyV3{value: ethPerWallet}(router, amountOut, tokenIn, tokenOut, fee, amountInMaximum);
        }
    }

    function batchBuyV3ExactInput(uint256 walletNum, uint256 ethPerWallet, address router, uint256 amountIn, address tokenIn, address tokenOut, uint24 fee, uint256 amountOutMinimum) external payable onlyOwner {
        require(walletNum <= numberOfClones(), "BuyerFactory: not enough clones");
        require(ethPerWallet * walletNum <= msg.value, "BuyerFactory: not enought fund");

        for (uint256 i = 0; i < walletNum; i++) {
            IBuyer(preClones[i]).buyV3ExactInput{value: ethPerWallet}(router, amountIn, tokenIn, tokenOut, fee, amountOutMinimum);
        }
    }

    function withdrawAllETH(address to) external onlyOwner {
        for (uint256 i = 0; i < numberOfClones(); i++) {
            IBuyer(preClones[i]).withdrawAllETH(to);
        }
        TransferHelper.safeTransferETH(to, address(this).balance);
    }

    function withdrawAllToken(address token, address to) external onlyOwner {
        for (uint256 i = 0; i < numberOfClones(); i++) {
            IBuyer(preClones[i]).withdrawAllToken(token, to);
        }
    }

    function numberOfClones() public view returns (uint256 number) {
        number = preClones.length;
    }

    function allClones() external view returns (address[] memory) {
        return preClones;
    }

}
