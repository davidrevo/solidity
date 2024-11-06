// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract transferTest {
    
    // 向合约账户转账 
    function transderToContract() payable public {
        payable(address(this)).transfer(msg.value);
    }
    
    // 获取合约账户余额 
    function getBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }
    
    fallback() external payable {}
    
    receive() external payable {}

}
