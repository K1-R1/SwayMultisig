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
    //Base asset balance
    balance: u64 = 0,
    //Mutex for constructor
    initialised: bool = false,
    //Allows checking is address is owner
    is_owner: StorageMap<Address,bool> = StorageMap {},
    //Number of confirmations in order for a transaction to be executed
    required_confirmations: u64
    //List of submitted transactions
    transactions_list: StorageVec<Transaction> = StorageVec {},
    //Is a given tx confirmed by a given owner
    is_tx_confirmed_by: StorageMap<(u64,Address), bool> = StorageMap {},
}

impl Multisig for Contract {
    //Constructor
     #[storage(read, write)]fn constructor(owners: Vec<Address>, required_confirmations: u64) {
        //Check that constructor has not been called before
        if storage.initialised == true {
            revert(0);
        }
        //Check that the number of owners is valid
        if owners.len() < 1 {
            revert(0);
        }
        //Check that the number of confirmations if valid
        if required_confirmations < 1 ||  required_confirmations > owners.len() {
            revert(0);
        }
        //Set info for each owner
        let mut i = 0;
        while i < owners.len() {
            //get owner
            let owner = owners.get(i);
            match owner {
                Option::None => {
                    revert(0)
                },
                Option::Some(owner) => {
                    //Check that owner address is unique
                    if storage.is_owner.get(owner) {
                        revert(0)
                    }
                    //Set info
                    storage.is_owner.insert(owner, true);
                },
            }
            i += 1;
        }
        //Set number of required confirmations before a transaction can be executed
        storage.required_confirmations = required_confirmations;
        //Set initialised to true, preventing constructor from being called again
        storage.initialised = true;
    }

    //All other func must first check  storage.initialised == true

    //Receive funds
    #[storage(read, write)]fn receive_funds() {
        //Check if multisig has been setup
        if storage.initialised == false {
            revert(0);
        } 
        if msg_asset_id() == BASE_ASSET_ID {
            // If we received `BASE_ASSET_ID` then keep track of the balance.
            // Otherwise, we're receiving other native assets and don't care
            // about our balance of tokens.
            storage.balance = storage.balance + msg_amount();
        }
    }

    //
}


