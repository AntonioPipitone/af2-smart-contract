pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */

        //Structs-------------------------
        //! Air Player and Maker
        struct Position{
            int256 longitude;
            int256 latitude;
        }
        
        struct AirPlayer{
            PlayerType playerType;
            bytes32 username;
            Position position;
            uint256 reputation;
            uint256 weight;
            uint256 timestampCreation;
        }
        struct AirMaker{
            uint avaiabilityRangeFrom;
            uint avaiabilityRangeTo;
            bool avaiableToPrint;
        }

        enum PlayerType{ MAKER, CALLER }
