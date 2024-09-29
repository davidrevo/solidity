// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Crowdfunding {
    address public immutable beneficiary;   // 受益人
    uint256 public immutable fundingGoal;   // 筹资目标数量
    uint256 public fundingAmount;   // 当前的金额

    mapping(address => uint256) public funders;   // 赞助者地址和金额
    // 可迭代的映射
    mapping(address => uint256) private fundersInserted;
    address[] public fundersKey;    // length
    // 不用自销毁方法，使用变量来控制
    bool public AVAILABLED = true;    // 状态
    // 部署的时候，写入受益人+筹资目标数量
    constructor(address _beneficiary, uint256 _fundingGoal) {
        beneficiary = _beneficiary;
        fundingGoal = _fundingGoal;
    }

    // 资助
    //      可用的时候才可以捐
    //      合约关闭之后，就不能在操作了
    function contribute() external payable {
        require(AVAILABLED, "合约关闭");
        require(msg.value > 0, "金额必须大于0");

        // 检查捐赠金额是否会超过目标金额
        uint256 potentialFundingAmount = fundingAmount + msg.value;
        uint256 refundAmount = 0;

        if (potentialFundingAmount > fundingGoal) {
            refundAmount = potentialFundingAmount - fundingGoal;
            funders[msg.sender] += (msg.value - refundAmount);
            fundingAmount += (msg.value - refundAmount);
        } else {
            funders[msg.sender] += msg.value;
            fundingAmount += msg.value;
        }

        // 更新捐赠者信息
        if (!fundersInserted[msg.sender]) {
            fundersInserted[msg.sender] = true;
            fundersKey.push(msg.sender);
        }

        // 退还多余的金额
        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount);
        }
    }

    // 关闭合约
    function close() external {
        require(msg.sender == beneficiary, "只有受益人可以关闭合约");
        require(fundingAmount >= fundingGoal, "筹资目标未达到");
        uint256 amount = fundingAmount;

        fundingAmount = 0;
        AVAILABLED = false;

        payable(beneficiary).transfer(amount);
        return true;
    }

    function fundersLengh() public view returns(uint256){
        return fundersKey.length;
    }
}