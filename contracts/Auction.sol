pragma solidity ^0.5.0;

contract Auction {
    address payable public beneficiary;

    // Current state of the auction. You can create more variables if needed
    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Constructor
    bool flag;
    constructor() public {
        highestBid=0;
        beneficiary = msg.sender;
        flag=true; 
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() public payable {


        // TODO If the bid is not higher than highestBid, send the
        // money back. Use "require"
        require(msg.value > highestBid);
        // TODO update state
        uint old_bid=highestBid;
        address old_add=highestBidder;
        highestBid=msg.value;
        highestBidder=msg.sender;
        // TODO store the previously highest bid in pendingReturns. That bidder
        // will need to trigger withdraw() to get the money back.
        // For example, A bids 5 ETH. Then, B bids 6 ETH and becomes the highest bidder. 
        // Store A and 5 ETH in pendingReturns. 
        // A will need to trigger withdraw() later to get that 5 ETH back.
        pendingReturns[old_add]=old_bid+pendingReturns[old_add];
        // Sending back the money by simply using
        // highestBidder.send(highestBid) is a security risk
        // because it could execute an untrusted contract.
        // It is always safer to let the recipients
        // withdraw their money themselves.
        
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        require(pendingReturns[msg.sender]>0);
        // uint tempbal=pendingReturns[msg.sender];
        uint bal=pendingReturns[msg.sender];
        pendingReturns[msg.sender]=0;
        bool  ans= msg.sender.send(bal);
        if(!ans){
            pendingReturns[msg.sender]=bal;
        }
        return ans;
        // TODO send back the amount in pendingReturns to the sender. Try to avoid the reentrancy attack. Return false if there is an error when sending
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() public {
         require(beneficiary==msg.sender); 
         require(flag==true);

         flag=false;
         beneficiary.transfer(highestBid);
    }
}