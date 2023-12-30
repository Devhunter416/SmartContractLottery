//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {Raffle} from "@src/Raffle.sol";


import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    struct NetConfig {
        uint256 entranceFee;
                uint256 playInterval;
                address VRFCoordinator;
                bytes32 VRFKeyHash;
                uint64 VRFSubId;
                uint32 VRFGasLimit;
    }

    NetConfig public activeNetConfig;

    constructor() {
        if(block.chainid == 11155111) {
            activeNetConfig = getSepoliaEthConfig();   
        } else {
            activeNetConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetConfig memory) { 
        return NetConfig({
            entranceFee: 0.01 ether,
            playInterval: 30,
            VRFCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            VRFKeyHash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            VRFSubId: 8177,
            VRFGasLimit: 500000
        });
    }
    function getOrCreateAnvilEthConfig() public returns(NetConfig memory) {
        if(activeNetConfig.VRFCoordinator != address(0)) {
            return activeNetConfig;
        }
        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast();
        VRFCoordinatorV2Mock VRFCoordinator = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);
        vm.stopBroadcast();

        return NetConfig({
            entranceFee: 0.01 ether,
            playInterval: 30,
            VRFCoordinator: address(VRFCoordinator),
            VRFKeyHash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            VRFSubId: 0,
            VRFGasLimit: 500000
        });

    }
}