// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../libraries/LibStakingStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingFacet {
    using LibStakingStorage for LibStakingStorage.StakingStorage;

    event Staked(address indexed user, uint poolId, uint amount, uint stakeId);

    function stakeInAPool(uint _amount, uint _poolId) external {
        LibStakingStorage.StakingStorage storage ss = LibStakingStorage.stakingStorage();

        require(_amount > 0, "Invalid amount");
        require(_poolId <= uint(LibStakingStorage.Pools.Gold), "Invalid pool ID");

        uint _maturityTime = block.timestamp + ss.MATURITY_PERIOD;

        LibStakingStorage.Staker memory newStaker = LibStakingStorage.Staker({
            stakeId: ss.stakeIdTrack,
            poolType: LibStakingStorage.Pools(_poolId),
            amount: _amount,
            maturityTime: _maturityTime
        });

        ss.stakers[msg.sender].push(newStaker);
        ss.stakeIdTrack += 1;

        // Transfer staked tokens to the contract
        require(ss.token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        emit Staked(msg.sender, _poolId, _amount, ss.stakeIdTrack);
    }
}
