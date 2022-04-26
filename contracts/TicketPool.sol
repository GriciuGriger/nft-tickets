pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

contract TicketPool is ERC721URIStorageUpgradeable, OwnableUpgradeable {

    address payable internal withdrawalAddress;

    uint256 internal _ticketsPool;
    uint256 internal _mintPool;
    uint256 internal _ticketPrice;

    event ETHWithdrawn(address _by, address _to, uint256 _amount);
    event TicketMinted(address _to, uint256 ID);

    struct SaleDate 
    {
        uint256 start;
        uint256 end;
    }

    SaleDate internal saleDate;

     struct Ticket {
        uint256 ID;
        address belongsTo;
        string URI;
     }

    Ticket[] internal tickets;

    function initialize(   
        address admin_,
        uint256 ticketsPool_,
        uint256 mintPool_,
        uint256 ticketPrice_,
        uint256 eventSaleStart_,
        uint256 eventSaleEnd_
    ) public initializer {
    require(mintPool_ <= ticketsPool_, "Mintpool is bigger than the whole ticketpool.");

        transferOwnership(admin_);
        withdrawalAddress = payable(OwnableUpgradeable.owner());
        __ERC721_init("Coachella Art Festival", "CAF");

        _ticketsPool = ticketsPool_;
        _mintPool = mintPool_;
        _ticketPrice = ticketPrice_;

        for(uint256 i = 0; i < mintPool_; i++) {
            _safeTicketMint(admin_, i);
        }

        saleDate.start = eventSaleStart_;
        saleDate.end = eventSaleEnd_;
    }

    function _createTicket(uint256 Id_, address belongsTo_) internal {

        Ticket memory _ticket = Ticket({
            ID: Id_,
            belongsTo: belongsTo_,
            URI: tokenURI(Id_)
        });

        tickets.push(_ticket);
    }

    function _safeTicketMint(address to, uint256 tokenId) internal virtual {
        _createTicket(tokenId, to);
        _safeMint(to, tokenId);
        emit TicketMinted(to, tokenId);
    }


    function withdraw() payable external onlyOwner {

        uint256 _contractBalance = uint256(address(this).balance);
        (bool success, ) = withdrawalAddress.call{value: _contractBalance}("");   
        require(success, "Failed to withdraw Ether");     
        emit ETHWithdrawn(msg.sender, withdrawalAddress, _contractBalance);

    }

    function _changeWithdrawalAddress(address newWithdrawalAddress_) private onlyOwner {
        withdrawalAddress = payable(newWithdrawalAddress_);
    }

}
