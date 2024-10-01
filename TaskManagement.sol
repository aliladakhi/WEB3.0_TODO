// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TaskManagementSystem {
    address public owner;
    uint256 public constant MAX_TASKS_PER_USER = 100;
    
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
    
    struct Comment {
        address author;
        string content;
        uint256 timestamp;
    }
    
    struct User {
        string username;
        bytes32 passwordHash;
        UserRole role;
        uint256 taskCount;
        address[] collaborators;
        bool exists;
    }
    
    enum TaskStatus { Created, InProgress, Completed, Cancelled }
    enum TaskPriority { Low, Medium, High, Urgent }
    enum UserRole { Basic, Premium }
    
    mapping(address => User) public users;
    mapping(address => Task[]) public userTasks;
    mapping(bytes32 => bool) public usernameExists;
    
    uint256 public totalTasks;
    uint256 public registrationFee;
    
    event UserRegistered(address indexed userAddress, string username);
    event TaskCreated(address indexed creator, uint256 indexed taskId, string title);
    event TaskUpdated(address indexed updater, uint256 indexed taskId);
    event TaskAssigned(uint256 indexed taskId, address indexed assignee);
    event CommentAdded(uint256 indexed taskId, address indexed commenter);
    event CollaboratorAdded(address indexed user, address indexed collaborator);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyRegisteredUser() {
        require(users[msg.sender].exists, "User not registered");
        _;
    }
    
    modifier validTaskId(uint256 taskId) {
        require(taskId < userTasks[msg.sender].length, "Invalid task ID");
        require(userTasks[msg.sender][taskId].exists, "Task does not exist");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        registrationFee = 0.01 ether;
    }
    
    function register(string memory username, string memory password) public payable {
        require(!users[msg.sender].exists, "User already registered");
        require(msg.value >= registrationFee, "Insufficient registration fee");
        
        bytes32 usernameHash = keccak256(abi.encodePacked(username));
        require(!usernameExists[usernameHash], "Username already taken");
        
        UserRole role = msg.value >= 0.05 ether ? UserRole.Premium : UserRole.Basic;
        
        users[msg.sender] = User({
            username: username,
            passwordHash: keccak256(abi.encodePacked(password)),
            role: role,
            taskCount: 0,
            collaborators: new address[](0),
            exists: true
        });
        
        usernameExists[usernameHash] = true;
        emit UserRegistered(msg.sender, username);
    }
    
    function createTask(
        string memory title,
        string memory description,
        uint256 deadline,
        TaskPriority priority,
        string[] memory tags
    ) public onlyRegisteredUser {
        require(users[msg.sender].taskCount < MAX_TASKS_PER_USER, "Task limit reached");
        require(bytes(title).length > 0, "Title cannot be empty");
        require(deadline > block.timestamp, "Deadline must be in the future");
        
        Task memory newTask = Task({
            title: title,
            description: description,
            deadline: deadline,
            assignee: address(0),
            status: TaskStatus.Created,
            priority: priority,
            tags: tags,
            exists: true,
            createdAt: block.timestamp,
            completedAt: 0,
            comments: new Comment[](0)
        });
        
        userTasks[msg.sender].push(newTask);
        users[msg.sender].taskCount++;
        totalTasks++;
        
        emit TaskCreated(msg.sender, userTasks[msg.sender].length - 1, title);
    }
    
    function updateTask(
        uint256 taskId,
        string memory title,
        string memory description,
        uint256 deadline,
        TaskPriority priority
    ) public onlyRegisteredUser validTaskId(taskId) {
        Task storage task = userTasks[msg.sender][taskId];
        
        task.title = title;
        task.description = description;
        task.deadline = deadline;
        task.priority = priority;
        
        emit TaskUpdated(msg.sender, taskId);
    }
    
    function assignTask(uint256 taskId, address assignee) 
        public 
        onlyRegisteredUser 
        validTaskId(taskId) 
    {
        require(users[assignee].exists, "Assignee must be a registered user");
        Task storage task = userTasks[msg.sender][taskId];
        task.assignee = assignee;
        task.status = TaskStatus.InProgress;
        
        emit TaskAssigned(taskId, assignee);
    }
    
    function addComment(uint256 taskId, string memory content) 
        public 
        onlyRegisteredUser 
        validTaskId(taskId) 
    {
        require(bytes(content).length > 0, "Comment cannot be empty");
        
        Comment memory newComment = Comment({
            author: msg.sender,
            content: content,
            timestamp: block.timestamp
        });
        
        userTasks[msg.sender][taskId].comments.push(newComment);
        emit CommentAdded(taskId, msg.sender);
    }
    
    function addCollaborator(address collaborator) public onlyRegisteredUser {
        require(users[collaborator].exists, "Collaborator must be a registered user");
        require(msg.sender != collaborator, "Cannot collaborate with yourself");
        
        User storage user = users[msg.sender];
        for (uint i = 0; i < user.collaborators.length; i++) {
            require(user.collaborators[i] != collaborator, "Already a collaborator");
        }
        
        user.collaborators.push(collaborator);
        emit CollaboratorAdded(msg.sender, collaborator);
    }
    
    function getTaskDetails(uint256 taskId) 
        public 
        view 
        onlyRegisteredUser 
        validTaskId(taskId) 
        returns (
            string memory title,
            string memory description,
            uint256 deadline,
            address assignee,
            TaskStatus status,
            TaskPriority priority,
            uint256 commentCount
        ) 
    {
        Task storage task = userTasks[msg.sender][taskId];
        return (
            task.title,
            task.description,
            task.deadline,
            task.assignee,
            task.status,
            task.priority,
            task.comments.length
        );
    }
    
    function getTaskComments(uint256 taskId) 
        public 
        view 
        onlyRegisteredUser 
        validTaskId(taskId) 
        returns (Comment[] memory) 
    {
        return userTasks[msg.sender][taskId].comments;
    }
    
    function getUserTasks() 
        public 
        view 
        onlyRegisteredUser 
        returns (
            uint256 totalUserTasks,
            uint256 completedTasks,
            UserRole role
        ) 
    {
        User storage user = users[msg.sender];
        uint256 completed = 0;
        
        for (uint256 i = 0; i < userTasks[msg.sender].length; i++) {
            if (userTasks[msg.sender][i].status == TaskStatus.Completed) {
                completed++;
            }
        }
        
        return (user.taskCount, completed, user.role);
    }
    

    function setRegistrationFee(uint256 newFee) public onlyOwner {
        registrationFee = newFee;
    }
    
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
