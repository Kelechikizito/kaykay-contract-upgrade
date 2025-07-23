// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {KayKayV1} from "src/KayKayV1.sol";
import {KayKayV2} from "src/KayKayV2.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract UpgradeKayKay is Script {
    function run() external returns (address) {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        vm.startBroadcast();
        KayKayV2 kayKay = new KayKayV2();
        vm.stopBroadcast();
        address proxy = upgradeKayKay(mostRecentDeployment, address(kayKay));
        return proxy;
    }

    function upgradeKayKay(address proxyAddress, address newimplementation) public returns (address) {
        vm.startBroadcast();
        // Upgrade the proxy to the new implementation
        KayKayV1 proxy = KayKayV1(proxyAddress);
        proxy.upgradeTo(address(newimplementation));
        vm.stopBroadcast();
        return address(proxy);
    }
}
