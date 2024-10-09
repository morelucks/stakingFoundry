// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../libraries/LibStakingStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WithdrawalFacet {
    using LibStakingStorage for LibStakingStorage.StakingStorage;

    event Withdrawn(address indexed user, uint poolId, uint amount);

    function withdraw(uint _poolId, uint _amount) external {
        LibStakingStorage.StakingStorage storage ss = LibStakingStorage.stakingStorage();
        LibStakingStorage.Staker[] storage userStakes = ss.stakers[msg.sender];
        bool found = false;

        for (uint i = 0; i < userStakes.length; i++) {
            if (uint(userStakes[i].poolType) == _poolId) {
                found = true;

                require(userStakes[i].maturityTime <= block.timestamp, "Maturity period not reached");
                require(userStakes[i].amount >= _amount, "Insufficient stake amount");

                userStakes[i].amount -= _amount;

                // Transfer tokens back to the user
                require(ss.token.transfer(msg.sender, _amount), "Token transfer failed");

                emit Withdrawn(msg.sender, _poolId, _amount);

                if (userStakes[i].amount == 0) {
                    delete userStakes[i];  // Delete stake entry if fully withdrawn
                }

                break;
            }
        }

        require(found, "Stake not found for this pool");
    }
}
