// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {KayKayV1} from "src/KayKayV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployKayKay is Script {
    function run() external returns (address) {
        address proxy = deployKayKay();
        return proxy;
    }

    function deployKayKay() public returns (address) {
        vm.startBroadcast();
        KayKayV1 kayKay = new KayKayV1();
        ERC1967Proxy proxy = new ERC1967Proxy(address(kayKay), "");
        KayKayV1(address(proxy)).initialize();
        vm.stopBroadcast();
        return address(proxy);
    }
}
