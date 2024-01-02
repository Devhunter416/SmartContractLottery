//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";

import {Raffle} from "@src/Raffle.sol";

import {HelperConfig} from "@script/HelperConfig.s.sol";

import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

import {LinkToken} from "@test/mocks/LinkToken.sol";

import {DevOpsTools} from  "@dev-ops/DevOpsTools.sol";

contract CreateSub is Script {

    function createSubUsingConfig() public returns (uint64) {
        HelperConfig helper = new HelperConfig();
        (,,address VRFCoordinator, , , ,, ) = helper.activeNetConfig();
        return createSub(VRFCoordinator);
    }

    function createSub(address VRFCoordinator) public returns (uint64) {

        console.log("Creating sub on ChainId: ", block.chainid);
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(VRFCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your subId: ", subId);
        return subId;
    }


    function run() external returns(uint64) {
        return createSubUsingConfig();
    }
}

contract FundSub is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubUsingConfig() public {
        
        HelperConfig helper = new HelperConfig();
        (,,address VRFCoordinator, , uint64 subId, , address Link,) = helper.activeNetConfig();
        fundSub(VRFCoordinator, subId, Link);
        
    }

    function fundSub(address VRFCoordinator, uint64 subId, address Link) public {
        console.log("Funding sub: ", subId);
        console.log("Using coordinator", VRFCoordinator);
        console.log("On chain: ", block.chainid);
        
        if(block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(VRFCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(Link).transferAndCall(VRFCoordinator, FUND_AMOUNT, abi.encode(subId));
            vm.stopBroadcast();
        }
    }

    function run() external {

        fundSubUsingConfig();
    }
}

contract AddConsumer is Script {


    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helper = new HelperConfig();
        
        (,,address VRFCoordinator , , uint64 subId, , , uint256 deployerKey)= helper.activeNetConfig();

        addConsumer(subId, VRFCoordinator, raffle, deployerKey);
    }

    function addConsumer(uint64 subId, address VRFCoordinator, address raffle, uint256 deployerKey) public {
        console.log("adding consumer: ", raffle);
        console.log("Using coordinator: ", VRFCoordinator);
        console.log("On chainId: ", block.chainid);
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(VRFCoordinator).addConsumer(subId, raffle); 
        vm.stopBroadcast();

    }


    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);

        addConsumerUsingConfig(raffle);
    }
}
