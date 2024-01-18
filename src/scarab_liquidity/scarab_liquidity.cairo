use ekubo::interfaces::core::{ICoreDispatcherTrait};
use ekubo::types::keys::{PoolKey, PositionKey};
use starknet::{StorePacking};

#[derive(Copy, Drop, starknet::Store)]
struct PoolState {
    // TODO: Add a way to store the pool's position.
}

#[starknet::contract]
mod ScarabLiquidity {
    use super::{PoolKey, PositionKey, PoolState};
    use ekubo::types::call_points::{CallPoints};
    use ekubo::types::bounds::{Bounds};
    use ekubo::types::i129::{i129};
    use ekubo::interfaces::core::{
        ICoreDispatcher, ICoreDispatcherTrait, IExtension, SwapParameters, UpdatePositionParameters,
        Delta
    };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};

    #[storage]
    struct Storage {
        core: ICoreDispatcher,
        pool_state: LegacyMap<PoolKey, PoolState>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, core: ICoreDispatcher) {
        self.core.write(core);
    }

    #[generate_trait]
    impl Internal of InternalTrait {
        fn check_caller_is_core(self: @ContractState) -> ICoreDispatcher {
            let core = self.core.read();
            assert(core.contract_address == get_caller_address(), 'CALLER_NOT_CORE');
            core
        }

        fn update_pool(ref self: ContractState, core: ICoreDispatcher, pool_key: PoolKey) {
            let state = self.pool_state.read(pool_key);

            let time = get_block_timestamp();
            // TODO: Contract Logic
        }
    }

    #[external(v0)]
    impl ScarabLiquidityExtension of IExtension<ContractState>{
        // TODO: Contract Logic
        fn before_initialize_pool(
            ref self: ContractState, caller: ContractAddress, pool_key: PoolKey, initial_tick: i129
        ) -> CallPoints {
            self.check_caller_is_core();

            self
                .pool_state
                .write(
                    pool_key,
                    PoolState {
                    }
                );

            CallPoints {
                after_initialize_pool: false,
                before_swap: true,
                after_swap: false,
                before_update_position: true,
                after_update_position: false,
            }
        }

        fn after_initialize_pool(
            ref self: ContractState, caller: ContractAddress, pool_key: PoolKey, initial_tick: i129
        ) {
            assert(false, 'NOT_USED');
        }

        fn before_swap(
            ref self: ContractState,
            caller: ContractAddress,
            pool_key: PoolKey,
            params: SwapParameters
        ) {
            let core = self.check_caller_is_core();
            self.update_pool(core, pool_key);
        }

        fn after_swap(
            ref self: ContractState,
            caller: ContractAddress,
            pool_key: PoolKey,
            params: SwapParameters,
            delta: Delta
        ) {
            assert(false, 'NOT_USED');
        }

        fn before_update_position(
            ref self: ContractState,
            caller: ContractAddress,
            pool_key: PoolKey,
            params: UpdatePositionParameters
        ) {
            let core = self.check_caller_is_core();
            self.update_pool(core, pool_key);
        }

        fn after_update_position(
            ref self: ContractState,
            caller: ContractAddress,
            pool_key: PoolKey,
            params: UpdatePositionParameters,
            delta: Delta
        ) {
            assert(false, 'NOT_USED');
        }
    }
}