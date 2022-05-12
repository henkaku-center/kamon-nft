require('dotenv').config()
// npx hardhat verify --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS
module.exports = [process.env.TOKEN_ADDRESS, process.env.FUND_ADDRESS]
