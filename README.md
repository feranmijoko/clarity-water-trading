# Clarity Water Trading Smart Contract

This smart contract manages the buying, selling, and reserve management of water. It is built using Clarity, the smart contract language for the Stacks blockchain. The contract allows users to buy and sell water, set prices, manage reserves, and more, with functionality tailored for decentralized water trading.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Contract Functions](#contract-functions)
  - [Setters](#setters)
  - [Water Trading](#water-trading)
  - [Reserve Management](#reserve-management)
  - [Refunds](#refunds)
  - [Transaction Fees](#transaction-fees)
  - [Security and Validations](#security-and-validations)
- [Error Handling](#error-handling)
- [Usage Example](#usage-example)
- [Deploying the Contract](#deploying-the-contract)
- [License](#license)

## Overview

This contract allows users to trade water in a decentralized way. Users can add water to the sale, remove it, and buy water from other users. The contract owner can set the price, transaction fee, refund percentages, and the global water reserve limits.

The core functionalities are designed to ensure fairness, security, and efficient management of the water reserve.

## Features

- **Water Price Management:** Set the price of water (by the contract owner).
- **Transaction Fees:** Charge transaction fees on trades.
- **Refund System:** Refund a portion of the STX balance when withdrawing water.
- **Reserve Management:** Manage global water reserves and user limits.
- **Water Trading:** Users can list water for sale, buy from others, or withdraw water.
- **Fee Calculation:** Automatically calculates transaction fees based on trade amounts.
- **Security:** Includes validations to prevent invalid transactions and malicious actions.

## Contract Functions

### Setters

#### `set-water-price (new-price uint)`

Sets the price per cubic meter of water. Only the contract owner can change the price.

- **Input:** New price in microstacks.
- **Error:** `err-owner-only` if not called by the contract owner, `err-invalid-price` if price is invalid.

#### `set-transaction-fee (new-fee-percentage uint)`

Sets the percentage of transaction fee applied to each trade. Only the contract owner can change the fee.

- **Input:** New fee percentage.
- **Error:** `err-owner-only` if not called by the contract owner, `err-invalid-fee` if fee is invalid.

#### `set-refund-percentage (new-percentage uint)`

Sets the percentage of refund when a user withdraws water.

- **Input:** Refund percentage.
- **Error:** `err-owner-only` if not called by the contract owner, `err-invalid-fee` if fee is invalid.

#### `set-water-reserve-limit (new-limit uint)`

Sets the maximum water reserve limit in the system. Only the contract owner can change this value.

- **Input:** New reserve limit in cubic meters.
- **Error:** `err-owner-only` if not called by the contract owner, `err-invalid-reserve-limit` if limit is too small.

### Water Trading

#### `add-water-for-sale (amount uint, price uint)`

Adds a specified amount of water to the sale at the set price. The user must have enough water to list for sale.

- **Input:** Amount and price per unit.
- **Error:** `err-invalid-amount`, `err-invalid-price`, `err-not-enough-water`.

#### `remove-water-from-sale (amount uint)`

Removes a specified amount of water from the sale.

- **Input:** Amount to remove.
- **Error:** `err-not-enough-water` if the user doesn't have enough water listed for sale.

#### `buy-water-from-user (seller principal, amount uint)`

Allows a user to buy water from another user. The price and fees are automatically calculated.

- **Input:** Seller’s address and the amount of water to buy.
- **Error:** `err-same-user` if the buyer is the seller, `err-not-enough-water` if there’s insufficient water for sale or insufficient funds.

### Reserve Management

#### `update-water-reserve (amount int)`

Updates the global water reserve. Adds or removes water from the reserve based on the input amount.

- **Input:** Amount to add or subtract from the reserve.
- **Error:** `err-reserve-limit-exceeded` if the new reserve exceeds the global limit.

#### `view-total-water-reserve`

Displays the current total water reserve in the system.

- **Output:** Current water reserve in cubic meters.

### Refunds

#### `refund-water (amount uint)`

Refunds a portion of the STX balance to the user based on the amount of water being withdrawn.

- **Input:** Amount of water to refund.
- **Error:** `err-not-enough-water` if the user doesn't have enough water to refund, `err-refund-failed` if the refund process fails.

#### `secure-refund-water (amount uint)`

Securely processes water refunds ensuring that only valid users receive refunds.

- **Input:** Amount of water to refund.
- **Error:** `err-not-enough-water` or `err-refund-failed`.

### Transaction Fees

#### `calculate-fee (amount uint)`

Calculates the transaction fee based on the provided amount.

- **Input:** Amount of the trade.
- **Output:** Calculated fee.

#### `calculate-refund (amount uint)`

Calculates the refund based on the amount of water being withdrawn.

- **Input:** Amount of water.
- **Output:** Refund amount in microstacks.

### Security and Validations

#### `validate-water-transfer (amount uint, receiver principal)`

Validates that a water transfer is being made to a different user and the amount is positive.

- **Input:** Amount and receiver's address.
- **Error:** `err-same-user` if the receiver is the sender, `err-invalid-amount` if the amount is invalid.

#### `verify-price (new-price uint)`

Verifies that the new water price is valid and not manipulated.

- **Input:** New water price.
- **Error:** `err-invalid-price` if the price is invalid.

## Error Handling

The contract defines several error codes to handle various failure scenarios:

- `err-owner-only`: Only the contract owner can perform certain actions.
- `err-not-enough-water`: The user doesn't have enough water for a transaction.
- `err-transfer-failed`: Water transfer operation failed.
- `err-invalid-price`: The price provided is invalid.
- `err-invalid-amount`: The amount provided is invalid.
- `err-invalid-fee`: The fee provided is invalid.
- `err-refund-failed`: The refund operation failed.
- `err-same-user`: A user cannot trade with themselves.
- `err-reserve-limit-exceeded`: The water reserve limit has been exceeded.
- `err-invalid-reserve-limit`: The reserve limit is invalid.

## Usage Example

Here is an example of how to interact with the contract:

1. **Set the water price:**
   ```clarity
   set-water-price 1000000
   ```

2. **Add water for sale:**
   ```clarity
   add-water-for-sale 100 2000000
   ```

3. **Buy water from a seller:**
   ```clarity
   buy-water-from-user seller-principal 10
   ```

4. **Refund water:**
   ```clarity
   refund-water 5
   ```

## Deploying the Contract

To deploy this contract, use the Clarity CLI or the Stacks Wallet with Clarity integration.

1. Compile the contract:
   ```bash
   clarity compile water-trading.clar
   ```

2. Deploy the contract to the Stacks blockchain:
   ```bash
   clarity deploy water-trading.clar --contract-name water-trading --network mainnet
   ```

3. Interact with the contract using Clarity transactions via the CLI or Stacks Wallet.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
