pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


contract Voting  {
mapping(uint=>Candidate) public candidateIndex;
mapping(address=>bool) public aCandidate;
mapping(address=>bool) private hasVoted;

uint public candidateCount;

struct Candidate{
    string name;
    uint id;
    uint voteCount;
    address _add;
}


modifier isNotCandidate(address _target){
    require(aCandidate[_target]==false,'You are already registered as a candidate');
    _;
}

modifier isCandidate(address _target){
    
    require(aCandidate[_target]==true,'Not a valid candidate');
    _;
}

modifier onlyOwner{
    require (msg.sender==owner);
    _;
}


//requires that the deadline hasn't passed
modifier voteStillValid(){
    require (now<=deadlineInDays,"this election has expired");
    _;
}

string public electionName;

string public electionDescription;

uint deadlineInDays;

address public owner;

event voted(uint _candidate);

event newDeadlineSet(uint _newDeadline);

 constructor (string memory _name,string memory _description,uint _days) public
    {
        electionName=_name;
        electionDescription=_description;
        deadlineInDays=now+_days*1 days;
        owner=msg.sender;
        
        
    }

 //anyone who wants to become a candidate provided you are not a candidate before
 function becomeCandidate(string memory name) public  voteStillValid() isNotCandidate(msg.sender){
     
     candidateIndex[candidateCount]= Candidate(name,candidateCount,0,msg.sender);
     aCandidate[msg.sender]=true;
     candidateCount++;
 }
 
 //main vote function to vote for any candidateCount
 //makes sure you haven't voted before and you are not a candidate
function vote(uint index) public   voteStillValid() returns(bool){
 require (aCandidate[msg.sender]==false,"you are a candidate");
 require (hasVoted[msg.sender]==false,"you have already voted");
 require (index>=0 && index <= candidateCount+1);
 candidateIndex[index].voteCount++;
 hasVoted[msg.sender]=true;
  emit voted(index);
 return (true);


}

//Returns all the candidates and their corresponding number of votes
function getCandidates() external view returns (string[] memory,uint[] memory){
    string[] memory names = new string[](candidateCount);
    uint[] memory voteCounts = new uint[](candidateCount);
    for (uint i = 0; i < candidateCount; i++) {
        names[i] = candidateIndex[i].name;
        voteCounts[i] = candidateIndex[i].voteCount;
    }
    return (names, voteCounts);
}

//This function returns the candidate with the highest number of votes at that point in time
function getWinner()public view returns(string memory,uint){
    uint winningVote=0;
    for(uint p=0;p<candidateCount;p++){
        if (candidateIndex[p].voteCount>winningVote){
            winningVote=candidateIndex[p].voteCount;
            string memory winner= candidateIndex[p].name;
            return (winner,winningVote);
        }
    }
}

    //allows the election creator to set a new election deadline
    function setNewDeadline(uint _newDays) public onlyOwner voteStillValid returns(uint){
        deadlineInDays=now+_newDays*1 days;
        emit newDeadlineSet(deadlineInDays);
        return deadlineInDays;
    }
    
    //returns when the election will end
    function getDeadline() public view returns(uint){
        return deadlineInDays;
    }

} 
