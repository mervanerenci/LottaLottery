//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract LottaLottery {
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

    uint256 public constant TICKET_PRICE = 1e15;

    mapping(uint256 => Round) public rounds;
    uint256 public round;
    uint256 public duration;
    mapping(address => uint256) public balances;
    mapping(uint256 => mapping(address => uint256)) public tickets_bought_per_round;

    //duration is in blocks. 1 day = ~40000 blocks in Polygon
    constructor(uint256 _duration) {
        duration = _duration;
        round = 1;
        rounds[round].endBlock = block.number + duration;
        rounds[round].drawBlock = block.number + duration + 5;
    }

    function buy_ticket() public payable {
        require(
            msg.value % TICKET_PRICE == 0,
            "Amount is not a multiple of ticket price"
        );
        require(msg.value >= TICKET_PRICE, "Amount is less than ticket price");


        
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

        // Increment the number of tickets bought by the sender in the current round
        ticketsBoughtPerRound[round][msg.sender] += quantity;
    }

    function draw_winner(uint256 roundNumber) public {
        Round storage drawing = rounds[roundNumber];
        require(drawing.winner == address(0), "Round already drawn");
        require(
            block.number > drawing.drawBlock && drawing.drawBlock > 0,
            "Round not ended"
        );
        require(drawing.entries.length > 0, "No participants");

        // PICK A random number

        // pick winner
        bytes32 rand = keccak256(abi.encodePacked(blockhash(drawing.drawBlock)));
        uint counter = uint(rand) % drawing.totalQuantity;
        for (uint i = 0; i < drawing.entries.length; i++) {
            uint quantity = drawing.entries[i].quantity;
            if (quantity > counter) {
                drawing.winner = drawing.entries[i].buyer;
                break;
            } else counter -= quantity;
        }
        balances[drawing.winner] += TICKET_PRICE * drawing.totalQuantity;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function get_entries(
        uint256 roundNumber
    ) public view returns (Entry[] memory) {
        return rounds[roundNumber].entries;
    }

    function get_entries_by_round(uint256 roundNumber) public view returns (uint256) {
        return ticketsBoughtPerRound[roundNumber][msg.sender];
    }

    function delete_round(uint256 roundNumber) public {
        require(
            block.number > rounds[roundNumber].drawBlock + 100,
            "Round not ended"
        );
        require(rounds[roundNumber].winner != address(0), "Round not drawn");
        delete rounds[roundNumber];
    }
}
