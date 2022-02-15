pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

/*
# coding=utf-8
############################################################################################
##
# Copyright (C) 2021-2022 Nachiket Tapas,Michele Arena
##
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
##
# http://www.apache.org/licenses/LICENSE-2.0
##
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##
############################################################################################ 
*/

/*
 * @file marketplace.sol
 * @author Nachiket Tapas <ntapas@unime.it>
 * @date created 01 Jun 2020
 * @date last modified 09 Jul 2020
 * @SPDX-License-Identifier: UNLICENSED
 */


contract VotingSystem {
    // The status tells the state of the voting on the design
    // 0: voting
    // 1: finished
    uint256 ab=0;
    struct designState
    {
        bytes32 filehash;
        address vendor;
        uint256 timestamp;
        uint256 balance;
        address manager;
        uint256 status;
        uint256 taup;
        uint256 taur;
        uint256 deltaExp;
        uint256 deltaReveal;
        int result;   
        //////////
        uint256 beginOfphase;
        uint256 phaseState;
        //0 for phase1 1 for phase2 
    }

    //The vote is considered as follows
    // 0 : no vote. maybe due to time expired
    // -1 : invalid design
    // 1 : valid design
    struct playerState
    {
        int256 reputation;
        uint256 weight;
        mapping ( uint256 => bytes32 ) commitments;
        mapping ( uint256 => int ) votes;
        mapping ( uint256 => bool ) received;
        uint256[] designes;
        uint256 balance;
    }

    //information about the print begin,the print end and design name
    struct printingProcess
    {
        
        uint256 startTimestamp;
        uint256 endTimestamp;
        bytes32 printingdataHash;
        bytes32 designHash;

        //uint256 design_number;

    }
   
    //Printer details
    struct printerDetails
    {
        bytes32 make;
        bytes32 name;
        uint strength;    // values: Very High = 3, High = 2, Medium =1 , Low = 0
        uint flexibility; // values: Very High = 3, High = 2, Medium =1 , Low = 0
        uint durability;  // values: Very High = 3, High = 2, Medium =1 , Low = 0
        uint difficulty;  // values: Very High = 3, High = 2, Medium =1 , Low = 0
        int printTemperature;
        int bedTemperature;
        bool soluble;
        bool foodSafety;
    }
    
    //Proof of printing
    //This structure contains the player address who prints the design
    //using the printer addressed by printer address. The proof of file
    //is represented by IPFS file hash.
    mapping ( uint => mapping ( address => mapping ( address => bytes32 ))) private printingProof;
    
    //Mapping if the proof exists
    mapping ( uint => mapping ( address => mapping ( address => bool ))) private isProof;
    
    //Mapping of design identified by design index and collection of players indexes registered to vote 
    mapping (uint256 => mapping (address => uint)) private checkPlayers;
    mapping (uint256 => address[]) private regPlayers;
    
    //Design details indexed by design index
    mapping (uint256 => designState) private designes;
    uint256 private numDesignes = 0;
    
    //Player details indexed by player address
    mapping (address => playerState) private players;
    mapping (address => uint) private isPlayer;
    address[] private playerAddresses;
    //check if a design was printed
    //mapping (playerState.designes=>uint256) printed;
   
    //Printer details indexed by printer address
    mapping (address => printerDetails) private printers;
    mapping (address => uint) private isPrinter;
    address[] private printerAddresses;
    

    //Printing procesthe printer addresss indexed by 
    mapping (address=>printingProcess)private printersWork;

    //Printer player mapping
    mapping (address => address[]) private userPrinters;


    
    //Notifications for successful completion of events
    event newDesignAvailable(bytes32 file_hash, uint256 design_number, address creator);
    event resultCalculated(bytes32 file_hash, uint256 design_number, address creator);
    event newPlayerAddition(address player_address, bool status);
    event newPlayerRegistration(address player_address, uint256 design_number, bool status);
    event playerDesignReceived(uint256 design_number, address player_address);
    event playerCommitted(uint256 design_number, address player_address);
    event playerRevealed(uint256 design_number, address player_address);
    event votingResult(int result);
    
    event newPrinterAddition(address printer, bytes32 name);
    event proofAdded( uint256 design_number, address player_address, address printer_address);
    
    event tempOutput(address _output);//, uint256 timestamp, uint256 expiry, uint256 balance);
///////////////////////////////////////////////////////////
    event phase2Begin(uint256 design_number,address vendor,uint256 time);
    event playerVotedPhase1(uint256 design,address player);
    event playerVotedPhase2(uint256 design,address player);
///////////////////////////////////////////////////////////




    //The commitment is send via the value field in the remix. If the sent value matches the commitment parameter,
    //the contract announces the availability of new design for verification.
    function announce(bytes32 _fileHash, uint256 _timestamp, uint256 _commitment, address _manager, uint256 _taur, uint256 _taup, uint256 _deltaExp, uint256 _deltaReveal)
        public payable
    {
        //Check for positive commitment
        require(_commitment > 0, "The commitment should be more than 0.");
       
        //Check if the commitment parameter matches the commiment sent to the contract.
        require(msg.value == _commitment, "The announcement didn't receive the commitment.");
       
        //Design index
        uint256 j = numDesignes;
        
        //Design file hash from IPFS
        designes[j].filehash = _fileHash;
        
        //Design creator
        designes[j].vendor = msg.sender;
       
        //Creation timestamp received from the js script
        designes[j].timestamp = _timestamp;
        //////////////////////////////////
        designes[j].beginOfphase=_timestamp;
        designes[j].phaseState=0;
        ////////////////////////////////
        //Commitment
        designes[j].balance = _commitment;
       
        //Set a manager
        designes[j].manager = _manager;
        
        //Set result to zero
        designes[j].result = 0;
        
        //Setting the value for reward
        if (_taur == 0) {
            designes[j].taur = 1000000000000000000;
        } else {
            designes[j].taur = _taur;    
        }
        
        //Setting the value for penalty
        if (_taup == 0) {
            designes[j].taup = 1000000000000000000;
        } else {
            designes[j].taup = _taup;    
        }
        
        //Setting the value for expiry
        if (_deltaExp == 0) {
            designes[j].deltaExp = 600;
        } else {
            designes[j].deltaExp = _deltaExp;    
        }
        
        //Setting the value for reveal
        if (_deltaReveal == 0) {
            designes[j].deltaReveal = 600;
        } else {
            designes[j].deltaReveal = _deltaReveal;    
        }
        
        //Set the status to be created
        designes[j].status = 0;
        
        //Incrementing the design index
        numDesignes = numDesignes + 1;
       
        //Emitting notification for new design creation.
        //Verifiers receiving the notification can participate in the process
        //Filehash to ensure file integrity
        //Index to use for search
        //Vendor address for source verification
        emit newDesignAvailable(_fileHash, j, msg.sender);
    }
    
    //Reader function to get number of designes
    function getNumDesignes() public view returns (uint256) {
        return numDesignes;
    }
    
    //Reader function to get designe details at _index
    function getDesigne(uint256 _index) public view returns (designState memory) {
        return designes[_index];
    }
   
    //Function to add players to the system. This does not mean the player is registering to vote.
    //function addPlayer(bytes32 _hashMsg, bytes memory _signature) public {
    //argument for add player : bytes32 _hashMsg, bytes memory _signature
    function addPlayer(bytes32 _hashMsg, bytes memory _signature) public {
        //Check for identity of the user registering
       // (uint8 _v, bytes32 _r, bytes32 _s) = splitSignature(_signature);
       // bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hashMsg));
        //require(ecrecover(prefixedHash, _v, _r, _s) == msg.sender, "The registration identity verification failed.");
        
        //Check for existing player
        require( isPlayer [ msg.sender ] == 0, "Player already added to the system.");
        
        //Push Player address
        playerAddresses.push ( msg.sender );
        
        //Set player to 1 to denote that player is added to the system
        isPlayer [ msg.sender ] = 1;
        
        //Initialize player requesting registration
        players[msg.sender].reputation = 1;
        players[msg.sender].weight = 1;
        
        //Event for successful registration
        emit newPlayerAddition(msg.sender, true);
        
    }
    
    //Reader function to get number of players
    function getNumPlayers() public view returns (uint256) {
        return playerAddresses.length;
    }

   
    
    //Reader function to get player's addresses
    function getPlayerAddresses() public view returns (address[] memory) {
        return playerAddresses;
    }
    
    //Reader function to get player details for _playerAddress. 
    //This does not include the vote, commitment, and design file received status
    function getPlayerDetails(address _playerAddress) public view returns ( int256, uint256, uint256 ) {
        return ( players[_playerAddress].reputation, players[_playerAddress].weight, players[_playerAddress].balance );
    }
    
    //Get commitment corresponding to design number and player
    function getPlayerCommitment(address _playerAddress, uint256 _designNo) public view returns ( bytes32 ) {
        return ( players[_playerAddress].commitments[_designNo] );
    }
    
    //Get vote corresponding to design number and player
    function getPlayerVote(address _playerAddress, uint256 _designNo) public view returns ( int ) {
        return ( players[_playerAddress].votes[_designNo] );
    }
    
    //Check file received status corresponding to design number and player
    function isFileReceived(address _playerAddress, uint256 _designNo) public view returns ( bool ) {
        return ( players[_playerAddress].received[_designNo] );
    }
    
    //This function can be considered as expression of interest to take part in the voting and not to be confused with
    //player registration to the system.
    function register(bytes32 _hashMsg, bytes memory _signature, uint256 _designNo, uint256 _commitment)
        public payable
    {
        //Check of player is added to the system
        require(isPlayer [ msg.sender ] == 1, "Player not added to the system.");
        
        //Check for identity of the user registering
        (uint8 _v, bytes32 _r, bytes32 _s) = splitSignature(_signature);
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, _hashMsg));
        require(ecrecover(prefixedHash, _v, _r, _s) == msg.sender, "The registration identity verification failed.");
        
        //Check for positive commitment
        require(_commitment > 0, "The commitment should be more than 0.");
       
        //Check if the commitment parameter matches the commiment sent to the contract.
        require(msg.value == _commitment, "The registration didn't receive the commitment.");
       
        //Check if the commitment is less than penalty
        require(_commitment >= designes[_designNo].taup, "The commitment should be greater than the penalty.");
       
        //Check if the required number of verifiers are already meet
        require(regPlayers[_designNo].length < designes[_designNo].balance / designes[_designNo].taur, "No more registrations are accepted.");

        //Check if already registered
        require(checkPlayers[_designNo][msg.sender] == 0, "Player already registered.");
        
        //Incrementing the player index and registration
        checkPlayers[_designNo][msg.sender] = 1;
        regPlayers[_designNo].push(msg.sender);
        players[msg.sender].balance += msg.value;
        
        //Event for successful registration for a design
        emit newPlayerRegistration(msg.sender, _designNo, true);
    }
   
    //Reader function to get number of registered players
    function getNumRegPlayers(uint256 _designNo) public view returns (uint256) {
        return regPlayers[_designNo].length;
    }
    
    //Reader function to get registered player's addresses
    function getRegPlayerAddresses(uint256 _designNo) public view returns (address[] memory) {
        return regPlayers[_designNo];
    }
    
    function setReceived(uint256 _designNo, address _playerAddress)
        public payable
    {
        //Check if the sender is the manager responsible for secure exchange.
        require(msg.sender == designes[_designNo].manager, "Only manager can call this function.");
        
        //The manager sets the design received to be true
        players[_playerAddress].received[_designNo] = true;
        players[_playerAddress].designes.push(_designNo);
        
        //An event is emitted after successful
        emit playerDesignReceived(_designNo, _playerAddress);
    }


   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //phase1 voting stage 
    function votingPhase1(uint256 _designNo,uint256 timestamp,int256 vote)public{
            //check for time-expiry and registration then make a vote
            require(players[msg.sender].received[_designNo] == true, "The player can commit only when manager confirms design exchange.");
            require(checkPlayers[_designNo][msg.sender]==0,"The is have not registered to the design");
            require(timestamp <= designes[_designNo].timestamp + designes[_designNo].deltaExp, "The player cannot vote after expiry.");
            players[msg.sender].votes[_designNo]=vote;
            emit playerVotedPhase1(_designNo,msg.sender);

    }

    function startPhase2(uint _designNo,uint256 timestamp)public{
            
            require(designes[_designNo].vendor == msg.sender, "Unable to execute operation.");
            require(designes[_designNo].result==1,"The design has been considered not valid");
            require(timestamp <= designes[_designNo].beginOfphase + designes[_designNo].deltaExp, "The first voting phase is still not finished.");
            
            designes[_designNo].phaseState=1;
            designes[_designNo].beginOfphase=timestamp;
            emit phase2Begin(_designNo,msg.sender,timestamp);


    }

    function votingPhase2(uint256 _designNo,uint256 timestamp,int256 vote)public{

        require(designes[_designNo].phaseState==1,"The first phase is still on going. ");
        require(timestamp <= designes[_designNo].beginOfphase + designes[_designNo].deltaExp, "The first voting phase is still not finished.");
        //Need to implement a check that the design was actually printed
        players[msg.sender].votes[_designNo]=vote;
        emit playerVotedPhase2(_designNo,msg.sender);

    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    

    function commit(uint256 _designNo, bytes32 _cryptoCommitment, uint256 _timestamp)
        public
    {
        //Check if the player received the design and ready to vote.
        require(players[msg.sender].received[_designNo] == true, "The player can commit only when manager confirms design exchange.");
        
        //Check for expiry
        require(_timestamp <= designes[_designNo].timestamp + designes[_designNo].deltaExp, "The player cannot vote after expiry.");
        
        //Store the commitment by the player
        players[msg.sender].commitments[_designNo] = _cryptoCommitment;
        
        //An event emitted after successful commitment of vote
        emit playerCommitted(_designNo, msg.sender);
    }
   
    function reveal(uint256 _designNo, int _vote, bytes32 _nonce, uint256 _timestamp)
        public
    {
        //Check for expiry. Beyond the expiry, the player revealing will have 
        //a picture of the voting trend and thus, can change for profit.
        require(_timestamp <= designes[_designNo].timestamp + designes[_designNo].deltaExp + designes[_designNo].deltaReveal, "The vote cannot be revealed after the expiry.");
        
        //Check the commitment
        require(players[msg.sender].commitments[_designNo] == keccak256(abi.encodePacked(_vote, _nonce)), "The player did not commit to this.");
        
        //Store the vote by the player
        players[msg.sender].votes[_designNo] = _vote;
        
        //An event emitted after successful reveal of vote
        emit playerRevealed(_designNo, msg.sender);
    }

    function calculateResult(uint256 _designNo, uint256 _timestamp)
        public
    {
        //Check the status of the voting. If already completed, then this function is not run.
        require(designes[_designNo].status == 0, "The voting is already finished and results are declared.");
        
        //Check for expiry. The result cannot be calculated before the expiry.
        require(_timestamp > designes[_designNo].timestamp + designes[_designNo].deltaExp + designes[_designNo].deltaReveal, "The result cannot be revealed before the expiry.");
        
        //Since solidity do not support floating point arithematic, we will store the value as quotient and remainder.
        //Here we are calculating the numerator and denominator.
        int256 playerNum = 0;
        int256 playerDen = 0;
        for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            playerNum  += ( players[regPlayers[_designNo][i]].votes[_designNo] * int( players[regPlayers[_designNo][i]].weight ) * players[regPlayers[_designNo][i]].reputation );    
            playerDen  += int ( players[regPlayers[_designNo][i]].weight ) * players[regPlayers[_designNo][i]].reputation;
        }
        
        //Here we are just calculating the remainder as the value varies from 0 to 1.
        //The borderline case of same positive and negative votes is considered as correct (To be decided later)
        int256 finalScoreQuo = ( playerNum + playerDen ) / ( 2 * playerDen );
        int256 finalScoreRem = ( playerNum + playerDen ) % ( 2 * playerDen );
        int result = 0;
        if ( finalScoreQuo == 1 || finalScoreRem >= playerDen ) {
            designes[_designNo].result = 1;
        } else if ( finalScoreRem < playerDen ) {
            designes[_designNo].result = -1;
        }
        
        for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            if ( players[regPlayers[_designNo][i]].votes[_designNo] > 0 ) {
                //Set new reputation
                players[regPlayers[_designNo][i]].reputation += players[regPlayers[_designNo][i]].votes[_designNo] * result;    
        
                //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                players[regPlayers[_designNo][i]].weight += uint ( players[regPlayers[_designNo][i]].votes[_designNo] * result );
            } else {
                //Set new reputation
                players[regPlayers[_designNo][i]].reputation += -1 * result;    
        
                //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                players[regPlayers[_designNo][i]].weight += uint ( -1 * result );
            }
        }
        
        //Retuen the player commitments
        for ( uint256 i = 0; i < regPlayers[_designNo].length; i++ ) {
            if ( players[regPlayers[_designNo][i]].votes[_designNo] * result == 1) {
                players[regPlayers[_designNo][i]].balance += designes[_designNo].taur;
                designes[_designNo].balance -= designes[_designNo].taur;
            } else {
                players[regPlayers[_designNo][i]].balance -= designes[_designNo].taup;
                designes[_designNo].balance += designes[_designNo].taup;
            }
        }
        
        //Set the status to finished
        designes[_designNo].status = 1;
        
        //Emit the notification for the result
        emit votingResult(result);
    }
   
    //This is a utility function to extract ECDSA parameters from the signature.
    function splitSignature(bytes memory sig)
    private
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        
        if (v < 27) {
            v += 27;
        }

        return (v, r, s);
    }

    function addPrinter(address _printerAddr, bytes32 _make, bytes32 _name, uint _strength, uint _flexibility, uint _durability, uint _difficulty, int _printTemperature,
    int _bedTemperature, bool _soluble, bool _foodSafety) 
    public 
    {
        //Check for existing player

        require( isPlayer [ msg.sender ] == 1, "Only registered player can add a printer.");
        
        //Setting up required properties
        printers [ _printerAddr ].make = _make;
        printers [ _printerAddr ].name = _name;
        printers [ _printerAddr ].strength = _strength;    
        printers [ _printerAddr ].flexibility = _flexibility; 
        printers [ _printerAddr ].durability = _durability;  
        printers [ _printerAddr ].difficulty = _difficulty;  
        printers [ _printerAddr ].printTemperature = _printTemperature;
        printers [ _printerAddr ].bedTemperature = _bedTemperature;
        printers [ _printerAddr ].soluble = _soluble;
        printers [ _printerAddr ].foodSafety = _foodSafety;
        
        //Add printer address to the array
        printerAddresses.push( _printerAddr );
        isPrinter [ _printerAddr ] = 1;
        
        //Mapping the player and the printer/s
        userPrinters [ msg.sender ].push( _printerAddr );
        
        //Emit the successfull addition
        emit newPrinterAddition(_printerAddr, _name);
    }   
    
    //Reader function to get number of printers registered by a user
    function getUserPrinters(address _userAddress) public view returns (address[] memory) {
        return userPrinters[ _userAddress ];
    }
    
    //Reader function to get printer details of printer identified by address
    function getPrinterDetails(address _printerAddr) public view returns (printerDetails memory) {
        return printers[ _printerAddr ];
    }
    
    //Reader function for number of printers registered
    function getNumPrinters() public view returns (uint256) {
        return printerAddresses.length;
    }
    
    
    
    
    /*
    function addProof( uint256 _designNo, address _printerAddress, bytes32 _fileHash ) public {
        
        //Check for existing player
        require( isPlayer [ msg.sender ] == 1, "Only registered player can add proof of printer.");
        
        //Check for existing printer
        require( isPrinter [ _printerAddress ] == 1, "Only proof from a registered printer can be added.");
        
        //Add the proof
        printingProof [ _designNo ][ msg.sender ][ _printerAddress ] = _fileHash;
        isProof [ _designNo ][ msg.sender ][ _printerAddress ] = true;
        
        //Emit event
        emit proofAdded( _designNo, msg.sender, _printerAddress);
    }
    */
    function get_printingProcess(address _printerAddress)public view returns(printingProcess memory){
        return printersWork[_printerAddress] ;
    }

    function printingBegin(address _printerAddress,uint256 startTimestamp,bytes32 designHash) public {
        
        require( isPlayer [ msg.sender ] == 1, "Only registered player can add proof of printer.");

        //Check for an existing printer
        require( isPrinter [ _printerAddress ] == 1, "Only proof from a registered printer can be added.");

        printersWork[_printerAddress].startTimestamp=startTimestamp;
        printersWork[_printerAddress].designHash=designHash;
    } 


    function end_of_printing(address _printerAddress,uint256 endTimestamp,bytes32 printingdataHash) public {
        
        require( isPlayer [ msg.sender ] == 1, "Only registered player can add proof of printer.");

        //Check for an existing printer
        require( isPrinter [ _printerAddress ] == 1, "Only proof from a registered printer can be added.");

        printersWork[_printerAddress].endTimestamp=endTimestamp;
        printersWork[_printerAddress].printingdataHash=printingdataHash;
        //printersWork[printerAddresses].design_number=_designNo

    }


    //Function to check if the researcher added the proof from the printer
    function isProofPresent( uint256 _designNo, address _userAddress, address _printerAddress ) public view returns (bool) {
        return isProof [ _designNo ][ _userAddress ][ _printerAddress ];
    }
    
    
}
