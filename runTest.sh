#!/bin/bash
truffle migrate --reset --network development
node test/test.js 
