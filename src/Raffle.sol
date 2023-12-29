//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


//@title Sample Raffle Contract
//@author Pedro Curti
//@notice This contract was made mimicking PatrickCollins video tutorial. Is a contract that creates a raffle
//@dev Implements Chainlink VRFv2

contract Raffle {

    error Raffle__NotEnoughEthSent();
    error Raffle__NotEnoughBlocksPassed();

    uint256 private immutable i_entranceFee;

    address payable[] private s_players;

    uint256 private immutable i_playInterval;

    uint256 private s_lastTimeStamp;


    //Events
    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 playInterval) {
        i_entranceFee = entranceFee;
        i_playInterval = playInterval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }


        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() external {
        if(block.timestamp - s_lastTimeStamp < i_playInterval) {
            revert Raffle__NotEnoughBlocksPassed();
        }
        //pick a rand address




        s_lastTimeStamp = block.timestamp;
    }


    //Getters

    function getEntranceFee() public view returns(uint256) {
        return i_entranceFee;
    }
}
