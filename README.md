# Foundry Fund Me

## Table of Contents
* [General Information](#general-information)
* [Requirements](#requirements)
* [Prerequisites](#prerequisites)
* [Program Usage](#program-usage)
* [Project Status](#project-status)

## General Information 
> Smart Contract for fund endowment using Foundry.

## Requirements 
* `Solidity`
* `Foundry`
* `Foundry-ZkSync`
* `Chainlink Data Feeds`
* `smartcontractkit/chainlink-brownie-contracts`
* `foundry-rs/forge-std`
* `cyfrin/foundry-devops`

## Prerequisites
> **Ensure that you're in the `main` branch** </br>

**Clone this repository using the following command line (git bash)**
```
$ git clone https://github.com/sivaren/foundry-fund-me.git
```

## Program Usage
* Open `cmd` on this folder and install dependencies

  ```
  forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit
  forge install foundry-rs/forge-std@v1.8.2 --no-commit
  forge install cyfrin/foundry-devops@0.2.2 --no-commit
  ```
* Deploy `FundMe` contract on **Sepolia Test Network**
  ```
  forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
  ```
* Run all **test** cases
  ```
  forge test  
  ```
* Run specific **test** case
  ```
  forge test --mt <TEST_FUNCTION_NAME> 
  ```
* Inspect **test coverage**
  ```
  forge coverage
  ```
* Interact with `FundMe` contract | `fund()`
  ```
  cast send <CONTRACT_ADDRESS> "fund()" --value 0.01ether --private-key <PRIVATE_KEY> 
  ```
* Interact with `FundMe` contract | `withdraw()`
  ```
  cast send <CONTRACT_ADDRESS> "withdraw()" --private-key <PRIVATE_KEY>
  ```

## Project Status
> **Project is: DONE**
