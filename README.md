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
- Ethereum development environment (e.g., Hardhat, Truffle)
- Solidity compiler version 0.8.0 or higher

### Deployment
1. Deploy the contract to your chosen Ethereum network
2. The deploying address becomes the contract owner

### Interacting with the Contract
1. **Registration**:
   ```javascript
   await contract.register("username", "password", {value: ethers.utils.parseEther("0.01")});
   ```

2. **Creating a Task**:
   ```javascript
   await contract.createTask(
     "Task Title",
     "Task Description",
     deadline, // Unix timestamp
     1, // Priority: 0=Low, 1=Medium, 2=High, 3=Urgent
     ["tag1", "tag2"]
   );
   ```

3. **Assigning a Task**:
   ```javascript
   await contract.assignTask(taskId, assigneeAddress);
   ```

## Security Considerations
- All user passwords are hashed using keccak256
- Registration fee prevents spam accounts
- Task limit per user prevents DOS attacks
- Only task creators can modify their tasks
- Contract owner can only modify registration fee and withdraw funds

## Gas Optimization
- Efficient data structures to minimize gas costs
- Task limit prevents excessive storage usage
- Careful use of storage vs memory variables

## Testing
Recommended test cases:
1. User registration with correct/incorrect fees
2. Task creation and validation
3. Collaboration and task assignment
4. Access control for various functions

## Frontend Integration
The contract emits events for all major actions, allowing frontends to:
- Track task creation and updates in real-time
- Monitor user registrations and collaborations
- Update UI based on task status changes

## License
This project is licensed under the MIT License - see the LICENSE file for details

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
