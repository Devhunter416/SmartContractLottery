//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {Raffle} from "@src/Raffle.sol";

import {HelperConfig} from "@script/HelperConfig.s.sol";


contract DeployRaffle is Script {

    function run() external returns(Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 playInterval,
            address VRFCoordinator,
            bytes32 VRFKeyHash,
            uint64 VRFSubId,
            uint32 VRFGasLimit
        ) = helperConfig.activeNetConfig();
        vm.startBroadcast();
        Raffle raffle = new Raffle( 
                                   entranceFee,
                                   playInterval,
                                   VRFCoordinator,
                                   VRFKeyHash,
                                   VRFSubId,
                                   VRFGasLimit );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}
