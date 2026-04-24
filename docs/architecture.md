Each system component (Registry, Compliance, Token) is independently upgreadable

# ComplianceToken responsibilities


`ComplianceToken` is the main ERC-3643-style token contract.

It represents the regulated security token that investors hold. It behaves similarly to an ERC-20 token,
but adds compliance and identity checks before important actions such as minting and transferring.

In simple words, `ComplianceToken` is responsible for storing token balances and executing token operations
only when the investor identity and compliance rules allow it.

Main responsibilities:

- Store investor token balances.
- Allow verified investors to transfer tokens.
- Block transfers to non-verified wallets.
- Call `MockIdentityRegistry` to check whether a wallet is verified.
- Call `ComplianceService` to check whether a transfer follows compliance rules.
- Allow authorized agents to mint new tokens.
- Allow authorized agents to burn tokens.
- Support freezing addresses if needed.
- Support emergency pause if needed.

# MockIdentityRegistry responsibilities

`MockIdentityRegistry` is a simplified test version of the ERC-3643 Identity Registry.

In the real T-REX architecture, each investor has a dedicated ONCHAINID smart contract,
which represents their on-chain identity and stores claims issued by trusted issuers.
The Identity Registry does not store the full KYC data itself. Instead, it maps investor
wallet addresses to their ONCHAINID contract addresses:

```solidity
mapping(address walletAddress => address onchainIdAddress) private _identities;
```

In simple words, it is responsible for user verification on-chain

# ComplianceService responsibilities

The Compliance Service is a pluggable module implementing the ICompliance interface from the T-REX standard. It is called synchronously within the token's _transfer() function. If the compliance check returns false, the transfer reverts

It maintains a set of modular sub-rules:

 - MaxInvestors
 - CountryBlock
 - MaxBalance
 - MinBalance
 - TimeRestriction
 - ExchangeMonthlyLimit

 ## Interaction Flow

1. Admin registers an investor address in MockIdentityRegistry.
2. Investor A calls `transfer(to, amount)` on ComplianceToken.
3. ComplianceToken checks whether both sender and receiver are verified in MockIdentityRegistry.
4. ComplianceToken calls ComplianceService to validate the transfer rules.
5. ComplianceService checks active compliance rules such as country block, max balance, min balance and time restrictions.
6. If all checks pass, ComplianceToken executes the transfer.
7. If any check fails, the transaction reverts.

## Simple diagram


Investor
   |
   v
ComplianceToken.transfer()
   |
   |-- checks --> MockIdentityRegistry
   |
   |-- checks --> ComplianceService
   |
   v
Transfer executed or reverted

## Planned Events

- `IdentityRegistered(address investor)`
- `IdentityRemoved(address investor)`
- `ComplianceServiceUpdated(address newComplianceService)`
- `IdentityRegistryUpdated(address newIdentityRegistry)`
- `CountryBlocked(uint16 countryCode)`
- `CountryUnblocked(uint16 countryCode)`
- `MaxInvestorsUpdated(uint256 newLimit)`
- `MaxBalanceUpdated(uint256 newLimit)`
- `MinBalanceUpdated(uint256 newLimit)`
- `TokensFrozen(address investor, uint256 amount)`
- `TokensUnfrozen(address investor, uint256 amount)`


## Planned Roles

### Owner / Admin
Responsible for deploying contracts and configuring system addresses.

### Agent
Can mint tokens, burn tokens, and perform administrative token operations.

### Compliance Officer
Can configure compliance rules such as blocked countries, investor limits, and balance limits.

### Investor
A verified user who can hold and transfer tokens if compliance checks pass.

### Mock KYC Provider
In the MVP, this is simulated by the admin registering addresses in MockIdentityRegistry.