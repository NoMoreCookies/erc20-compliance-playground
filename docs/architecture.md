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