# trust-ledger-web3

This is a small Solidity project where I experimented with how blockchain could be used for transparent civic systems instead of just finance. The idea is simple: people can register an identity hash, take part in polls, and review long-term public promises whose outcomes affect a basic on-chain credibility score.

I built this mainly to learn more about smart contract design, governance logic, and how community-driven verification might work in a Web3 setting.

## What the contract does

* Lets users join using a unique identity hash
* Allows creation of tasks/promises with deadlines
* Community members can review a task once the deadline passes
* Final outcome updates a simple reputation score
* Includes a lightweight poll/voting system

## Project Structure

```
contracts/
 └── CivicTrack.sol
```

## Why I Made This

I wanted to explore how Ethereum’s immutability could be applied to something closer to public accountability. This isn’t meant to be a production-ready governance system — it’s more of a learning project and a personal experiment with Solidity.

## Tech

* Solidity ^0.8.x
* Basic DAO-style logic
* Event-driven contract design

