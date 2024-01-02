//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {Raffle} from "@src/Raffle.sol";


import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

import {LinkToken} from "@test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetConfig {
        uint256 entranceFee;
                uint256 playInterval;
                address VRFCoordinator;
                bytes32 VRFKeyHash;
                uint64 VRFSubId;
                uint32 VRFGasLimit;
                address LINK_Token;
                uint256 deployerKey;
    }

    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    NetConfig public activeNetConfig;

    constructor() {
        if(block.chainid == 11155111) {
            activeNetConfig = getSepoliaEthConfig();   
        } else {
            activeNetConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetConfig memory) { 
        return NetConfig({
            entranceFee: 0.01 ether,
            playInterval: 30,
            VRFCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            VRFKeyHash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            VRFSubId: 8177,
            VRFGasLimit: 500000,
            LINK_Token: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerKey: vm.envUint("PRIVATE_KEY")
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
        LinkToken link = new LinkToken();
        vm.stopBroadcast();

        return NetConfig({
            entranceFee: 0.01 ether,
            playInterval: 30,
            VRFCoordinator: address(VRFCoordinator),
            VRFKeyHash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            VRFSubId: 0,
            VRFGasLimit: 500000,
            LINK_Token: address(link),
            deployerKey:  DEFAULT_ANVIL_KEY
        });

    }
}
