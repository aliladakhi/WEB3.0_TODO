# Decentralized Task Management System

## Overview
This smart contract implements a decentralized task management system on the Ethereum blockchain. Users can create, manage, and collaborate on tasks in a secure and transparent manner.

## Features
- **User Authentication**: Secure registration and login system
- **Task Management**: Create, update, and assign tasks
- **Collaboration**: Add collaborators to work on tasks together
- **Priority Levels**: Assign different priority levels to tasks
- **Comments**: Add comments to tasks for better communication
- **Two-Tier System**: Basic and Premium user roles with different capabilities

## Data Structures

### User
```solidity
struct User {
    string username;
    bytes32 passwordHash;
    UserRole role;
    uint256 taskCount;
    address[] collaborators;
    bool exists;
}
```

### Task
```solidity
struct Task {
    string title;
    string description;
    uint256 deadline;
    address assignee;
    TaskStatus status;
    TaskPriority priority;
    string[] tags;
    bool exists;
    uint256 createdAt;
    uint256 completedAt;
    Comment[] comments;
}
```

## Main Functions

### Registration
```solidity
function register(string memory username, string memory password) public payable
```
- Requires registration fee (0.01 ETH for Basic, 0.05 ETH for Premium)
- Ensures unique username
- Emits `UserRegistered` event

### Task Creation
```solidity
function createTask(
    string memory title,
    string memory description,
    uint256 deadline,
    TaskPriority priority,
    string[] memory tags
) public
```
- Only registered users can create tasks
- Enforces task limit per user
- Emits `TaskCreated` event

### Task Assignment
```solidity
function assignTask(uint256 taskId, address assignee) public
```
- Assigns task to another registered user
- Changes task status to `InProgress`
- Emits `TaskAssigned` event

## Events
- `UserRegistered(address indexed userAddress, string username)`
- `TaskCreated(address indexed creator, uint256 indexed taskId, string title)`
- `TaskUpdated(address indexed updater, uint256 indexed taskId)`
- `TaskAssigned(uint256 indexed taskId, address indexed assignee)`
- `CommentAdded(uint256 indexed taskId, address indexed commenter)`
- `CollaboratorAdded(address indexed user, address indexed collaborator)`

## Usage

### Prerequisites
- Ethereum wallet (e.g., MetaMask)
- - Solidity compiler version 0.8.0 or higher

### Deployment
1. Deploy the contract to your chosen Ethereum network
2. The deploying address becomes the contract owner


