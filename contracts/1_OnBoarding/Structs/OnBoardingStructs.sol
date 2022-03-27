pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */
    struct Printer{
        bytes32 name;
        address printerAddress;

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

        uint256 timestampModify;
    }
    
    struct MakerPrinters{
        address maker;
        Printer printer;
    }

    //Material
    struct MaterialDetails{
        bytes32 name;
        MaterialType mType;
        MaterialColor color;
        uint256 quantityKG;
        uint256 printTemperature; 
        uint256 bedTemperature;
        
        uint256 timestampCreation;
    }

    struct MakerMaterials{
        address maker;
        MaterialDetails material;
    }


    enum MaterialType  { ABS, PLA, PETG, NONE }
    enum MaterialColor { NONE, BLACK, WHITE, BROWN, GRAY, YELLOW, ORANGE, RED, PINK, PURPLE, BLU, GREEN }
