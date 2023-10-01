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
        require(msg.value % TICKET_PRICE == 0, "Amount is not a multiple of ticket price");

        // if previous round is ended , create a new one
        if (block.number > rounds[round].endBlock) {
            round++;
            rounds[round].endBlock = block.number + duration;
            rounds[round].drawBlock = block.number + duration + 5;
        }

        uint256 quantity = msg.value / TICKET_PRICE;
        Entry memory entry = Entry(msg.sender, quantity);
        rounds[round].entries.push(entry);
        rounds[round].totalQuantity += quantity;

    }

    function drawWinner (uint256 roundNumber) public {
        Round storage drawing = rounds[roundNumber];
        require(drawing.winner == address(0), "Round already drawn");
        require(block.number > drawing.drawBlock && drawing.drawBlock > 0, "Round not ended");
        require(drawing.entries.length > 0, "No participants");

        // PICK A RANDOM NUMBER VIA CHAINLINK VRF
        uint256 randomNumber = 4; // TO BE REPLACED

        // PICK THE WINNER
        uint256 winnerIndex = randomNumber % drawing.totalQuantity;

        for (uint256 i = 0; i < drawing.entries.length; i++) {
            uint256 quantity = drawing.entries[i].quantity;
            if (quantity > winnerIndex) {
                drawing.winner = drawing.entries[i].buyer;
                break;
            } else {
                winnerIndex -= quantity;
            }
        }

        balances[drawing.winner] += TICKET_PRICE * drawing.totalQuantity; 

        

    }


}