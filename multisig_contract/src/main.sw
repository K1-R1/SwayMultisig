contract;

use std::{
    address::Address,
    assert::assert,
    chain::auth::{AuthError, msg_sender},
    constants::BASE_ASSET_ID,
    context::{call_frames::msg_asset_id, msg_amount},
    contract_id::ContractId,
    identity::Identity,
    result::Result,
    revert::revert,
    storage::{StorageMap, StorageVec}
    token::transfer_to_output,
    vec::Vec,
};

use mutlisig_abi::Multisig;

struct Transaction {
    recipient: Address,
    amount: u64,
    bool: executed,
    confitmations: u64,
}

storage {
    //Acts as array of owners, index => address;
    owners_map: StorageMap<u64,Address> = StorageMap {},
    //Allows checking is address is owner
    is_owner: StorageMap<Address,bool> = StorageMap {},
    //Number of confirmations in order for a transaction to be executed
    required_confirmations: u64
    //List of submitted transactions
    transactions_list: StorageVec<Transaction> = StorageVec {},
    //Has given address confirmed
    has_confirmed: StorageMap<Address,bool> = StorageMap {},
    //Is a given tx confirmed by a given owner
    is_tx_confirmed_by: StorageMap<u64,has_confirmed> = StorageMap {},
}


