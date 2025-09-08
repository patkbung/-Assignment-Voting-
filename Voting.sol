// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8 .30;

contract Voting {
    address officialAddress;
    string[] public candidateList;
    mapping(string => uint256) votesReceived;
    mapping(address => bool) isVoted;
    enum State {
        Created,
        Voting,
        Ended
    }
    State public state;

    constructor(string[] memory candidateNames) {
        officialAddress = msg.sender;
        candidateList = candidateNames;
        state = State.Created;
    }

    modifier onlyOfficial() {
        require(msg.sender == officialAddress, "Only Official");
        _;
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }
    //เพิ่มเงื่อนไข ended ก็ เริ่มใหม่ดั้ย
    function startVote() public onlyOfficial {
        require(state == State.Created || state == State.Ended, "Invalid state");
        state = State.Voting;
    }

    function endVote() public inState(State.Voting) onlyOfficial {
        state = State.Ended;
    }


    function candidateCount() public view returns(uint256) {
        return candidateList.length;
    }
    //add check จิงป่าว
    function isValidCandidate(string memory candidate) internal view returns(bool) {
        for (uint i = 0; i < candidateList.length; i++) {
            if (keccak256(bytes(candidateList[i])) == keccak256(bytes(candidate))) {
                return true;
            }
        }
        return false;
    }

    function voteForCandidate(string memory candidate) public inState(State.Voting) {
        require(isVoted[msg.sender] == false, "Already Voted");
        require(isValidCandidate(candidate), "Invalid candidate");
        isVoted[msg.sender] = true;
        votesReceived[candidate] += 1;

    }

    function totalVotesFor(string memory candidate) public inState(State.Ended) view returns(uint256) {
        return votesReceived[candidate];
    }
}