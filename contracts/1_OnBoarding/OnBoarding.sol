/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Structs/OnBoardingStructs.sol";

abstract contract IUser{
    mapping (address => bool) public isPlayer;
    function isMaker(address adr) virtual public view returns(bool);
    function getNMakers() virtual public view returns(uint256);
    address[] public makerAddress;
}

contract OnBoarding {
    // Material unused 
    MaterialDetails private NONE = MaterialDetails("",MaterialType.NONE,MaterialColor.NONE,0,0,0,0);

    //Printers
    mapping (address => mapping(address => Printer)) private printers;
    mapping (address => bool) private isPrinter;
    mapping (address => address[]) private makerPrinters;

    //Material
    mapping (address => mapping (MaterialType => MaterialDetails[]) ) private materials;
    mapping (address => bytes32[]) private materialsName;

    event newPrinterAddition(address player_address, bool status);

    IUser private Iuser;
    constructor(address _user){
        Iuser = IUser(_user);
    }


    //----------- Printers ---------------

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
        bool foodSafety,
        uint256 timestamp
    ) public payable{
        require( Iuser.isPlayer(msg.sender) == true, "Player not in the system.");
        require( Iuser.isMaker(msg.sender) == true, "Only Maker can add Printers.");

        Printer memory newPrinter = Printer(
                                            name,
                                            printerAddress,
                                            suppertedMaterial,
                                            NONE, 
                                            nozzles, 
                                            nozzlesMounted, 
                                            printTemperature, 
                                            bedTemperature, 
                                            volume, 
                                            soluble, 
                                            foodSafety,
                                            true,
                                            timestamp
                                            );
        printers[msg.sender][printerAddress] = (newPrinter);  
        isPrinter[msg.sender] = true;
        makerPrinters[msg.sender].push(printerAddress);


        emit newPrinterAddition(msg.sender, true);
    }

    function getMakerPrinters() 
    public view 
    returns (Printer[] memory mprinters){
        require( Iuser.isPlayer(msg.sender) == true, "Player not in the system.");
        require( Iuser.isMaker(msg.sender) == true, "Only Maker can get their Printers.");
        mprinters = new Printer[](makerPrinters[msg.sender].length);
        for (uint i = 0; i < makerPrinters[msg.sender].length; i++) {
            mprinters[i] = printers[msg.sender][makerPrinters[msg.sender][i]];
        }
        return mprinters;
    }

    function getMakerNPrinters()
    public view
    returns(uint256 Nprinters){
        return makerPrinters[msg.sender].length;
    }


    //---------------- Utils -------------------
    function getMakerNPrintersBeforeTimestamp(uint256 timestamp)
    public view
    returns(uint256 Nprinters){
        for (uint i = 0; i < Iuser.getNMakers(); i++){
            address m = Iuser.makerAddress(i);
            for (uint j = 0; j < makerPrinters[m].length; j++) {
                if(printers[m][makerPrinters[m][j]].timestampModify<timestamp){
                    Nprinters++;
                }
            }
        }
        return Nprinters;
    }

    function getMakerPrintersBeforeTimestamp(uint256 timestamp)
    public view
    returns(MakerPrinters[] memory mprinters){
        mprinters = new MakerPrinters[](getMakerNPrintersBeforeTimestamp(timestamp));
        uint256 pos = 0;
        for (uint i = 0; i < Iuser.getNMakers(); i++){
            address m = Iuser.makerAddress(i);
            for (uint j = 0; j < makerPrinters[m].length; j++) {
                if(printers[m][makerPrinters[m][j]].timestampModify<timestamp){
                    mprinters[pos] = MakerPrinters(m,printers[m][makerPrinters[m][j]]);
                    pos++;
                }
            }
        }
        return mprinters;
    }
    //--------------- End Utils ----------------


     //----------- End Printers ---------------


    //-----------Materials---------------

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

    function addMaterials(bytes32 name, MaterialType mType, MaterialColor mColor, uint256 quantityKG, uint256 printTemp, uint256 bedTemp, uint256 timestamp)
    public payable
    returns (MaterialType){
        require( Iuser.isMaker(msg.sender) == true, "Only Maker can add Material.");
        require(mColor != MaterialColor.NONE, "Color not valid");
        require(mType != MaterialType.NONE, "Material not valid");

        require(checkMaterial(name) == false, "There is already a material with this name");
        MaterialDetails memory newMaterial = MaterialDetails(name, mType,mColor, quantityKG, printTemp, bedTemp, timestamp);    
        materials[msg.sender][mType].push(newMaterial);
        materialsName[msg.sender].push(name);
        return mType;
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

    function updateMaterial(bytes32 name, MaterialType mType, MaterialColor mColor, uint256 quantityKG, uint256 printTemp, uint256 bedTemp, uint256 timestamp)
    public payable{
        require( Iuser.isMaker(msg.sender) == true, "Only Maker can update Materials.");
        require(checkMaterial(name) == true, "No material with this name");

        for(uint j=0; j < materials[msg.sender][mType].length; j++){
            if (materials[msg.sender][mType][j].name==name){
                materials[msg.sender][mType][j] = MaterialDetails(name,mType, mColor, quantityKG, printTemp, bedTemp, timestamp); 
            }
        }
    }

    function removeMaterial(bytes32 name, MaterialType mType) 
    public payable{
        require( Iuser.isMaker(msg.sender) == true, "Only Maker can delete Materials.");
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

    function mountMaterial(bytes32 name, MaterialType mType, address printer, uint256 timestamp)
    public payable{
        require(Iuser.isMaker(msg.sender) == true, "Only Maker can delete Materials.");
        require(checkMaterial(name) == true, "No material with this name");
        
        for(uint j=0; j < materials[msg.sender][mType].length; j++){
            if (materials[msg.sender][mType][j].name==name){
                printers[msg.sender][printer].mountedMaterial = materials[msg.sender][mType][j];
                printers[msg.sender][printer].timestampModify = timestamp;
            }
        }
    }

    //---------------- Utils -------------------
    function getMaterialsBeforeTimestamp(uint timestamp)
    public view
    returns (MakerMaterials[] memory mats){
        mats = new MakerMaterials[](getNMaterialBeforeTimestamp(timestamp));
        uint pos = 0;
        for (uint i = 0; i < Iuser.getNMakers(); i++){
            for (uint t = 0; t < 3; t++){
                for(uint j=0; j < materials[Iuser.makerAddress(i)][MaterialType(t)].length; j++){
                    if  (materials[Iuser.makerAddress(i)][MaterialType(t)][j].timestampCreation<timestamp){
                        mats[pos]=MakerMaterials(Iuser.makerAddress(i),materials[Iuser.makerAddress(i)][MaterialType(i)][j]);
                        pos++;
                    }
                }
            }
        }
        return mats;
    }

    function getNMaterialBeforeTimestamp(uint timestamp)
    public view
    returns (uint n){
        for (uint i = 0; i < Iuser.getNMakers(); i++){
            for (uint t = 0; t < 3; t++){
                for(uint j=0; j < materials[Iuser.makerAddress(i)][MaterialType(t)].length; j++){
                    if  (materials[Iuser.makerAddress(i)][MaterialType(t)][j].timestampCreation<timestamp){
                        n++;
                    }
                }
            }
        }
        return n;
    }

    //--------------- End Utils ----------------

    //-----------End Materials---------------

}