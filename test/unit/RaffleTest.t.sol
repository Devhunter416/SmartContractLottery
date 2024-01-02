//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployRaffle} from "@script/DeployRaffle.s.sol";
import {Raffle} from "@src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "@script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";


import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test{


    //events
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);



    //state vars

    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 playInterval;
    address VRFCoordinator;
    bytes32 VRFKeyHash;
    uint64 VRFSubId;
    uint32 VRFGasLimit;
    address Link;
    uint256 deployerKey;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (
            entranceFee,
            playInterval,
            VRFCoordinator,
            VRFKeyHash,
            VRFSubId,
            VRFGasLimit,
            Link,
            deployerKey
        ) = helperConfig.activeNetConfig();
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);

    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.State.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{
            value: entranceFee
        }();

        assert(PLAYER == raffle.getPlayer(0));
    }

    function testEmitsEventOnEntrance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{
            value: entranceFee
        }();
    }


    function testCantEnterWhenLocked() public raffleEnteredAndTimePassed{
        raffle.performUpkeep("");
        vm.expectRevert(Raffle.Raffle__NotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{
            value: entranceFee
        }();

    }

    function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
        vm.warp(block.timestamp + playInterval + 1);
        vm.roll(block.number+1);

        (bool upkeepNeded, ) = raffle.checkUpkeep("");


        assert(!upkeepNeded);

    }

    function testCheckUpkeepReturnsFalseIfRaffleNotOpen() public raffleEnteredAndTimePassed{

        raffle.performUpkeep("");

        (bool upkeepNeded,) = raffle.checkUpkeep("");
        assert(!upkeepNeded);
    }

    function testCheckUpkeepReturnsFalseIfEnoughTimeHasntPassed() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        (bool upkeepNeded,) = raffle.checkUpkeep("");
        assert(!upkeepNeded);
    }

    function testCheckupkeepReturnsTrueWhenParametersAreGood() public raffleEnteredAndTimePassed{

        (bool upkeepNeded,) = raffle.checkUpkeep("");
        assert(upkeepNeded);

    }

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue () public raffleEnteredAndTimePassed{

        raffle.performUpkeep("");
    }
    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {

        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        uint256 raffleState = 0;
        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__UpkeepNotNeeded.selector, currentBalance, numPlayers, raffleState));

        raffle.performUpkeep("");
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleEnteredAndTimePassed {
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 requestId = entries[1].topics[1];

        Raffle.State state = raffle.getRaffleState();

        assert(uint256(requestId) > 0);
        assert(uint256(state) == 1);
    }


    modifier skipFork() {
        if(block.chainid != 31337) {
            return;
        }
        _;
    }

    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(uint256 randomRequestId) public raffleEnteredAndTimePassed skipFork{
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(VRFCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
        
    }

    function testFulfillRandomWordsPicksWinnerResetsAndSendsMoney() public raffleEnteredAndTimePassed skipFork {
        uint256 additionalEntrants = 5;
        uint256 startingIndex = 1;
        for(uint256 i = startingIndex; i< startingIndex + additionalEntrants; i++) {
            
            hoax(address(uint160(i)), STARTING_PLAYER_BALANCE);
            raffle.enterRaffle{value: entranceFee}();

        }
        
        uint256 prize = entranceFee * (additionalEntrants + 1);


        assert(raffle.getAmountOfPlayers() == 6);

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 requestId = entries[1].topics[1];

        uint256 previousTimeStamp = block.timestamp;


        VRFCoordinatorV2Mock(VRFCoordinator).fulfillRandomWords(uint256(requestId), address(raffle));
        

        assert(uint256(raffle.getRaffleState()) == 0);
        assert(raffle.getRecentWinner() != address(0));
        assert(raffle.getAmountOfPlayers() == 0);
        assert(raffle.getLastTimeStamp() >= previousTimeStamp);
        
        assert(raffle.getRecentWinner().balance == STARTING_PLAYER_BALANCE + prize - entranceFee);
        //can test emit is welldone
    }
    
    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + playInterval + 1);
        vm.roll(block.number + 1);
        _;
    }
}
