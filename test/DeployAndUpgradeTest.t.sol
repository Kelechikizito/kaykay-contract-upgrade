// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {KayKayV1} from "src/KayKayV1.sol";
import {KayKayV2} from "src/KayKayV2.sol";
import {DeployKayKay} from "script/DeployKayKay.s.sol";
import {UpgradeKayKay} from "script/UpgradeKayKay.s.sol";

contract DeployAndUpgradeTest is Test {
    DeployKayKay public deployer;
    UpgradeKayKay public upgrader;

    address public proxy;

    function setUp() public {
        deployer = new DeployKayKay();
        upgrader = new UpgradeKayKay();
        proxy = deployer.run();
    }

    function testProxyStartAsKayKayV1() public {
        // ACT / ASSERT
        vm.expectRevert();
        KayKayV2(proxy).setNumber(7);
    }

    function testKayKayV1InitialNumber() public view {
        // ARRANGE
        uint256 initialNumber = KayKayV1(proxy).getNumber();

        // ASSERT
        assertEq(initialNumber, 0);
    }

    function testKayKayV1Version() public view {
        // ARRANGE
        uint256 version = KayKayV1(proxy).version();

        // ASSERT
        assertEq(version, 1);
    }

    function testUpgrades() public {
        // ARRANGE
        KayKayV2 kayKay2 = new KayKayV2();
        upgrader.upgradeKayKay(proxy, address(kayKay2));

        // ARRANGE / ASSERT
        uint256 expectedValue = 2;
        assertEq(expectedValue, KayKayV2(proxy).version());

        // ACT / ASSERT
        KayKayV2(proxy).setNumber(7);
        assertEq(7, KayKayV2(proxy).getNumber());
    }

    function testMultipleUpgrades() public {
        // ARRANGE / ASSERT
        KayKayV2 kayKay2 = new KayKayV2();
        upgrader.upgradeKayKay(proxy, address(kayKay2));
        assertEq(KayKayV2(proxy).version(), 2);

        // ACT / ASSERT
        KayKayV2(proxy).setNumber(50);
        assertEq(KayKayV2(proxy).getNumber(), 50);

        // ARRANGE / ASSERT
        // Deploy another V2 instance and upgrade again
        KayKayV2 anotherKayKay2 = new KayKayV2();
        upgrader.upgradeKayKay(proxy, address(anotherKayKay2));

        // Should still be V2 and preserve state
        assertEq(KayKayV2(proxy).version(), 2);
        assertEq(KayKayV2(proxy).getNumber(), 50);
    }
}
