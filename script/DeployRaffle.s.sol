//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {Raffle} from "@src/Raffle.sol";

import {HelperConfig} from "./HelperConfig.s.sol";

import {CreateSub, FundSub, AddConsumer} from "./Interactions.s.sol";


contract DeployRaffle is Script {

    function run() external returns(Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 playInterval,
            address VRFCoordinator,
            bytes32 VRFKeyHash,
            uint64 VRFSubId,
            uint32 VRFGasLimit,
            address Link,
            uint256 deployerKey
        ) = helperConfig.activeNetConfig();

        if(VRFSubId == 0) {
            //create a sub
            CreateSub createSub = new CreateSub();
            VRFSubId = createSub.createSub(VRFCoordinator);

            //fund
            FundSub fundSub = new FundSub();
            fundSub.fundSub(VRFCoordinator, VRFSubId, Link);
            
        }
        vm.startBroadcast();
        Raffle raffle = new Raffle( 
                                   entranceFee,
                                   playInterval,
                                   VRFCoordinator,
                                   VRFKeyHash,
                                   VRFSubId,
                                   VRFGasLimit);

        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(VRFSubId, VRFCoordinator, address(raffle), deployerKey);

        return (raffle, helperConfig);
    }
}
