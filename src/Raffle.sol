//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

//@title Sample Raffle Contract
//@author Pedro Curti
//@notice This contract was made mimicking PatrickCollins video tutorial. Is a contract that creates a raffle
//@dev Implements Chainlink VRFv2

contract Raffle is VRFConsumerBaseV2{

    //Const

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant WORDS = 1;

    //errs
    error Raffle__NotEnoughEthSent();
    error Raffle__NotEnoughBlocksPassed();
    error Raffle__TransferWinnerFailed();
    error Raffle__NotOpen();
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 players, uint256 state);
    //Enums

    enum State {OPEN, LOCKED}


    // State vars
    uint256 private immutable i_entranceFee;

    address payable[] private s_players;

    uint256 private immutable i_playInterval;

    uint256 private s_lastTimeStamp;

    address private immutable i_VRFCoordinator;

    bytes32 private immutable i_VRFKeyHash;

    uint64 private immutable i_VRFSubId;

    uint32 private immutable i_VRFGasLimit;

    address private s_lastWinner;
    
    State private s_RaffleState;

    //Events
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(uint256 entranceFee,
                uint256 playInterval,
                address VRFCoordinator,
                bytes32 VRFKeyHash,
                uint64 VRFSubId,
                uint32 VRFGasLimit) VRFConsumerBaseV2(VRFCoordinator){
        i_entranceFee = entranceFee;
        i_playInterval = playInterval;
        s_lastTimeStamp = block.timestamp;
        i_VRFCoordinator = VRFCoordinator;
        i_VRFKeyHash = VRFKeyHash;
        i_VRFSubId = VRFSubId;
        i_VRFGasLimit = VRFGasLimit;
        s_RaffleState = State.OPEN;

    }

    function enterRaffle() external payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        if(s_RaffleState != State.OPEN) {
            revert Raffle__NotOpen();
        }

        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }
    //When is the winner supposed to be picked?
    /*
        @dev This is the function that the ChainLink Automation nodes call
        to see if it's time to perform an upkeep.
        @param null
        @return upkeepNeeded
        @return


        */
    function checkUpkeep(bytes memory /*checkData*/) public view returns(bool upkeepNeeded, bytes memory /*performData*/){
        uint256 lastTimeStamp = s_lastTimeStamp;
        bool timeHasPassed = (block.timestamp - lastTimeStamp) >= i_playInterval;
        bool isOpen = State.OPEN == s_RaffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;

        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /*perfomData*/) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if(!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(address(this).balance,
                                          s_players.length,
                                          uint256(s_RaffleState));
        }
        //pick a rand address


        s_RaffleState = State.LOCKED;
        
        VRFCoordinatorV2Interface(i_VRFCoordinator).requestRandomWords(
            i_VRFKeyHash,
            i_VRFSubId,
            REQUEST_CONFIRMATIONS,
            i_VRFGasLimit,
            WORDS
        );
    }

    function fulfillRandomWords(uint256 /*requestId*/, uint256[] memory randomWords) internal override {
        
        address payable[] memory players = s_players;
        address payable winner = players[randomWords[0]%players.length];
        s_lastWinner = winner;
        (bool success, ) = winner.call{value: address(this).balance}("");

        if(!success) {
            revert Raffle__TransferWinnerFailed();
        }
        s_players = new address payable[](0);
        s_RaffleState = State.OPEN;
        
        s_lastTimeStamp = block.timestamp;

        emit PickedWinner(winner);
    }


    //Getters

    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }
    function getRaffleState() external view returns(State) {
        return s_RaffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns(address payable) {
        return s_players[indexOfPlayer];
    }
}

