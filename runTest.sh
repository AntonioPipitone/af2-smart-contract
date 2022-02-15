#!/bin/bash
truffle migrate --reset --network development
node test/SchedulingTest.js   
#node test/VotingSystemTest.js