pragma solidity ^0.8.0;

import "./TicketPool.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract Community is TicketPool, PausableUpgradeable {

    uint256 internal _communityPool;
    uint256 internal _indexingIDsStart;

    event TicketPurchase(address by, uint256 numberOfTikckets, uint256[] ticketIds);

    function communityInit() public {
        _communityPool = _ticketsPool - _mintPool; 
        _indexingIDsStart = _mintPool;
    }
 
    function buyTickets(uint256 numberOfTickets) virtual public payable whenNotPaused {
        require(_indexingIDsStart + numberOfTickets <= _communityPool, "No more tickets available to buy");

        uint256[] memory ticketIds;
        uint256 costInEther = _ticketPrice * numberOfTickets;
        require(msg.value != costInEther, "Wrong amount paid in transaction");

        for(uint256 i = _indexingIDsStart; i < _indexingIDsStart + numberOfTickets; i++) {
            for(uint256 j = 0; j<numberOfTickets; j++){
                ticketIds[j] = i;
            }
            _safeTicketMint(msg.sender, i);
        }     

        (bool success, ) = withdrawalAddress.call{value: costInEther}(""); 
        require(success, "Failed to pay for Tickets.");

        emit TicketPurchase(msg.sender, numberOfTickets, ticketIds);
        shiftIndexingStart(numberOfTickets);
    }

    function shiftIndexingStart(uint256 ticketsBought) private {
        _indexingIDsStart += ticketsBought;
    }

}