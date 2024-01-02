-include .env

.PHONY: all test deploy

DEFAULT_ANVIL_KEY:=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80


help:
	@echo "Useage:"
	@echo "    make deploy [ARGS=...]"

build:; forge build

install:; forge install Cyfrin/foundry-devops --no-commit && forge install transimissions11/solmate --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/froge-std --no-commit


test:; forge test

NETWORK_ARGS:= --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

# if --network sepolia
ifeq ($(findstring --network sepolia,$(ARGS)), --network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

anvil:
	 anvil:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

deploy:
	@forge script script/DeployRaffle.s.sol:DeplyRaffle $(NETWORK_ARGS)



