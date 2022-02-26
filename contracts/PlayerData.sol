import "./EnumType.sol" ;
  
library PlayerData{  

    
    struct votingStage{
        //private
        int votingStage1;
        int  votingStage2;
        //private
        EnumType.votingState phase;
        EnumType.revealVote reveal_1;
        EnumType.revealVote reveal_2;


    }

    struct playerState
    {
        EnumType.playerType playerType;
        int256 reputation;
        bytes32 position;
        uint256 weight;
        bytes32 username;
        mapping ( uint256 => bytes32 ) commitments;
        //mapping ( uint256 =>int ) votes;
        //the associative array designNo voting struct
        mapping ( uint256 =>votingStage) votes1;
        mapping ( uint256 => bool ) received;
        uint256[] designes;
        uint256 balance;
    }



}
