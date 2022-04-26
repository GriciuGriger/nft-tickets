pragma solidity ^0.8.0;

import {Community} from "./Community.sol";

contract Timelockable is Community {

    function lockSale() internal onlyOwner {
        _pause();
    }

    function unlockSale() internal onlyOwner {
        _unpause();
    }

    modifier saleTimeCheck() {
        uint256 timeOfPurchase = block.timestamp;
        require(timeOfPurchase >= eventDate.saleStart && timeOfPurchase <= eventDate.saleEnd, "This sale has ended.");
        _;
    }

   function buyTickets(uint256 numberOfTickets) public override payable saleTimeCheck{
       super.buyTickets(numberOfTickets);
   }

}