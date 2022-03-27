/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Structs/UserStructs.sol";

contract User {
    //Player - Common Details Maker-Caller
    mapping (address => AirPlayer) private airPlayers;  
    address[] private playerAddresses;
    //Details Maker
    mapping (address =>AirMaker) private airMakers;
    address[] public makerAddress;
    //To check if a user is registered; 
    mapping (address => bool) public isPlayer;


    //Events-----------------------------
    event newPlayerAddition(address player_address);
    //-----------------------------------


    //Functions--------------------------
    //Functions Players
    function addCaller(bytes32 username, Position memory position, uint256 timestamp/*, bytes32 _hashMsg, bytes memory _signature*/)
    public payable{
        //Check for existing player
        require( isPlayer [msg.sender] == false, "Player already added to the system." );
        //checkIdentity(_hashMsg, _signature);
        addPlayer(false, position, username, 0, 0, timestamp);

    }

    function addMaker(bytes32 username, Position memory position, uint256 from, uint256 to, uint256 timestamp/*, bytes32 _hashMsg, bytes memory _signature*/)
    public payable{
        //Check for existing player
        require( isPlayer [msg.sender] == false, "Player already added to the system." );
        //checkIdentity(_hashMsg, _signature);
        addPlayer(true, position, username, from, to, timestamp);
    }

    function addPlayer(bool maker, Position memory position, bytes32 username, uint256 from, uint256 to, uint256 timestamp) 
    public payable{
        //Push Player address
        playerAddresses.push(msg.sender);

        //Set player to 1 to denote that player is added to the system
        isPlayer[msg.sender] = true;

        airPlayers[msg.sender].playerType = PlayerType.CALLER;
        
        if (maker==true){
            airPlayers[msg.sender].playerType = PlayerType.MAKER;
            airMakers[msg.sender].avaiableToPrint = false;
            airMakers[msg.sender].avaiabilityRangeFrom = from;
            airMakers[msg.sender].avaiabilityRangeTo = to;
            makerAddress.push(msg.sender);
        }

        airPlayers[msg.sender].username = username;
        airPlayers[msg.sender].position.latitude = position.latitude;
        airPlayers[msg.sender].position.longitude = position.longitude;
        airPlayers[msg.sender].timestampCreation = timestamp;


        //Default value
        airPlayers[msg.sender].reputation = 3;  
        airPlayers[msg.sender].weight = 1;
        
        //Event for successful registration
        emit newPlayerAddition(msg.sender);
    }

    function getPlayerInfo()
    public view 
    returns (AirPlayer memory airPlayer, AirMaker memory airMaker){
        require( isPlayer [msg.sender] == true, "Player not in the system." );

        return (airPlayers[msg.sender], airMakers[msg.sender]);
    }

    function getPlayerInfoWithAddress(address player)
    public view 
    returns (AirPlayer memory airPlayer){
        require( isPlayer [player] == true, "Player not in the system." );
        return airPlayers[player];
    }

    //Scheduling utilities function
    function getNMakersBeforeTimestamp(uint256 timestamp_request)
    private view returns(uint256 n){
        for (uint i = 0; i < makerAddress.length; i++) {
            if(airPlayers[makerAddress[i]].timestampCreation<timestamp_request){
                n++;
            }
        }
        return n;
    }

    function getMakersInfo(uint256 timestamp_request) 
    public view 
    returns (address[] memory addr, AirPlayer[] memory pl, AirMaker[] memory mk){
        uint256 nMakers = getNMakersBeforeTimestamp(timestamp_request);
        pl = new AirPlayer[](nMakers);
        mk = new AirMaker[](nMakers);
        addr = new address[](nMakers);
        for (uint i = 0; i < makerAddress.length; i++) {
            if(airPlayers[makerAddress[i]].timestampCreation<timestamp_request){
                addr[i] = makerAddress[i];
                pl[i] = airPlayers[makerAddress[i]];
                mk[i] = airMakers[makerAddress[i]];
            }
        }
        return (addr,pl,mk);
    }

    //--------

    
    //TEST Function
    function getPlayers() 
    public view 
    returns (AirPlayer[] memory pl){
        pl = new AirPlayer[](playerAddresses.length);
        for (uint i = 0; i < playerAddresses.length; i++) {
            pl[i] = airPlayers[playerAddresses[i]];
        }
        return pl;
    }

    //TEST Function 
    function getNPlayers()
    public view returns(uint256){
        return playerAddresses.length;
    }

    //TEST Function
    function getNMakers()
    public view returns(uint256){
        return makerAddress.length;
    }

    //TEST Function
    function getNCallers()
    public view returns(uint256){
        return getNPlayers() - getNMakers();
    }

    function isMaker(address adr) 
    public view returns(bool){
        return airPlayers[adr].playerType == PlayerType.MAKER;
    } 

    function checkIdentity(bytes32 _hashMsg, bytes memory _signature) 
    private view{
        //Check for identity of the user registering
        (uint8 _v, bytes32 _r, bytes32 _s) = splitSignature(_signature);
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hashMsg));
        require(ecrecover(prefixedHash, _v, _r, _s) == msg.sender, "The registration identity verification failed."); 
    }

    function splitSignature(bytes memory sig)
    private pure
    returns (uint8, bytes32, bytes32){
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
}
