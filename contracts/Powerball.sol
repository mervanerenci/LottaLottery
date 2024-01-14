//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Powerball {
    struct Round {
        uint endTime;
        uint drawBlock;
        uint[6] winningNumbers;
        mapping(address => uint[6][]) tickets;
    }

    uint public constant TICKET_PRICE = 2e15;
    uint public constant MAX_NUMBER = 69;
    uint public constant MAX_POWERBALL_NUMBER = 26;
    uint public constant ROUND_LENGTH = 3 days;

    uint public round;
    mapping(uint => Round) public rounds;

    constructor() {
        round = 1;
        rounds[round].endTime = now + ROUND_LENGTH;
    }

    function buy(uint[6][] numbers) public payable {
        require(
            numbers.length * TICKET_PRICE == msg.value,
            "Incorrect amount sent"
        );

        for (uint i = 0; i < numbers.length; i++) {
            for (uint j = 0; j < 6; j++) {
                require(numbers[i][j] > 0, "Invalid number");
            }
            for (uint j = 0; j < 5; j++) {
                require(numbers[i][j] <= MAX_NUMBER);
            }
            require(numbers[i][5] <= MAX_POWERBALL_NUMBER);
        }

        // check for round expiry
        if (now > rounds[round].endTime) {
            rounds[round].drawBlock = block.number + 5;
            round += 1;
            rounds[round].endTime = now + ROUND_LENGTH;
        }

        for (i=0; i < numbers.length; i++) {
            rounds[round].tickets[msg.sender].push(numbers[i]);
        }
    }
}
