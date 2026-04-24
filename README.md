# erc20-compliance-playground

## Short overview

This MVP is a simplified permissioned token system built around three contracts: `ComplianceToken`, `MockIdentityRegistry`, and `ComplianceService`.

The token can only be minted to and transferred between approved investors, and every transfer is checked against compliance rules before execution.

## MVP scope

- ERC-20 token with minting
- role-based access control
- mock identity registry
- compliance checks before transfer
- country block rule
- max investors rule
- minimum residual balance rule
- lock-up rule
- unit and integration tests
- local deployment on Anvil

## Architecture

The MVP is built around three main contracts:

- `ComplianceToken` — the main ERC-20 token contract with minting, pause/freeze restrictions, and transfer hooks
- `MockIdentityRegistry` — a simplified registry storing wallet registration status, verification status, and country code
- `ComplianceService` — a rule engine that validates transfers before execution

### High-level flow

```text
User / Agent
    |
    v
ComplianceToken
    | \
    |  \__ checks admin restrictions (pause / freeze / mint permissions)
    |
    v
ComplianceService
    |
    v
MockIdentityRegistry