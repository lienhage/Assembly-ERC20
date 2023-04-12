# Sample Hardhat-Foundry Project

This project demonstrates a basic Hardhat develop suite with foundry testing framework build in. It comes with a sample contract, test cases for both hardhat and foundry, and a script that deploys that contract. And it also integrates other common dependencies

This project demonstrates an advanced dapp develop suite which has following features:
- Hardhat development environment with foundry testing framework built in
- Git flows that run unit tests and perform code static analysis
- Pull request & Issue templates

## Pre-requisites

- install foundry
- npm version 7 or later

## Commands
- start-up
```shell
git clone https://github.com/lienhage/hardhat-foundry-template.git
npm install
```

- test
```shell
npx hardhat test
REPORT_GAS=true npx hardhat test
or
forge test
```
- scripts
```shell
npx hardhat run scripts/deploy.ts
```
