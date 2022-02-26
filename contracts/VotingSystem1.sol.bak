/*# coding=utf-8
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

/**
 * @file marketplace.sol
 * @author Nachiket Tapas <ntapas@unime.it>
 * @date created 01 Jun 2020
 * @date last modified 09 Jul 2020
 * @SPDX-License-Identifier: UNLICENSED
 */
//TODO FARE LA CLAIM PER LE PERSONE CHE HANNO UN BALANCE POSITIVO
//import { AntoTokenSale } from "./AntoTokenSale.sol";
//import { TestToken } from "./TestToken.sol";
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;
//import "./sol";
import "./DesignData.sol";
import "./EnumType.sol";
import "./PlayerData.sol";
import "./PrinterData.sol";
import "./PrinterDetailsData.sol";

contract designVoting1  {
    
    
    //dataStructure public foo= new dataStructure();

    //dataStructure public usr=new dataStructure();
    struct AirMaker{
        uint avaiabilityRangeFrom;
        uint avaiabilityRangeTo;
        bool avaiableToPrint;
    } 
    struct printer{
        bytes32 name;

        EnumType.materialType[] supportedMaterial;
        PrinterData.materialDetails mountedMaterial;

        uint256[] nozzles;
        uint256 mountedNozzles;

        uint256 maxPrintTemperature;
        uint256 maxBedTemperature;        
        
        uint256 volume;
        bool soluble;
        bool foodSafety;
        bool avaiable;
    } 


        //Proof of printing
    //This structure contains the player address who prints the design
    //using the printer addressed by printer address. The proof of file
    //is represented by IPFS file hash.

    mapping ( uint => mapping ( address => mapping ( address => bytes32 ))) public printingProof;

    //Mapping if the proof exists
    mapping ( uint => mapping ( address => mapping ( address => bool ))) public isProof;

    //Mapping of design identified by design index and collection of players indexes registered to vote
    mapping (uint256 => mapping (address => uint)) public checkPlayers;
    mapping (uint256 => address[]) public regPlayers;

    //Design details indexed by design index
    mapping (uint256 => DesignData.designState) public designes;
    uint256 public numDesignes = 0;

    //Player details indexed by player address
    mapping (address => PlayerData.playerState) public players;
    mapping (address =>AirMaker) public airMakers;
    mapping (address => uint) public isPlayer;
    
    address[] public playerAddresses;
    address[] public makerAddress;


    //Printer details indexed by printer address
    mapping (address => mapping(address => printer)) public printers;
    mapping (address => uint) public isPrinter;
    
    address[] public printerAddresses;


    //Printing procesthe printer addresss indexed by
    mapping (address => PrinterDetailsData.printingProcess) public printersWork;

    //Printer player mapping
    mapping (address => address[]) public makerPrinters;

    mapping (address => mapping (EnumType.materialType => PrinterData.materialDetails[]) ) public materials;
    mapping (address => bytes32[]) public materialsName;

    PrinterData.materialDetails  NONE = PrinterData.materialDetails("",EnumType.materialType.ABS,EnumType.materialColor.NONE,0,0,0,0);
    //Mapping to track number of token for design
    //mapping(uint256 => DataLib.DesignToken) trackDesignToken;

    //event newPlayerAddition(address player_address);
    event newPrinterAddition(address player_address, bool status);

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

    //The commitment is send via the value field in the remix. If the sent value matches the commitment parameter,
    //the contract announces the availability of new design for verification.
    function announce(
        bytes32 _fileHash,
        uint256 _timestamp,
        uint256 _commitment,
        uint256 _taur,
        uint256 _taup /*uint256 _deltaExp, uint256 _deltaReveal*/
    ) public payable {
        require(isPlayer[msg.sender] == 1, "Operation denied");
        //Check for positive commitment
        require(_commitment > 0, "The commitment should be more than 0.");

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
        designes[j].phase = EnumType.votingState.first;

        //Set result to zero
        designes[j].result = 0;

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
        designes[j].status = 0;
        designes[j].status1 = 0;
        designes[j].status2 = 0;
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

    //Reader function to get number of designes
    function getNumDesignes() public view returns (uint256) {
        return numDesignes;
    }

    //Reader function to get designe details at _index


    //add a normal player to the system
    function addCaller(
        bytes32 position,
        bytes32 username /*, bytes32 _hashMsg, bytes memory _signature*/
    ) public payable {
        //Check for existing player
        require(
            isPlayer[msg.sender] == 0,
            "Player already added to the system."
        );
        //checkIdentity(_hashMsg, _signature);
        addPlayer(false, position, username, 0, 0);
    }

    //add the player who is able to print designes
    function addMaker(
        bytes32 position,
        bytes32 username,
        uint256 from,
        uint256 to /*, bytes32 _hashMsg, bytes memory _signature*/
    ) public payable {
        //Check for existing player
        require(
            isPlayer[msg.sender] == 0,
            "Player already added to the system."
        );
        //checkIdentity(_hashMsg, _signature);
        addPlayer(true, position, username, from, to);
    }

    //Function to add players to the system. This does not mean the player is registering to vote.
    //function addPlayer(bytes32 _hashMsg, bytes memory _signature) public {
    function addPlayer(
        bool maker,
        bytes32 position,
        bytes32 username,
        uint256 from,
        uint256 to
    ) public {
        //Check for identity of the user registering
        //(uint8 _v, bytes32 _r, bytes32 _s) = splitSignature(_signature);
        //bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hashMsg));
        //require(ecrecover(prefixedHash, _v, _r, _s) == msg.sender, "The registration identity verification failed.");

        //Check for existing player
        require(
            isPlayer[msg.sender] == 0,
            "Player already added to the system."
        );

        if (maker == true) {
            players[msg.sender].playerType = EnumType.playerType.MAKER;
            airMakers[msg.sender].avaiableToPrint = false;
            airMakers[msg.sender].avaiabilityRangeFrom = from;
            airMakers[msg.sender].avaiabilityRangeTo = to;
            makerAddress.push(msg.sender);
        }
        //Push Player address
        playerAddresses.push(msg.sender);

        //Set player to 1 to denote that player is added to the system
        isPlayer[msg.sender] = 1;

        //Initialize player requesting registration
        players[msg.sender].reputation = 1;
        players[msg.sender].weight = 1;
        players[msg.sender].username = username;
        players[msg.sender].position = position;
        //Event for successful registration
        emit newPlayerAddition(msg.sender, true);
    }

    //Reader function to get number of players
    function getNPlayers() public view returns (uint256) {
        return playerAddresses.length;
    }

    //Reader function to get player's addresses
    function getPlayerAddresses() public view returns (address[] memory) {
        return playerAddresses;
    }

    //Reader function to get player details for _playerAddress.
    //This does not include the vote, commitment, and design file received status
    function getPlayerDetails(address _playerAddress)
        public
        view
        returns (
            int256,
            uint256,
            uint256
        )
    {
        return (
            players[_playerAddress].reputation,
            players[_playerAddress].weight,
            players[_playerAddress].balance
        );
    }


    function getNMakers() public view returns (uint256) {
        return makerAddress.length;
    }

    function getNCallers() public view returns (uint256) {
        return getNPlayers() - getNMakers();
    }

    //Get commitment corresponding to design number and player
    function getPlayerCommitment(address _playerAddress, uint256 _designNo)
        public
        view
        returns (bytes32)
    {
        return (players[_playerAddress].commitments[_designNo]);
    }

    //Get vote corresponding to design number and player
    function getPlayerVotePhase1(address _playerAddress, uint256 _designNo)
        public
        view
        returns (int256)
    {
        return (players[_playerAddress].votes1[_designNo].votingStage1);
    }

    function getPlayerVotePhase2(address _playerAddress, uint256 _designNo)
        public
        view
        returns (int256)
    {
        return (players[_playerAddress].votes1[_designNo].votingStage2);
    }

    //Check file received status corresponding to design number and player
    function isFileReceived(address _playerAddress, uint256 _designNo)
        public
        view
        returns (bool)
    {
        return (players[_playerAddress].received[_designNo]);
    }

    //This function can be considered as expression of interest to take part in the voting and not to be confused with player registration to the system.
    function register(
        /*bytes32 _hashMsg, bytes memory _signature,*/
        uint256 _designNo,
        uint256 _commitment
    ) public payable {
        //Check of player is added to the system
        require(isPlayer[msg.sender] == 1, "Player not added to the system.");

        //Check for identity of the user registering
        //(uint8 _v, bytes32 _r, bytes32 _s) = splitSignature(_signature);
        //bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        //bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, _hashMsg));
        // require(ecrecover(prefixedHash, _v, _r, _s) == msg.sender, "The registration identity verification failed.");

        //Check for positive commitment
        require(_commitment > 0, "The commitment should be more than 0.");

        //Check if the commitment parameter matches the commiment sent to the contract.
        require(
            msg.value == _commitment,
            "The registration didn't receive the commitment."
        );

        //Check if the commitment is less than penalty
        require(
            _commitment >= designes[_designNo].taup,
            "The commitment should be greater than the penalty."
        );
        //require(_commitment <= ContractToken.balanceOf(msg.sender), "doesn't have enough tokens");
        //Check if the required number of verifiers are already meet
        //require(regPlayers[_designNo].length < designes[_designNo].balance / designes[_designNo].taur, "No more registrations are accepted.");

        //Check if already registered
        require(
            checkPlayers[_designNo][msg.sender] == 0,
            "Player already registered."
        );
        require(
                regPlayers[_designNo].length <
                designes[_designNo].balance / designes[_designNo].taur,
            "No more registrations are accepted."
        );

        //Deposit the commitment into the wallet of the contract owner (token)
        ///ContractToken.transfer(address(SaleContract), _commitment);

        //Incrementing the player index and registration
        checkPlayers[_designNo][msg.sender] = 1;
        regPlayers[_designNo].push(msg.sender);
        players[msg.sender].balance += msg.value;

       // trackDesignToken[_designNo].totalPlayers.push(msg.sender);
        //trackDesignToken[_designNo].stakes[msg.sender] = _commitment;

        //Event for successful registration for a design
        emit newPlayerRegistration(msg.sender, _designNo, true);
    }

    //Reader function to get number of registered players
    function getNumRegPlayers(uint256 _designNo) public view returns (uint256) {
        return regPlayers[_designNo].length;
    }

    //Reader function to get registered player's addresses
    function getRegPlayerAddresses(uint256 _designNo)
        public
        view
        returns (address[] memory)
    {
        return regPlayers[_designNo];
    }

    /* function setReceived(uint256 _designNo, address _playerAddress)
        public payable
    {
        //Check if the sender is the manager responsible for secure exchange.
        require(msg.sender == designes[_designNo].manager, "Only manager can call this function.");

        //The manager sets the design received to be true
        players[_playerAddress].received[_designNo] = true;
        players[_playerAddress].designes.push(_designNo);

        //An event is emitted after successful
        emit playerDesignReceived(_designNo, _playerAddress);
    }*/

    /*function commit(uint256 _designNo, bytes32 _cryptoCommitment, uint256 _timestamp)
        public
    {
        //Check if the player received the design and ready to vote.
        //require(players[msg.sender].received[_designNo] == true, "The player can commit only when manager confirms design exchange.");

        //Check for expiry
        require(_timestamp <= designes[_designNo].timestamp + designes[_designNo].deltaExp, "The player cannot vote after expiry.");

        //Store the commitment by the player
        players[msg.sender].commitments[_designNo] = _cryptoCommitment;

        //An event emitted after successful commitment of vote
        emit playerCommitted(_designNo, msg.sender);
    }*/
    //In theory even if it is called reveal it should be refered to the voting action
    function vote(
        uint256 _designNo,
        int256 _vote,
        /*bytes32 _nonce,*/
        uint256 _timestamp
    ) public {
        ///////////////////////////////////////////////////////////////////
        require(
                designes[_designNo].phase == EnumType.votingState.first ||
                designes[_designNo].phase == EnumType.votingState.second,
            "No voting aviable for design. "
        );
        require(designes[_designNo].status == 0, "Operation failed.");
        require(
            _timestamp <=
                    designes[_designNo].timestamp +
                    designes[_designNo].deltaExp +
                    designes[_designNo].deltaReveal,
            "The time has expired."
        );
        //Check the commitment

        //Store the vote by the player
        //players[msg.sender].votes[_designNo] = _vote;
        if (designes[_designNo].phase == EnumType.votingState.first) {
            players[msg.sender].votes1[_designNo].votingStage1 = _vote;
            players[msg.sender].votes1[_designNo].reveal_1 = EnumType.revealVote
                .noReveal;
        }
        if (designes[_designNo].phase == EnumType.votingState.first) {
            players[msg.sender].votes1[_designNo].votingStage2 = _vote;
            players[msg.sender].votes1[_designNo].reveal_2 = EnumType.revealVote
                .noReveal;
        }
        //An event emitted after successful reveal of vote
        emit playerRevealed(_designNo, msg.sender);
    }

    function reveal(uint256 _designNo, uint256 _timestamp) public {
        require(
            _timestamp >
                designes[_designNo].timestamp + designes[_designNo].deltaExp,
            "The result cannot be revealed before the expiry."
        );
        if (designes[_designNo].phase == EnumType.votingState.first) {
            players[msg.sender].votes1[_designNo].reveal_1 = EnumType.revealVote.reveal;
        }

        if (designes[_designNo].phase == EnumType.votingState.second) {
            players[msg.sender].votes1[_designNo].reveal_2 = EnumType.revealVote.reveal;
        }
        emit playerRevealed(_designNo, msg.sender);
    }

    /*function startNextPhase(uint256 _designNo,uint256 timestamp)public payable{

        require(msg.sender==designes[_designNo].vendor,"Operation not permitted. ");
        require(timestamp>designes[_designNo].deltaExp+designes[_designNo].timestamp,"Votation phase still going. ");
        designes[_designNo].phase=votingState.second;
        emit phase2Begin(_designNo, msg.sender, timestamp);



    }*/

    function getRevealedVotes() public {}

 

    //Need to add a check to be sure that the player that make call
    //has commited to that design

    /////////////////////////////////////////////////////////////////////////////////////////
    //Need to change result into a struct containing two result
    function playerCheckResult1(uint256 _designNo, uint256 _timestamp)
        public
        view
        returns (int256)
    {
        require(
            _timestamp >
                    designes[_designNo].timestamp +
                    designes[_designNo].deltaExp +
                    designes[_designNo].deltaReveal,
            "The time period has not expired yet. "
        );
        require(
            designes[_designNo].status1 == 1,
            "The result has not yet been revealed"
        );
        return designes[_designNo].result;
    }

    function playerCheckResult2(uint256 _designNo, uint256 _timestamp)
        public
        view
        returns (int256)
    {
        require(
            _timestamp >
                    designes[_designNo].timestamp +
                    designes[_designNo].deltaExp +
                    designes[_designNo].deltaReveal,
            "The time period has not expired yet. "
        );
        require(
                designes[_designNo].status2 == 1 &&
                designes[_designNo].status1 == 1,
            "The result has not yet been revealed"
        );
        return designes[_designNo].result;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////

    //TODO Chiedere come viene utilizzata la variabile result
    function calculateResult(uint256 _designNo, uint256 _timestamp) public {
        //Only if we are in phase 1 or 2 the result can be calculated
        require(
                designes[_designNo].phase == EnumType.votingState.first ||
                designes[_designNo].phase == EnumType.votingState.second,
            "Operation failed"
        );
        require(
            msg.sender == designes[_designNo].vendor,
            "Only the announcer can calculate the result"
        );
        //Check the status of the voting. If already completed, then this function is not run.
        //require(designes[_designNo].status == 0, "The voting is already finished and results are declared.");
        require(
                designes[_designNo].status1 == 0 ||
                designes[_designNo].status2 == 0,
            "The voting is already finished and results are declared."
        );

        //Check for expiry. The result cannot be calculated before the expiry.
        require(
            _timestamp >
                designes[_designNo].timestamp + designes[_designNo].deltaExp,
            "The result cannot be revealed before the expiry."
        );

        //Since solidity do not support floating point arithematic, we will store the value as quotient and remainder.
        //Here we are calculating the numerator and denominator.
        int256 playerNum = 0;
        int256 playerDen = 0;
        for (uint256 i = 0; i < regPlayers[_designNo].length; i++) {
            //playerNum  += ( players[regPlayers[_designNo][i]].votes[_designNo] * int( players[regPlayers[_designNo][i]].weight ) * players[regPlayers[_designNo][i]].reputation );
            //playerDen  += int ( players[regPlayers[_designNo][i]].weight ) * players[regPlayers[_designNo][i]].reputation;
            if (designes[_designNo].phase == EnumType.votingState.first)
                playerNum += (players[regPlayers[_designNo][i]]
                    .votes1[_designNo]
                    .votingStage1 *
                    int256(players[regPlayers[_designNo][i]].weight) *
                    players[regPlayers[_designNo][i]].reputation);

            if (designes[_designNo].phase == EnumType.votingState.second)
                playerNum += (players[regPlayers[_designNo][i]]
                    .votes1[_designNo]
                    .votingStage2 *
                    int256(players[regPlayers[_designNo][i]].weight) *
                    players[regPlayers[_designNo][i]].reputation);

            playerDen +=
                int256(players[regPlayers[_designNo][i]].weight) *
                players[regPlayers[_designNo][i]].reputation;
        }

        //Here we are just calculating the remainder as the value varies from 0 to 1.
        //The borderline case of same positive and negative votes is considered as correct (To be decided later)
        int256 finalScoreQuo = (playerNum + playerDen) / (2 * playerDen);
        int256 finalScoreRem = (playerNum + playerDen) % (2 * playerDen);
        int256 result = 0;
        if (finalScoreQuo == 1 || finalScoreRem >= playerDen) {
            designes[_designNo].result = 1;
        } else if (finalScoreRem < playerDen) {
            designes[_designNo].result = -1;
        }
        result = designes[_designNo].result; //PROBABILE SOLUZIONE

        for (uint256 i = 0; i < regPlayers[_designNo].length; i++) {
            if (designes[_designNo].phase == EnumType.votingState.first) {
                if (
                    players[regPlayers[_designNo][i]]
                        .votes1[_designNo]
                        .votingStage1 > 0
                ) {
                    //Set new reputation
                    players[regPlayers[_designNo][i]].reputation +=
                        players[regPlayers[_designNo][i]]
                            .votes1[_designNo]
                            .votingStage1 *
                        result;

                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                    players[regPlayers[_designNo][i]].weight += uint256(
                        players[regPlayers[_designNo][i]]
                            .votes1[_designNo]
                            .votingStage1 * result
                    );
                } else if (
                    players[regPlayers[_designNo][i]]
                        .votes1[_designNo]
                        .votingStage2 > 0
                ) {
                    //Set new reputation
                    players[regPlayers[_designNo][i]].reputation +=
                        players[regPlayers[_designNo][i]]
                            .votes1[_designNo]
                            .votingStage2 *
                        result;

                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                    players[regPlayers[_designNo][i]].weight += uint256(
                        players[regPlayers[_designNo][i]]
                            .votes1[_designNo]
                            .votingStage2 * result
                    );
                } else {
                    //Set new reputation
                    players[regPlayers[_designNo][i]].reputation += -1 * result;

                    //Set new weight (we only use the player weight. The total weight, which is used as normalization factor is eliminated in the final calculation.)
                    players[regPlayers[_designNo][i]].weight += uint256(
                        -1 * result
                    );
                }
            }
        }

        for (uint256 i = 0; i < regPlayers[_designNo].length; i++) {
            if (designes[_designNo].phase == EnumType.votingState.first) {
                if (
                    players[regPlayers[_designNo][i]]
                        .votes1[_designNo]
                        .votingStage1 *
                        result ==
                    1
                ) {
                    // rimuovere * result
                    players[regPlayers[_designNo][i]].balance += designes[
                        _designNo
                    ].taur;
                    //ContractToken.transferFrom(address(SaleContract), regPlayers[_designNo][i], designes[_designNo].taur);
                    designes[_designNo].balance -= designes[_designNo].taur;
                }
            } else if (designes[_designNo].phase == EnumType.votingState.second) {
                if (
                    players[regPlayers[_designNo][i]]
                        .votes1[_designNo]
                        .votingStage2 *
                        result ==
                    1
                ) {
                    // rimuovere * result
                    players[regPlayers[_designNo][i]].balance += designes[
                        _designNo
                    ].taur;
                    //ContractToken.transferFrom(address(SaleContract), regPlayers[_designNo][i], designes[_designNo].taur);
                    designes[_designNo].balance -= designes[_designNo].taur;
                }
            } else {
                players[regPlayers[_designNo][i]].balance -= designes[_designNo]
                    .taup;
                //ContractToken.transferFrom(regPlayers[_designNo][i], address(SaleContract), designes[_designNo].taup);
                designes[_designNo].balance += designes[_designNo].taup;
            }
        }

        //Set the status to finished
        //designes[_designNo].status = 1;
        if (designes[_designNo].phase == EnumType.votingState.first)
            designes[_designNo].status1 = 1;
        if (designes[_designNo].phase == EnumType.votingState.second)
            designes[_designNo].status2 = 1;
        //Setting the new phase start
        if (
            designes[_designNo].result == 1 &&
            designes[_designNo].phase == EnumType.votingState.first
        ) {
            designes[_designNo].phase = EnumType.votingState.second;
            designes[_designNo].timestamp = _timestamp;
        }

        //Emit the notification for the result
        emit votingResult(result);
    }

    //This is a utility function to extract ECDSA parameters from the signature.
    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
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

    

   
    //Reader function to get balance of players
    function getBalance(address player) public view returns (uint256 amount) {
        amount = players[player].balance;
        return amount;
    }

    event TokensClaimed(address indexed player, uint256 amount);

    function claimTokens() public {
        uint256 claimableTokens = getBalance(msg.sender);
        require(claimableTokens > 0, "No claimable tokens");

        //_claimedTokens[players[i]] += claimableTokens; Should be implemented a function that returns the claimed tokens
        //ContractToken.transferFrom(address(SaleContract),msg.sender, claimableTokens);

        //An event emitted after successful claim of tokens
        emit TokensClaimed(msg.sender, claimableTokens);
    }



    function printingBegin(
        address _printerAddress,
        uint256 startTimestamp,
        bytes32 designHash
    ) public {
        require(
            isPlayer[msg.sender] == 1,
            "Only registered player can add proof of printer."
        );

        //Check for an existing printer
        require(
            isPrinter[_printerAddress] == 1,
            "Only proof from a registered printer can be added."
        );

        printersWork[_printerAddress].startTimestamp = startTimestamp;
        printersWork[_printerAddress].designHash = designHash;
    }

    function end_of_printing(
        address _printerAddress,
        uint256 endTimestamp,
        bytes32 printingdataHash
    ) public {
        require(
            isPlayer[msg.sender] == 1,
            "Only registered player can add proof of printer."
        );

        //Check for an existing printer
        require(
            isPrinter[_printerAddress] == 1,
            "Only proof from a registered printer can be added."
        );

        printersWork[_printerAddress].endTimestamp = endTimestamp;
        printersWork[_printerAddress].printingdataHash = printingdataHash;
    }
   function addPrinter(
        address printerAddress,
        bytes32 name, 
        EnumType.materialType[] memory suppertedMaterial,
        uint256[] memory nozzles,
        uint256 nozzlesMounted, 
        uint256 printTemperature, 
        uint256 bedTemperature, 
        uint256 volume, 
        bool soluble,
        bool foodSafety
    ) public payable{
        require( isPlayer[ msg.sender ] == 1, "Player not in the system.");
        require( players[ msg.sender ].playerType == EnumType.playerType.MAKER, "Only Maker can add Printers.");

        printer memory newPrinter = printer(
                                            name,
                                            suppertedMaterial,
                                            NONE, 
                                            nozzles, 
                                            nozzlesMounted, 
                                            printTemperature, 
                                            bedTemperature, 
                                            volume, 
                                            soluble, 
                                            foodSafety,
                                            true
                                            );
        printers[msg.sender][printerAddress] = (newPrinter);  
        isPrinter[msg.sender] = 1;
        makerPrinters[msg.sender].push(printerAddress);


        emit newPrinterAddition(msg.sender, true);
    }

    function getMakerPrinters() 
    public view 
    returns (printer[] memory mprinters){
        require( isPlayer[ msg.sender ] == 1, "Player not in the system.");
        require( players[ msg.sender ].playerType == EnumType.playerType.MAKER, "Only Maker can get their Printers.");
        mprinters = new printer[](makerPrinters[msg.sender].length);
        for (uint i = 0; i < makerPrinters[msg.sender].length; i++) {
            mprinters[i] = printers[msg.sender][makerPrinters[msg.sender][i]];
        }
        return mprinters;
    }

    function getMakerNPrinters()
    public view
    returns(uint256 Nprinters){
        for (uint i = 0; i < makerPrinters[msg.sender].length; i++) {
            Nprinters++;
        }
        return Nprinters;
    }


    //Functions Materials
    function checkMaterial(bytes32 name) 
    internal view returns(bool){
        bool response = false;
        for(uint i = 0; i < materialsName[msg.sender].length; i++ ){
            if (materialsName[msg.sender][i] == name){
                response = true;
            }
        }
        return response;
    }

    function addMaterials(bytes32 name, EnumType.materialType mType, EnumType.materialColor mColor, uint256 quantityKG, uint256 quantityM, uint256 printTemp, uint256 bedTemp)
    public payable{
        require( players[ msg.sender ].playerType == EnumType.playerType.MAKER, "Only Maker can add Material.");
        require(mColor != EnumType.materialColor.NONE, "Color not valid");
        require(checkMaterial(name) == false, "There is already a material with this name");
        PrinterData.materialDetails memory newMaterial = PrinterData.materialDetails(name, mType,mColor, quantityKG, quantityM, printTemp, bedTemp);    
        materials[msg.sender][mType].push(newMaterial);
        materialsName[msg.sender].push(name);
    }

    function getMaterials()
    public view
    returns (PrinterData.materialDetails[] memory av_materials){
        
        uint256 n_materials = materials[msg.sender][EnumType.materialType.ABS].length+materials[msg.sender][EnumType.materialType.PETG].length+materials[msg.sender][EnumType.materialType.PLA].length;
        av_materials = new PrinterData.materialDetails[](n_materials);
        for (uint i = 0; i < 3; i++){
            for(uint j=0; j < materials[msg.sender][EnumType.materialType(i)].length; j++){
                av_materials[i+j] = materials[msg.sender][EnumType.materialType(i)][j];
            }
        }
        return av_materials;
    }

    function updateMaterial(bytes32 name, EnumType.materialType mType, EnumType.materialColor mColor, uint256 quantityKG, uint256 quantityM, uint256 printTemp, uint256 bedTemp)
    public payable{
        require( players[ msg.sender ].playerType == EnumType.playerType.MAKER, "Only Maker can update Materials.");
        require(checkMaterial(name) == true, "No material with this name");

        for(uint j=0; j < materials[msg.sender][mType].length; j++){
            if (materials[msg.sender][mType][j].name==name){
                materials[msg.sender][mType][j] = PrinterData.materialDetails(name,mType, mColor, quantityKG, quantityM, printTemp, bedTemp); 
            }
        }
    }

    function removeMaterial(bytes32 name, EnumType.materialType mType) 
    public payable{
        require( players[ msg.sender ].playerType == EnumType.playerType.MAKER, "Only Maker can delete Materials.");
        require(checkMaterial(name) == true, "No material with this name");

        for(uint j=0; j < materials[msg.sender][mType].length; j++){
            if (materials[msg.sender][mType][j].name==name){
                materials[msg.sender][mType][j] = NONE;
            }
        }
        for (uint i = 0; i < makerPrinters[msg.sender].length; i++) {
            if(printers[msg.sender][makerPrinters[msg.sender][i]].mountedMaterial.name == name){
                printers[msg.sender][makerPrinters[msg.sender][i]].mountedMaterial = NONE;
            }
        }
    }

    function mountMaterial(bytes32 name, EnumType.materialType mType, address printer)
    public payable{
        require( players[ msg.sender ].playerType == EnumType.playerType.MAKER, "Only Maker can delete Materials.");
        require(checkMaterial(name) == true, "No material with this name");
        
        for(uint j=0; j < materials[msg.sender][mType].length; j++){
            if (materials[msg.sender][mType][j].name==name){
                printers[msg.sender][printer].mountedMaterial = materials[msg.sender][mType][j];
            }
        }
    }

}
