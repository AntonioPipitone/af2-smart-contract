pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */

contract Scheduling {
    //Structs-------------------------
    //! Air Player and Maker
    struct Position{
        uint256 x;
        uint256 y;
    }
    struct AirPlayer{
        PlayerType playerType;
        bytes32 username;
        bytes32 position;
        uint256 reputation;
        uint256 weight;
    }
    struct AirMaker{
        uint avaiabilityRangeFrom;
        uint avaiabilityRangeTo;
        bool avaiableToPrint;
    }

    //Printer
    struct Printer{
        bytes32 name;

        MaterialType[] supportedMaterial;
        MaterialDetails mountedMaterial;

        uint256[] nozzles;
        uint256 mountedNozzles;

        uint256 maxPrintTemperature;
        uint256 maxBedTemperature;        
        
        uint256 volume;
        bool soluble;
        bool foodSafety;
        bool avaiable;
    }
    
    //Material
    struct MaterialDetails{
        bytes32 name;
        MaterialType mType;
        MaterialColor color;
        uint256 quantityKG;
        uint256 quantityM;
        uint256 printTemperature;
        uint256 bedTemperature;
    }

    struct Design{
        bytes32 hashDesign;
        uint256 printVolume;
        uint256 kgMaterials;
        uint256 mMaterials;
    }

    struct Order{
        bytes32 design;
        MaterialType typeMaterial;
        MaterialColor color;
        uint256 pieces;
        bool higherQuality;
        uint256 layerHeight;
        mapping (address => uint256) partitions;
        address[] makers;
    }

    struct OrderPartition{
        Order order;
        uint256 piecesToPrint;
    }
    //-----------------------------------

    //Enums------------------------------
    //! Material
    enum MaterialType  { ABS, PLA, PETG }
    enum MaterialColor { NONE, BLACK, WHITE, BROWN, GRAY, YELLOW, ORANGE, RED, PINK, PURPLE, BLU, GREEN }
    MaterialDetails private NONE = MaterialDetails("",MaterialType.ABS,MaterialColor.NONE,0,0,0,0);
    //-----------------------------------

    //Mapping and Variables--------------
    //Player - Common Details Maker-Caller
    enum PlayerType{ MAKER, CALLER }
    mapping (address => AirPlayer) private airPlayers;  
    address[] private playerAddresses;
    //Details Maker
    mapping (address =>AirMaker) private airMakers;
    address[] private makerAddress;
    //To check if a user is registered; 
    mapping (address => bool) private isPlayer;

    //Printers
    mapping (address => mapping(address => Printer)) private printers;
    mapping (address => bool) private isPrinter;
    mapping (address => address[]) private makerPrinters;

    //Material
    mapping (address => mapping (MaterialType => MaterialDetails[]) ) private materials;
    mapping (address => bytes32[]) private materialsName;

    
    //Design
    mapping(bytes32 => Design) designs;
    Design[] designsA;
    mapping(bytes32 => bool) isDesign;

    //Orders
    mapping(address => Order[]) orders;
    mapping(address => Order[]) myOrders;
    //-----------------------------------

    //Events-----------------------------
    event newPlayerAddition(address player_address);
    event newPrinterAddition(address player_address, bool status);
    //-----------------------------------

    //Functions--------------------------
    //Functions Players
    function addCaller(bytes32 position, bytes32 username/*, bytes32 _hashMsg, bytes memory _signature*/)
    public payable{
        //Check for existing player
        require( isPlayer [msg.sender] == false, "Player already added to the system." );
        //checkIdentity(_hashMsg, _signature);
        addPlayer(false, position, username, 0, 0);

    }

    function addMaker(bytes32 position, bytes32 username, uint256 from, uint256 to/*, bytes32 _hashMsg, bytes memory _signature*/)
    public payable{
        //Check for existing player
        require( isPlayer [msg.sender] == false, "Player already added to the system." );
        //checkIdentity(_hashMsg, _signature);
        addPlayer(true, position, username, from, to);
    }

    function addPlayer(bool maker, bytes32 position, bytes32 username, uint256 from, uint256 to) 
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
        airPlayers[msg.sender].position = position;

        //Default value
        airPlayers[msg.sender].reputation = 0;  
        airPlayers[msg.sender].weight = 0;
        
        //Event for successful registration
        emit newPlayerAddition(msg.sender);
    }

    function getPlayerInfo()
    public view 
    returns (AirPlayer memory airPlayer, AirMaker memory airMaker){
        require( isPlayer [msg.sender] == true, "Player not in the system." );

        return (airPlayers[msg.sender], airMakers[msg.sender]);
    }

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




    //Functions Printers
    function addPrinter(
        address printerAddress,
        bytes32 name, 
        MaterialType[] memory suppertedMaterial,
        uint256[] memory nozzles,
        uint256 nozzlesMounted, 
        uint256 printTemperature, 
        uint256 bedTemperature, 
        uint256 volume, 
        bool soluble,
        bool foodSafety
    ) public payable{
        require( isPlayer[ msg.sender ] == true, "Player not in the system.");
        require( airPlayers[ msg.sender ].playerType == PlayerType.MAKER, "Only Maker can add Printers.");

        Printer memory newPrinter = Printer(
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
        isPrinter[msg.sender] = true;
        makerPrinters[msg.sender].push(printerAddress);


        emit newPrinterAddition(msg.sender, true);
    }

    function getMakerPrinters() 
    public view 
    returns (Printer[] memory mprinters){
        require( isPlayer[ msg.sender ] == true, "Player not in the system.");
        require( airPlayers[ msg.sender ].playerType == PlayerType.MAKER, "Only Maker can get their Printers.");
        mprinters = new Printer[](makerPrinters[msg.sender].length);
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

    function addMaterials(bytes32 name, MaterialType mType, MaterialColor mColor, uint256 quantityKG, uint256 quantityM, uint256 printTemp, uint256 bedTemp)
    public payable{
        require( airPlayers[ msg.sender ].playerType == PlayerType.MAKER, "Only Maker can add Material.");
        require(mColor != MaterialColor.NONE, "Color not valid");
        require(checkMaterial(name) == false, "There is already a material with this name");
        MaterialDetails memory newMaterial = MaterialDetails(name, mType,mColor, quantityKG, quantityM, printTemp, bedTemp);    
        materials[msg.sender][mType].push(newMaterial);
        materialsName[msg.sender].push(name);
    }

    function getMaterials()
    public view
    returns (MaterialDetails[] memory av_materials){
        
        uint256 n_materials = materials[msg.sender][MaterialType.ABS].length+materials[msg.sender][MaterialType.PETG].length+materials[msg.sender][MaterialType.PLA].length;
        av_materials = new MaterialDetails[](n_materials);
        for (uint i = 0; i < 3; i++){
            for(uint j=0; j < materials[msg.sender][MaterialType(i)].length; j++){
                av_materials[i+j] = materials[msg.sender][MaterialType(i)][j];
            }
        }
        return av_materials;
    }

    function updateMaterial(bytes32 name, MaterialType mType, MaterialColor mColor, uint256 quantityKG, uint256 quantityM, uint256 printTemp, uint256 bedTemp)
    public payable{
        require( airPlayers[ msg.sender ].playerType == PlayerType.MAKER, "Only Maker can update Materials.");
        require(checkMaterial(name) == true, "No material with this name");

        for(uint j=0; j < materials[msg.sender][mType].length; j++){
            if (materials[msg.sender][mType][j].name==name){
                materials[msg.sender][mType][j] = MaterialDetails(name,mType, mColor, quantityKG, quantityM, printTemp, bedTemp); 
            }
        }
    }

    function removeMaterial(bytes32 name, MaterialType mType) 
    public payable{
        require( airPlayers[ msg.sender ].playerType == PlayerType.MAKER, "Only Maker can delete Materials.");
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

    function mountMaterial(bytes32 name, MaterialType mType, address printer)
    public payable{
        require( airPlayers[ msg.sender ].playerType == PlayerType.MAKER, "Only Maker can delete Materials.");
        require(checkMaterial(name) == true, "No material with this name");
        
        for(uint j=0; j < materials[msg.sender][mType].length; j++){
            if (materials[msg.sender][mType][j].name==name){
                printers[msg.sender][printer].mountedMaterial = materials[msg.sender][mType][j];
            }
        }
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
