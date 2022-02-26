pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


/**
 * @file marketplace.sol
 * @author Nachiket Tapas <ntapas@unime.it>
 * @date created 01 Jun 2020
 * @date last modified 09 Jul 2020
 * @SPDX-License-Identifier: UNLICENSED
 */

    //              STRUCTS SECTION
    //###################################################
    struct voteVerdict {
        int256 resultPhase_1;
        int256 resultPhase_2;
    }

    struct votingStage {
        //private
        int256 votingStage1;
        int256 votingStage2;
        //private
        votingState phase;
        revealVote reveal_1;
        revealVote reveal_2;
    }

    struct status {
        uint256 statusPhase_1;
        uint256 statusPhase_2;
    }

    struct designState {
        bytes32 filehash;
        address vendor;
        uint256 timestamp;
        uint256 balance;
        address manager;
        status statusPhase;
        uint256 taup;
        uint256 taur;
        uint256 deltaExp;
        uint256 deltaReveal;
        voteVerdict result1;
        votingState phase;
    }
    //              END STRUCTS SECTION
    //###################################################


    //              ENUM SECTION
    //###################################################
    enum votingState {
        none,
        first,
        second
    }
    enum revealVote {
        noReveal,
        reveal
    }
    //              END ENUM SECTION
    //###################################################

