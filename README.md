# PredNext PoC

PredNext is an implementation of a prediction market. It allows users to participate in predictions by supplying liquidity, making token swaps based on their predictions, and redeeming rewards based on the outcome of the prediction.
The contract currently leverages role-based access control to manage administrative functions. Connection to an truth oracle like UMA for example are WIP.

## Contract Usage Instructions

#### Deploy Contract:

Deploy the PredNext contract with a specified minimum increment and initial admin address.

#### Supply Liquidity:

Call supplyLiquidity with the amount of POOL tokens to add to the liquidity pool.
Withdraw Liquidity:

Call withdrawLiquidity to remove POOL tokens from the liquidity pool.
Swap Tokens:

Call swap with the option ("buy_yes" or "buy_no") and the amount of POOL tokens to swap for YES or NO tokens.

#### Set Result:

Admin can call setResult to finalize the outcome of the prediction.

#### Redeem Tokens:

After the result is set, users can call redeem with the amount of YES or NO tokens to redeem POOL tokens.
Security Considerations
Role Management: Ensure only authorized users have the ADMIN_ROLE to set results and manage administrative functions.
Token Approvals: Users must approve the PredNext contract to transfer POOL tokens before calling swap.

## Foundry Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
