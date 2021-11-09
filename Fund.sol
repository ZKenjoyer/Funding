// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Fund {
    using SafeMath for uint256;
    
    mapping(address => uint256) public AdressToAmountFunded;
    address[] public funders;
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function Fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversationRate(msg.value) >= minimumUSD, "You need more ETH");
        AdressToAmountFunded[msg.sender] += msg.value;
        funders.push(address(msg.sender));
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    function getPrice() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
         return uint256(answer * 10000000000);
        
    }
    
    function getConversationRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountToUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountToUsd;
    }
    
    modifier OnlyOwner {
        require(msg.sender == owner, "You are not owner");
        _;
    }
    
    function withdraw() payable OnlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
        funders.pop(address(msg.sender));
    }
}
