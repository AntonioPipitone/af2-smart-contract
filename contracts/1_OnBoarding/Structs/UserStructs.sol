pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


/*
 * @author Pipitone Antonio 
 * @SPDX-License-Identifier: UNLICENSED
 */

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

        enum PlayerType{ MAKER, CALLER }
