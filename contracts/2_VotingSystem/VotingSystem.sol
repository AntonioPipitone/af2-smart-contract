
/**
 * @file marketplace.sol
 * @author Nachiket Tapas <ntapas@unime.it>
 * @date created 01 Jun 2020
 * @date last modified 09 Jul 2020
 * @SPDX-License-Identifier: UNLICENSED*/

//TODO FARE LA CLAIM PER LE PERSONE CHE HANNO UN BALANCE POSITIVO
//import { AntoTokenSale } from "./AntoTokenSale.sol";
//import { TestToken } from "./TestToken.sol";

pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Interfaces/IUser.sol";
import "./Structs/VotingSystemStructs.sol";

contract VotingSystem{
    
    IUser private user;
    constructor(address _address){
        user = IUser(_address);
    }

//              TEST FUNCTION 
//#################################################
    function getPlayer()public view returns(bool){

        return user.isPlayer(msg.sender);
    }
//            END TEST FUNCTION    
//#################################################



//                  DATA SECTION  
//#############################################################
//#############################################################
    //Mapping if the proof exists
    //Mapping of design identified by design index and collection of players indexes registered to vote
    mapping (uint256 => mapping(address=>bool)) public checkPlayer;
    mapping (uint256 => mapping (address => designState)) public TcheckPlayers;
    // This is the commitment for every design the user has committed to
    mapping (address=>mapping(uint=>bytes32))public userDesignCommitment;
    // At every player address we associate the corresponding vote he made for 
    // the specific design
    mapping (address=>mapping(uint256=>votingStage)) public playerVote;
    mapping (uint256 => address[]) public regPlayers;
    //Design details indexed by design index
    mapping (uint256 => designState) public designes;
    uint256 public numDesignes = 0;

    //IMPORTANT : USAGE REQUIRED FOR OTHER OPERATIONS 
    //mapping(uint256 => DataLib.DesignToken) trackDesignToken;
//                  END DATA SECTION   
//##############################################################
//##############################################################


//                   EVENT SECTION
// #############################################################
//##############################################################
    event newPrinterAddition(address player_address, bool status);

    //event newPlayerAddition(address player_address);
    //Notifications for successful completion of events
    event newDesignAvailable(
        bytes32 file_hash,
        uint256 design_number,
        address creator
    );
    event resultCalculated(
        bytes32 file_hash,
        uint256 design_number,
        address creator
    );
    event newPlayerAddition(address player_address, bool status);
    event newPlayerRegistration(
        address player_address,
        uint256 design_number,
        bool status
    );
    event playerDesignReceived(uint256 design_number, address player_address);
    event playerCommitted(uint256 design_number, address player_address);
    event playerRevealed(uint256 design_number, address player_address);
    event votingResult(int256 result);
    event phase2Begin(uint256 design_number, address vendor, uint256 time);

    event proofAdded(
        uint256 design_number,
        address player_address,
        address printer_address
    );

    event tempOutput(address _output); //, uint256 timestamp, uint256 expiry, uint256 balance);
//                              END EVENT SECTION    
// ##########################################################################################
//###########################################################################################


    //The commitment is send via the value field in the remix. If the sent value matches the commitment parameter,
    //the contract announces the availability of new design for verification.
    function announce(
        bytes32 _fileHash,
        uint256 _timestamp,
        uint256 _commitment,
        uint256 _taur,
        uint256 _taup /*uint256 _deltaExp, uint256 _deltaReveal*/
    ) public payable {
        require(user.isPlayer(msg.sender) == true, "Operation denied");
        //Check for positive commitment
        require(_commitment > 0, "The commitment should be more than 0.");

        require( _commitment / _taur>3,"Not enough commitment made for the design");
        //Check if the commitment parameter matches the commiment sent to the contract.
        require(
            msg.value == _commitment,
            "The announcement didn't receive the commitment."
        ); //chiedere a nachiket
        //require(_commitment <= ContractToken.balanceOf(msg.sender), "doesn't have enough tokens");

        //Design index
        uint256 j = numDesignes;

        //Design file hash from IPFS
        //designes[j].filehash = _fileHash;

        //Design creator
        designes[j].vendor = msg.sender;

        //Creation timestamp received from the js script
        designes[j].timestamp = _timestamp;

        //Commitment
        designes[j].balance = _commitment;

        //Set a manager
        //designes[j].manager = _manager;

        //Set the begining of the voting phase
        designes[j].phase = votingState.first;

        //Set result to zero
        designes[j].result1.resultPhase_1 =0 ;

        //Setting the value for reward
        if (_taur == 0) {
            designes[j].taur = 1000000000000000000; //ContractToken.totalSupply();
        } else {
            designes[j].taur = _taur;
        }

        //Setting the value for penalty
        if (_taup == 0) {
            designes[j].taup = 1000000000000000000; ////ContractToken.totalSupply();
        } else {
            designes[j].taup = _taup;
        }

        //Setting the value for expiry
        /* if (_deltaExp == 0) {
            designes[j].deltaExp = 600;
        } else {
            designes[j].deltaExp = _deltaExp;
        }

        //Setting the value for reveal
        if (_deltaReveal == 0) {
            designes[j].deltaReveal = 600;
        } else {
            designes[j].deltaReveal = _deltaReveal;
        }*/
        designes[j].deltaExp = 20000;
        //designes[j].deltaReveal = 600;

        //Set the status to be created

        //Incrementing the design index
        numDesignes = numDesignes + 1;

        //DataLib.DesignToken storage _design = trackDesignToken[j];
        //_design.committment = _commitment;

        //ContractToken.transferFrom(msg.sender, address(SaleContract), _commitment);
        //Emitting notification for new design creation.
        //Verifiers receiving the notification can participate in the process
        //Filehash to ensure file integrity
        //Index to use for search
        //Vendor address for source verification
        emit newDesignAvailable(_fileHash, j, msg.sender);
    }

    function getNumDesignes() public view returns (uint256) {
        return numDesignes;
    }

    //Reader function to get designe details at _index
    function getDesigne(uint256 _index) public view returns (designState memory) {
        return designes[_index];
    }

    //IMPORTANT NOT USEFULL AT THE MOMENT
    /*
    function getPlayerCommitment(address _playerAddress, uint256 _designNo) public view returns ( bytes32 ) {
        return ( userDesignCommitment[_playerAddress][_designNo] );
    }
    */
    // Get the player vote of first phase
    function getPlayerVotePhase1(address _playerAddress, uint256 _designNo) public view returns ( int ) {
        return ( playerVote[_playerAddress][_designNo].votingStage1 );
        }
    // Get the player vote of the second phase
    function getPlayerVotePhase2(address _playerAddress, uint256 _designNo) public view returns ( int ) {
        return ( playerVote[_playerAddress][_designNo].votingStage2 );
        }
    // The function used to make a player vote for adesign
    function vote(uint256 _designNo, int _vote, /*bytes32 _nonce,*/ uint256 _timestamp,uint256 _commitment)
        payable public{
        ///////////////////////////////////////////////////////////////////
        require(designes[_designNo].phase==votingState.first||designes[_designNo].phase==votingState.second,"No voting aviable for design. ");
        require(designes[_designNo].statusPhase.statusPhase_1==0||designes[_designNo].statusPhase.statusPhase_2==0, "Operation failed.");
        require(_timestamp <= designes[_designNo].timestamp + designes[_designNo].deltaExp + designes[_designNo].deltaReveal, "The time has expired.");
        require(user.isPlayer(msg.sender) == true, "Operation denied");
        require(_commitment > 0, "The commitment should be more than 0.");
        require(msg.value == _commitment, "The registration didn't receive the commitment.");
        require(_commitment >= designes[_designNo].taup, "The commitment should be greater than the penalty.");
        require(regPlayers[_designNo].length < designes[_designNo].balance / designes[_designNo].taur, "No more registrations are accepted.");
        require(checkPlayer[_designNo][msg.sender] == false, "Player already registered.");
        require(regPlayers[_designNo].length < designes[_designNo].balance / designes[_designNo].taur, "No more registrations are accepted.");
        
        checkPlayer[_designNo][msg.sender] = true;
        regPlayers[_designNo].push(msg.sender);
        //trackDesignToken[_designNo].totalPlayers.push(msg.sender);
        //trackDesignToken[_designNo].stakes[msg.sender] = _commitment;
        emit newPlayerRegistration(msg.sender, _designNo, true);
        //Store the vote by the player
        //players[msg.sender].votes[_designNo] = _vote;
        if(designes[_designNo].phase==votingState.first){
            playerVote[msg.sender][_designNo].votingStage1 = _vote;
            playerVote[msg.sender][_designNo].reveal_1=revealVote.noReveal;
        }
        if(designes[_designNo].phase==votingState.first){
            playerVote[msg.sender][_designNo].votingStage2 = _vote;
            playerVote[msg.sender][_designNo].reveal_2=revealVote.noReveal;
        }
        //An event emitted after successful reveal of vote
        emit playerRevealed(_designNo, msg.sender);
        
        }

    // The user can choose to reveal is vote (meaning making it public)
    function reveal(uint256 _designNo,uint256 _timestamp)
        public{
        require(_timestamp > designes[_designNo].timestamp + designes[_designNo].deltaExp , "The result cannot be revealed before the expiry.");
        if(designes[_designNo].phase==votingState.first){
            playerVote[msg.sender][_designNo].reveal_1=revealVote.reveal;
        }
        if(designes[_designNo].phase==votingState.second){
            playerVote[msg.sender][_designNo].reveal_2=revealVote.reveal;
        }
        emit playerRevealed(_designNo, msg.sender);
        
        }
    // To check wich is the current voting phase
    function checkPhase(uint256 _designNo)public view returns(votingState){
        return designes[_designNo].phase;
    }
    // Player can check the voting result of the first phase
    function playerCheckResult1(uint256 _designNo,uint256 _timestamp)public view returns(int){ 
        require(_timestamp>designes[_designNo].timestamp+designes[_designNo].deltaExp + designes[_designNo].deltaReveal,"The time period has not expired yet. ");
        require(designes[_designNo].statusPhase.statusPhase_1==1,"The result has not yet been revealed");
        return designes[_designNo].result1.resultPhase_1;
    }
    // Player can check the voting result of the second phase
    function playerCheckResult2(uint256 _designNo,uint256 _timestamp)public view returns(int){ 
        require(_timestamp>designes[_designNo].timestamp+designes[_designNo].deltaExp + designes[_designNo].deltaReveal,"The time period has not expired yet. ");
        require(designes[_designNo].statusPhase.statusPhase_2==1 && designes[_designNo].statusPhase.statusPhase_1==1,"The result has not yet been revealed");
        return designes[_designNo].result1.resultPhase_2;
    }

    /* function getAirPlayerInfo(address _playerAddress)view public returns(.AirPlayer memory){
        return isPlayer.airPlayers(_playerAddress);
    }*/

    function setPlayerReputation(address player,int256 reputation)view public{
        user.setPlayerReputation(player, reputation);
    }   

    function setPlayerWeight(address player, uint256 weight)view public{
        user.setPlayerWeigth(player, weight);
    }
    function getPlayerReputation(address _playerAddress)public view returns(int256 reputation){
        return user.getPlayerReputation(_playerAddress);
    }
    function getPlayerWeight(address _playerAddress)public view returns(uint256 weight){
        return user.getPlayerWeight(_playerAddress);
    }

    function calculateResult(uint256 _designNo,uint256 _timestamp)public{
        
        require(designes[_designNo].phase==votingState.first||designes[_designNo].phase==votingState.second,"Operation failed");
        require(msg.sender==designes[_designNo].vendor,"Only the announcer can calculate the result");
        //Check the status of the voting. If already completed, then this function is not run.
        //require(designes[_designNo].status == 0, "The voting is already finished and results are declared.");
        require(designes[_designNo].statusPhase.statusPhase_1 == 0 || designes[_designNo].statusPhase.statusPhase_2==0, "The voting is already finished and results are declared.");

        //Check for expiry. The result cannot be calculated before the expiry.
        require(_timestamp > designes[_designNo].timestamp + designes[_designNo].deltaExp , "The result cannot be revealed before the expiry.");

        //Since solidity do not support floating point arithematic, we will store the value as quotient and remainder.
        //Here we are calculating the numerator and denominator.
        int256 playerNum = 0;
        int256 playerDen = 0;
        uint256 playerWeight=0;
        int256 playerReput=0;
        for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            
            playerWeight=getPlayerWeight(regPlayers[_designNo][i]);
            playerReput=getPlayerReputation(regPlayers[_designNo][i]);
            //playerNum  += ( players[regPlayers[_designNo][i]].votes[_designNo] * int( players[regPlayers[_designNo][i]].weight ) * players[regPlayers[_designNo][i]].reputation );
            //playerDen  += int ( players[regPlayers[_designNo][i]].weight ) * players[regPlayers[_designNo][i]].reputation;
            if(designes[_designNo].phase==votingState.first)
                playerNum  += ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * ( playerReput )*int(playerWeight));
            
            if(designes[_designNo].phase==votingState.second)
                playerNum  += ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * int( playerWeight) * playerReput );

            playerDen  += int ( playerWeight) * playerReput;
        }

        int256 finalScoreQuo = ( playerNum + playerDen ) / ( 2 * playerDen );
        int256 finalScoreRem = ( playerNum + playerDen ) % ( 2 * playerDen );
        int result = 0;
        if ( finalScoreQuo == 1 || finalScoreRem >= playerDen ) {
                //designes[_designNo].result = 1;
            if(designes[_designNo].phase==votingState.first){
                designes[_designNo].result1.resultPhase_1=1;
                result = designes[_designNo].result1.resultPhase_1;
            }
            else if(designes[_designNo].phase==votingState.second){
                designes[_designNo].result1.resultPhase_2=1;
                result = designes[_designNo].result1.resultPhase_2;
            }
        } else if ( finalScoreRem < playerDen ) {
            //designes[_designNo].result = -1;
            if(designes[_designNo].phase==votingState.first){
                designes[_designNo].result1.resultPhase_1=-1;
                result = designes[_designNo].result1.resultPhase_1; 
            }
            else if(designes[_designNo].phase==votingState.second){
                designes[_designNo].result1.resultPhase_2=-1;
                result = designes[_designNo].result1.resultPhase_2;
            }
        }
        setPlayerRep_Weight(_designNo,result);
        updateDesignBalance(_designNo,_timestamp,result);
    }

    function setPlayerRep_Weight(uint256 _designNo,int256 result)public view{

        for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            //if(designes[_designNo].phase==votingState.first){PROBABLY SHOULD BE CHANGED BY CONSIDERING ALSO SECOND VOTING STAGE
            if ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 > 0 && designes[_designNo].phase==votingState.first ) {
                    //Set new reputation

                    //user.airPlayers(regPlayers[_designNo][i]).reputation += playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result;
                    setPlayerReputation(regPlayers[_designNo][i], playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result);
                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                    setPlayerWeight(regPlayers[_designNo][i], uint ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result ));
                    //user.airPlayers(regPlayers[_designNo][i]).weight += uint ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result );
                } 
            else if( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 > 0 && designes[_designNo].phase==votingState.second){
                                        //Set new reputation
                    
                    setPlayerReputation(regPlayers[_designNo][i], playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result);
                    //playerVote[regPlayers[_designNo][i]].reputation += playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result;
                    setPlayerWeight(regPlayers[_designNo][i], uint ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result ));
                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                   // user.airPlayers(regPlayers[_designNo][i]).weight += uint ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result );
                }
                
                
            else {
                    //Set new reputation
                    setPlayerReputation(regPlayers[_designNo][i], (-1*result));//POSSIBLE SOLUTION
                    //user.airPlayers(regPlayers[_designNo][i]).reputation += -1 * result;//TO CHECK HOW TO CHANGE THEM

                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                    setPlayerWeight(regPlayers[_designNo][i], uint(-1*result));//POSSIBLE SOLUTION
                    //user.airPlayers(regPlayers[_designNo][i]).weight += uint ( -1 * result );
            }
            
        }



    }


    function updateDesignBalance(uint256 _designNo,uint256 _timestamp,int256 result)public{

           for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            if(designes[_designNo].phase==votingState.first){
                if ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result == 1) { // rimuovere * result
                    //players[regPlayers[_designNo][i]].balance += designes[_designNo].taur;
                    //ContractToken.transferFrom(address(SaleContract), regPlayers[_designNo][i], designes[_designNo].taur);
                    designes[_designNo].balance -= designes[_designNo].taur;
                } 
            }

            else if(designes[_designNo].phase==votingState.second){
                if ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result == 1) { // rimuovere * result
                    //players[regPlayers[_designNo][i]].balance += designes[_designNo].taur;
                    //ContractToken.transferFrom(address(SaleContract), regPlayers[_designNo][i], designes[_designNo].taur);
                    designes[_designNo].balance -= designes[_designNo].taur;

                }
            }

            else {
                //players[regPlayers[_designNo][i]].balance -= designes[_designNo].taup;
                //ContractToken.transferFrom(regPlayers[_designNo][i], address(SaleContract), designes[_designNo].taup);
                designes[_designNo].balance += designes[_designNo].taup;

                }
            }

        //Set the status to finished
        //designes[_designNo].status = 1;
        if(designes[_designNo].phase==votingState.first)
            designes[_designNo].statusPhase.statusPhase_1 = 1;
        if(designes[_designNo].phase==votingState.second)
            designes[_designNo].statusPhase.statusPhase_2=1;
        //Setting the new phase start
        if(designes[_designNo].result1.resultPhase_1==1 && designes[_designNo].phase==votingState.first){
            designes[_designNo].phase=votingState.second;
            designes[_designNo].timestamp=_timestamp;

        }


        //Emit the notification for the result
        emit votingResult(result);
        }

    }






//####################################################################################################################################################################
//####################################################################################################################################################################    
    // function used for calculating the result of the votation
    /*function calculateResult(uint256 _designNo, uint256 _timestamp)
        public{
        //Only if we are in phase 1 or 2 the result can be calculated
        require(designes[_designNo].phase==votingState.first||designes[_designNo].phase==votingState.second,"Operation failed");
        require(msg.sender==designes[_designNo].vendor,"Only the announcer can calculate the result");
        //Check the status of the voting. If already completed, then this function is not run.
        //require(designes[_designNo].status == 0, "The voting is already finished and results are declared.");
        require(designes[_designNo].statusPhase.statusPhase_1 == 0 || designes[_designNo].statusPhase.statusPhase_2==0, "The voting is already finished and results are declared.");

        //Check for expiry. The result cannot be calculated before the expiry.
        require(_timestamp > designes[_designNo].timestamp + designes[_designNo].deltaExp , "The result cannot be revealed before the expiry.");

        //Since solidity do not support floating point arithematic, we will store the value as quotient and remainder.
        //Here we are calculating the numerator and denominator.
        int256 playerNum = 0;
        int256 playerDen = 0;
        uint256 playerWeight=0;
        int256 playerReput=0;
        for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            
            playerWeight=getPlayerWeight(regPlayers[_designNo][i]);
            playerReput=getPlayerReputation(regPlayers[_designNo][i]);
            //playerNum  += ( players[regPlayers[_designNo][i]].votes[_designNo] * int( players[regPlayers[_designNo][i]].weight ) * players[regPlayers[_designNo][i]].reputation );
            //playerDen  += int ( players[regPlayers[_designNo][i]].weight ) * players[regPlayers[_designNo][i]].reputation;
            if(designes[_designNo].phase==votingState.first)
                playerNum  += ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * ( playerReput )*int(playerWeight));
            
            if(designes[_designNo].phase==votingState.second)
                playerNum  += ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * int( playerWeight) * playerReput );

            playerDen  += int ( playerWeight) * playerReput;
        }

        //Here we are just calculating the remainder as the value varies from 0 to 1.
        //The borderline case of same positive and negative votes is considered as correct (To be decided later)
        int256 finalScoreQuo = ( playerNum + playerDen ) / ( 2 * playerDen );
        int256 finalScoreRem = ( playerNum + playerDen ) % ( 2 * playerDen );
        int result = 0;
        if ( finalScoreQuo == 1 || finalScoreRem >= playerDen ) {
                //designes[_designNo].result = 1;
            if(designes[_designNo].phase==votingState.first){
                designes[_designNo].result1.resultPhase_1=1;
                result = designes[_designNo].result1.resultPhase_1;
            }
            else if(designes[_designNo].phase==votingState.second){
                designes[_designNo].result1.resultPhase_2=1;
                result = designes[_designNo].result1.resultPhase_2;
            }
        } else if ( finalScoreRem < playerDen ) {
            //designes[_designNo].result = -1;
            if(designes[_designNo].phase==votingState.first){
                designes[_designNo].result1.resultPhase_1=-1;
                result = designes[_designNo].result1.resultPhase_1; 
            }
            else if(designes[_designNo].phase==votingState.second){
                designes[_designNo].result1.resultPhase_2=-1;
                result = designes[_designNo].result1.resultPhase_2;
            }
        }
        //result = designes[_designNo].result; //PROBABILE SOLUZIONE

        for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            if(designes[_designNo].phase==votingState.first){//PROBABLY SHOULD BE CHANGED BY CONSIDERING ALSO SECOND VOTING STAGE
                if ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 > 0 ) {
                    //Set new reputation

                    //user.airPlayers(regPlayers[_designNo][i]).reputation += playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result;
                    setPlayerReputation(regPlayers[_designNo][i], playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result);
                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                    setPlayerWeight(regPlayers[_designNo][i], uint ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result ));
                    //user.airPlayers(regPlayers[_designNo][i]).weight += uint ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result );
                } 
                else if( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 > 0 ){
                                        //Set new reputation
                    
                    setPlayerReputation(regPlayers[_designNo][i], playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result);
                    //playerVote[regPlayers[_designNo][i]].reputation += playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result;
                    setPlayerWeight(regPlayers[_designNo][i], uint ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result ));
                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                   // user.airPlayers(regPlayers[_designNo][i]).weight += uint ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result );
                }
                
                
                else {
                    //Set new reputation
                    setPlayerReputation(regPlayers[_designNo][i], (-1*result));//POSSIBLE SOLUTION
                    //user.airPlayers(regPlayers[_designNo][i]).reputation += -1 * result;//TO CHECK HOW TO CHANGE THEM

                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                    setPlayerWeight(regPlayers[_designNo][i], uint(-1*result));//POSSIBLE SOLUTION
                    //user.airPlayers(regPlayers[_designNo][i]).weight += uint ( -1 * result );
                }
            }
        }

        for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            if(designes[_designNo].phase==votingState.first){
                if ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage1 * result == 1) { // rimuovere * result
                    //players[regPlayers[_designNo][i]].balance += designes[_designNo].taur;
                    //ContractToken.transferFrom(address(SaleContract), regPlayers[_designNo][i], designes[_designNo].taur);
                    designes[_designNo].balance -= designes[_designNo].taur;
                } 
            }

            else if(designes[_designNo].phase==votingState.second){
                if ( playerVote[regPlayers[_designNo][i]][_designNo].votingStage2 * result == 1) { // rimuovere * result
                    //players[regPlayers[_designNo][i]].balance += designes[_designNo].taur;
                    //ContractToken.transferFrom(address(SaleContract), regPlayers[_designNo][i], designes[_designNo].taur);
                    designes[_designNo].balance -= designes[_designNo].taur;

                }
            }

            else {
                //players[regPlayers[_designNo][i]].balance -= designes[_designNo].taup;
                //ContractToken.transferFrom(regPlayers[_designNo][i], address(SaleContract), designes[_designNo].taup);
                designes[_designNo].balance += designes[_designNo].taup;

            }
        }

        //Set the status to finished
        //designes[_designNo].status = 1;
        if(designes[_designNo].phase==votingState.first)
            designes[_designNo].statusPhase.statusPhase_1 = 1;
        if(designes[_designNo].phase==votingState.second)
            designes[_designNo].statusPhase.statusPhase_2=1;
        //Setting the new phase start
        if(designes[_designNo].result1.resultPhase_1==1 && designes[_designNo].phase==votingState.first){
            designes[_designNo].phase=votingState.second;
            designes[_designNo].timestamp=_timestamp;

        }


        //Emit the notification for the result
        emit votingResult(result);
    }*/











































