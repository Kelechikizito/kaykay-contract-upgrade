-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil scopefile

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: remove install build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install foundry-rs/forge-std --no-commit && forge install openzeppelin/openzeppelin-contracts@v4.8.3 --no-commit && forge install openzeppelin/openzeppelin-contracts-upgradeable@v4.8.3 --no-commit && forge install cyfrin/foundry-devops@0.0.11 --no-commit 

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account sepolia-acc --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv
endif

deploy:
	@forge script script/DeployKayKay.s.sol:DeployKayKay $(NETWORK_ARGS)

deploy-sepolia:
	@forge script script/DeployKayKay.s.sol:DeployKayKay --rpc-url $(SEPOLIA_RPC_URL) --account sepolia-acc --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv

upgrade:
	@forge script script/UpgradeKayKay.s.sol:UpgradeKayKay --rpc-url $(SEPOLIA_RPC_URL) --account sepolia-acc --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv