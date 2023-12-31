//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployRaffle} from "@script/DeployRaffle.s.sol";
import {Raffle} from "@src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "@script/HelperConfig.s.sol";

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
            Link
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


    function testCantEnterWhenLocked() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{
            value: entranceFee
        }();
        vm.warp(block.timestamp + playInterval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");
        vm.expectRevert(Raffle.Raffle__NotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{
            value: entranceFee
        }();
     
   }
}
