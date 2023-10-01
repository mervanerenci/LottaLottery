//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract RecLottery {

    //round struct

    struct Round {
        uint256 endBlock;
        uint256 drawBlock;
        Entry[] entries;
        uint256 totalQuantity;
        address winner;
    }

    struct Entry {
        address buyer;
        uint256 quantity;
    }

    uint256 constant public TICKET_PRICE = 1e15;

    mapping(uint256 => Round) public rounds;
    uint256 public round;
    uint256 public duration;
    mapping(address => uint256) public balances;

    //duration is in blocks. 1 day = ~40000 blocks in Polygon
    constructor(uint256 _duration) {
        duration = _duration;
        round = 1;
        rounds[round].endBlock = block.number + duration;
        rounds[round].drawBlock = block.number + duration + 5;
    }

    function buy() payable public {
        // check if rounds has ended
        require(block.number < rounds[round].endBlock, "Round has ended");
        require(msg.value % TICKET_PRICE == 0, "Amount is not a multiple of ticket price");

        // update round data
        
    }


}