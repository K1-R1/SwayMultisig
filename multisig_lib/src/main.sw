library mutlisig_abi;

// use std::address::Address;

use std::{
    address::Address,
    vec::Vec,
};

abi Multisig {
    #[storage(read, write)]fn constructor(owners: Vec<Address>, required_confirmations: u64);
    #[storage(read, write)]fn receive_funds();
    #[storage(read, write)]fn submit_tx(recipient: Address, amount: u64);
    // #[storage(read, write)]fn confirm_tx(tx_index: u64);
    // #[storage(read, write)]fn revoke_confirmation(tx_index: u64);
    // #[storage(read, write)]fn execute_tx(tx_index: u64);
    // #[storage(read)]fn get_tx_count();
    // #[storage(read)]fn get_tx_details(tx_index: u64);
}
