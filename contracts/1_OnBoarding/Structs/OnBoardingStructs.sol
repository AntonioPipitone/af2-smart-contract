pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */
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
        uint256 quantityM;//TODO Rimuovi kg o M
        uint256 printTemperature; 
        uint256 bedTemperature;
    }

    //FIXME Metti NONE come materiale
    enum MaterialType  { ABS, PLA, PETG }
    enum MaterialColor { NONE, BLACK, WHITE, BROWN, GRAY, YELLOW, ORANGE, RED, PINK, PURPLE, BLU, GREEN }
