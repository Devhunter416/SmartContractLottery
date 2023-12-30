//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v1.8/interfaces/VRFCoordinatorV2Interface.sol";


//@title Sample Raffle Contract
//@author Pedro Curti
//@notice This contract was made mimicking PatrickCollins video tutorial. Is a contract that creates a raffle
//@dev Implements Chainlink VRFv2

contract Raffle {

    uint256 private constant REQUEST_CONFIRMATIONS = 3;
    uint256 private constant WORDS = 1;

    error Raffle__NotEnoughEthSent();
    error Raffle__NotEnoughBlocksPassed();

    uint256 private immutable i_entranceFee;

    address payable[] private s_players;

    uint256 private immutable i_playInterval;

    uint256 private s_lastTimeStamp;

    address private immutable i_VRFCoordinator;

    bytes32 private immutable i_VRFKeyHash;

    uint64 private immutable i_VRFSubId;

    uint32 private immutable i_VRFGasLimit;

    //Events
    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 playInterval, address VRFCoordinator, bytes32 VRFKeyHash, uint64 VRFSubId, uint32 VRFGasLimit) {
        i_entranceFee = entranceFee;
        i_playInterval = playInterval;
        s_lastTimeStamp = block.timestamp;
        i_VRFCoordinator = VRFCoordinator;
        i_VRFKeyHash = VRFKeyHash;
        i_VRFSubId = VRFSubId;
        i_VRFGasLimit = VRFGasLimit;

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

        uint256 requestId = i_VRFCoordinator.requestRandomWords(
            i_VRFKeyHash,
            i_VRFSubId,
            REQUEST_CONFIRMATIONS,
            i_VRFGasLimit,
            WORDS
        );


        s_lastTimeStamp = block.timestamp;
    }


    //Getters

    function getEntranceFee() public view returns(uint256) {
        return i_entranceFee;
    }
}
