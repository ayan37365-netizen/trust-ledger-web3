// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CivicTrack {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Task {
        uint256 id;
        address creator;
        string text;
        uint256 endTime;

        bool closed;
        bool success;

        uint256 up;
        uint256 down;
    }

    struct Poll {
        uint256 id;
        string name;
        uint256 yes;
        uint256 no;
        bool live;
    }

    uint256 public taskIndex;
    uint256 public pollIndex;

    mapping(uint256 => Task) public tasks;
    mapping(uint256 => Poll) public polls;

    mapping(uint256 => mapping(address => bool)) voted;
    mapping(uint256 => mapping(address => bool)) reviewed;

    mapping(bytes32 => bool) private takenIds;
    mapping(address => bytes32) public idOf;

    mapping(address => int256) public score;

    event Joined(address user);
    event NewTask(uint256 id, address by);
    event Review(uint256 id, address who, bool side);
    event TaskClosed(uint256 id, bool ok);
    event NewPoll(uint256 id);
    event Cast(uint256 id, address who, bool side);

    function join(bytes32 hash) external {

        require(idOf[msg.sender] == bytes32(0), "already in");
        require(!takenIds[hash], "id exists");

        idOf[msg.sender] = hash;
        takenIds[hash] = true;

        emit Joined(msg.sender);
    }

    function openTask(string memory text, uint256 endTime) external {

        require(endTime > block.timestamp, "bad time");
        require(bytes(text).length > 0, "empty");

        taskIndex++;

        tasks[taskIndex] = Task({
            id: taskIndex,
            creator: msg.sender,
            text: text,
            endTime: endTime,
            closed: false,
            success: false,
            up: 0,
            down: 0
        });

        emit NewTask(taskIndex, msg.sender);
    }

    function reviewTask(uint256 id, bool side) external {

        require(id > 0 && id <= taskIndex, "invalid task");

        Task storage t = tasks[id];

        require(block.timestamp >= t.endTime, "wait more");
        require(!t.closed, "done");
        require(idOf[msg.sender] != bytes32(0), "no id");
        require(!reviewed[id][msg.sender], "reviewed");

        reviewed[id][msg.sender] = true;

        if(side) {
            t.up++;
        } else {
            t.down++;
        }

        emit Review(id, msg.sender, side);
    }

    function closeTask(uint256 id) external {

        require(id > 0 && id <= taskIndex, "invalid task");

        Task storage t = tasks[id];

        require(!t.closed, "closed");
        require(block.timestamp >= t.endTime, "early");
        require(t.up + t.down > 0, "no reviews");

        t.closed = true;

        if(t.up > t.down) {
            t.success = true;
            score[t.creator] += 10;
        } else {
            t.success = false;
            score[t.creator] -= 15;
        }

        emit TaskClosed(id, t.success);
    }

    function newPoll(string memory name) external {

        require(bytes(name).length > 0, "empty");

        pollIndex++;

        polls[pollIndex] = Poll({
            id: pollIndex,
            name: name,
            yes: 0,
            no: 0,
            live: true
        });

        emit NewPoll(pollIndex);
    }

    function cast(uint256 id, bool side) external {

        require(id > 0 && id <= pollIndex, "invalid poll");

        Poll storage p = polls[id];

        require(p.live, "not live");
        require(idOf[msg.sender] != bytes32(0), "join first");
        require(!voted[id][msg.sender], "already");

        voted[id][msg.sender] = true;

        if(side) {
            p.yes++;
        } else {
            p.no++;
        }

        emit Cast(id, msg.sender, side);
    }

    function stopPoll(uint256 id) external {
        require(msg.sender == owner, "owner only");
        require(id > 0 && id <= pollIndex, "invalid poll");

        polls[id].live = false;
    }
}
