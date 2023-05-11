// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Election{
    struct Candidate{
        string name;
        uint num_votes;
    }

    struct Voter{
        string name;
        bool authorised;
        bool voted;
        uint vote_to;
    }

    //----------------- Implementing a timer ----------------------
    uint start;
    uint end;

    function startTimer() internal {
        start = block.timestamp;
        uint total_time = 43200; // 12 hours
        end = total_time + start;
    }

    modifier timeOver{
        require(block.timestamp <= end, "------------ Voting time has ended ------------");
        _;
    }

    function getTimeLeft() public timeOver view returns(uint){
        return (end - block.timestamp);
    }
    //------------------------------------------------------------


    address public owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    string public election_name;

    // Creating a dictionary key(address) and value(voter)
    mapping(address => Voter) public voters;

    Candidate[] public candidates;
    uint public total_votes;
    bool election_started;

    modifier ownerOnly(){
        require(msg.sender == owner);
        _;
    }

    // Starting the election only by owner of the smart contract
    function startElection(string memory _election_name) ownerOnly public {
        
        require(candidates.length > 0, "------------------- Number of candidates is ZERO -------------------");
        require(!election_started, "------------------- Election has already started -------------------");

        election_name = _election_name;
        startTimer();
        election_started = true;
    }
    
    // add a new candidate
    function addCandidate(string memory _candidate_name) ownerOnly public {

        require(!election_started, "------------------- Election has already started -------------------");
        candidates.push(Candidate(_candidate_name, 0));
    }

    // authorize the voter so he/she is allowed to vote
    function authorizeVoter(address _voter_address, string memory name) ownerOnly public {
        voters[_voter_address].name = name;
        voters[_voter_address].authorised = true;

    }

    // get back the total num of candidates
    function getNumCandidates() public view returns (uint){
        return candidates.length;
    }

    // vote for the your selected candidate
    function vote(uint candidate_index) public {
        require(!voters[msg.sender].voted);
        require(voters[msg.sender].authorised);

        voters[msg.sender].vote_to = candidate_index;
        voters[msg.sender].voted = true;

        candidates[candidate_index].num_votes++;
        total_votes++;
    }

    function endElection() view ownerOnly public returns (string memory) {

        require(block.timestamp >= end, "--------------- Election has not ended yet ---------------");

        uint winning_vote_count = 0;
        uint winning_candidate_index;

        // find the candidate with the most votes
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].num_votes > winning_vote_count) {
                winning_vote_count = candidates[i].num_votes;
                winning_candidate_index = i;
            }
        }

        // return the name of the winning candidate
        return candidates[winning_candidate_index].name;
    }


}