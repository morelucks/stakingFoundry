// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library LibStakingStorage {
    bytes32 constant STAKING_STORAGE_POSITION = keccak256("diamond.standard.staking.storage");

    enum Pools { Diamond, Silver, Gold }

    struct Staker {
        uint stakeId;
        Pools poolType;
        uint amount;
        uint maturityTime;
    }

    struct StakingStorage {
        address owner;
        uint stakeIdTrack;
        // IERC20 token;
        mapping(address => Staker[]) stakers;  // user -> list of stakes
        uint MATURITY_PERIOD;
    }

    function stakingStorage() internal pure returns (StakingStorage storage ss) {
        bytes32 position = STAKING_STORAGE_POSITION;
        assembly {
            ss.slot := position
        }
    }
}
