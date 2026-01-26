// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PeerSwap {
    struct Swap {
        address initiator;
        address counterparty;
        bytes32 secretHash;
        uint256 amount;
        uint256 deadline;
        bool completed;
        bool refunded;
    }

    mapping(uint256 => Swap) public swaps;
    uint256 public swapCount;

    event SwapInitiated(uint256 indexed swapId, address indexed initiator, address counterparty, bytes32 secretHash);
    event SwapCompleted(uint256 indexed swapId);
    event SwapRefunded(uint256 indexed swapId);

    error DeadlinePassed();
    error DeadlineNotReached();
    error InvalidSecret();

    function initiateSwap(address counterparty, bytes32 secretHash, uint256 duration) external payable returns (uint256) {
        uint256 swapId = swapCount++;
        swaps[swapId] = Swap({
            initiator: msg.sender,
            counterparty: counterparty,
            secretHash: secretHash,
            amount: msg.value,
            deadline: block.timestamp + duration,
            completed: false,
            refunded: false
        });
        emit SwapInitiated(swapId, msg.sender, counterparty, secretHash);
        return swapId;
    }

    function completeSwap(uint256 swapId, bytes32 secret) external {
        Swap storage swap = swaps[swapId];
        if (block.timestamp > swap.deadline) revert DeadlinePassed();
        if (keccak256(abi.encodePacked(secret)) != swap.secretHash) revert InvalidSecret();
        swap.completed = true;
        emit SwapCompleted(swapId);
    }

    function refundSwap(uint256 swapId) external {
        Swap storage swap = swaps[swapId];
        if (block.timestamp <= swap.deadline) revert DeadlineNotReached();
        swap.refunded = true;
        emit SwapRefunded(swapId);
    }
}
