[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

# KayKay Contract Upgrade

A minimal UUPS‑upgradeable proxy setup for the KayKay token contract, built and tested with Foundry and OpenZeppelin Upgradeable libraries.

---

## 📜 Overview

* **Name**: KayKay Contract Upgrade
* **Proxy (ERC1967)**: [0x22a2b4c3aa9a20efce1c02f08ac4f991fb327c68](https://sepolia.etherscan.io/address/0x22a2b4c3aa9a20efce1c02f08ac4f991fb327c68)
* **Implementation V1**: [KayKayV1 (0x259f…88e4)](https://sepolia.etherscan.io/address/0x259f0f3845D119E2Ac39d49518A173A3d93888e4#code)
* **Implementation V2**: [KayKayV2 (0xDDEB…885)](https://sepolia.etherscan.io/address/0xDDEB0933192020f3769dc7080fBCA7a28b9D885D)
* **Pattern**: UUPS (Universal Upgradeable Proxy Standard) via OpenZeppelin
* **Language**: Solidity ^0.8.18
* **Frameworks & Libraries**:

  * Foundry (`forge-std`, `forge script`)
  * OpenZeppelin Upgradeable (`UUPSUpgradeable`, `Initializable`, `OwnableUpgradeable`)

---

## 🏗️ Upgradeable Pattern

This project uses the **UUPS** proxy pattern:

1. **Proxy** (`ERC1967Proxy`) holds the state and delegates calls.

2. **Implementation** contracts (`KayKayV1`, `KayKayV2`) contain logic.

3. **Initializer** replaces constructors in upgradeable contracts:

   ```solidity
   function initialize() public initializer {
     __Ownable_init();
     __UUPSUpgradeable_init();
   }
   ```

4. **Authorization**: only the contract `owner` can call `upgradeTo(...)`, enforced via `UUPSUpgradeable`’s `_authorizeUpgrade`.

---

## 🚀 Deployment & Upgrade Scripts

All scripts are under `script/` and use Foundry’s `Script` abstraction.

### Deploy (V1)

```bash
forge script script/DeployKayKay.s.sol:DeployKayKay \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $DEPLOYER_KEY \
  --broadcast
```

```solidity
// DeployKayKay.s.sol
contract DeployKayKay is Script {
  function run() external returns (address) {
    vm.startBroadcast();
    KayKayV1 impl = new KayKayV1();
    ERC1967Proxy proxy = new ERC1967Proxy(address(impl), "");
    KayKayV1(address(proxy)).initialize();
    vm.stopBroadcast();
    return address(proxy);
  }
}
```

### Upgrade to V2

```bash
forge script script/UpgradeKayKay.s.sol:UpgradeKayKay \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $DEPLOYER_KEY \
  --broadcast
```

```solidity
// UpgradeKayKay.s.sol
contract UpgradeKayKay is Script {
  function run() external returns (address) {
    address proxyAddr = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
    vm.startBroadcast();
    KayKayV2 newImpl = new KayKayV2();
    KayKayV1(proxyAddr).upgradeTo(address(newImpl));
    vm.stopBroadcast();
    return proxyAddr;
  }
}
```

---

## ✅ Testing

Located in `test/`, run all unit tests with:

```bash
forge test -vv
```

Tests cover:

* Proxy & implementation interaction
* `initialize()` idempotence
* `upgradeTo(...)` access control and state preservation
* Any new logic added in V2

---

## 🔒 Security Considerations

* **Ownable & UUPSUpgradeable**: Only owner may upgrade.
* **Initializer Guard**: `initializer` modifier prevents re‑initialization.
* **State Preservation**: Storage layout compatibility between V1 and V2.
* **ReentrancyGuard** (if used in V2) protects against reentrant calls.

---

## 📚 References

* OpenZeppelin UUPSUpgradeable Docs: [https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable](https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable)
* Foundry Book: [https://book.getfoundry.sh/](https://book.getfoundry.sh/)
* EIP‑1967 (Proxy Storage Slots): [https://eips.ethereum.org/EIPS/eip-1967](https://eips.ethereum.org/EIPS/eip-1967)

---

## 📄 License

This project is licensed under the MIT License.
