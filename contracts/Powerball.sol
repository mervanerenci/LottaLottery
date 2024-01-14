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


}